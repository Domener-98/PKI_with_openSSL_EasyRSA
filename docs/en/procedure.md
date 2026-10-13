# Technical procedure: implementing the PKI

[← Back to README](../../README.md) · [← Theoretical concepts](concepts.md)

> Certificate names have been anonymised (`user1`, `server1`) and blurred in the screenshots, along with personal information. Screenshots come from the original lab, so their file names are in French.

## Contents

1. [Environment](#1-environment)
2. [Preparing the directory structure](#2-preparing-the-directory-structure)
3. [Method 1: root CA with OpenSSL](#3-method-1-root-ca-with-openssl)
4. [Method 2: CA with Easy-RSA](#4-method-2-ca-with-easy-rsa)
5. [User and server certificates](#5-user-and-server-certificates)
6. [Certificate management and PKCS#12](#6-certificate-management-and-pkcs12)
7. [Certificate revocation](#7-certificate-revocation)
8. [CRL and OCSP](#8-crl-and-ocsp)
9. [Issue encountered: the missing revoked certificate](#9-issue-encountered-the-missing-revoked-certificate)

---

## 1. Environment

| Item | Choice |
|---|---|
| System | openSUSE Leap 15.6 (Oracle VirtualBox VM) |
| Tools | OpenSSL (direct key and certificate management), Easy-RSA (automation) |
| Distribution | Apache HTTP Server |
| Topology | Root CA + user and server certificates |

---

## 2. Preparing the directory structure

Before creating the certificate authority, we prepare a dedicated directory to store private keys, certificates, certificate signing requests (CSR) and revocation lists. The goal is to clearly separate what belongs to the CA from what belongs to users.

```bash
mkdir -p ~/projetPKI/ca
mkdir ~/projetPKI/ca/private
mkdir ~/projetPKI/ca/certs
mkdir ~/projetPKI/ca/new
mkdir ~/projetPKI/ca/crl
mkdir ~/projetPKI/ca/csr
mkdir ~/projetPKI/users
mkdir ~/projetPKI/users/private
mkdir ~/projetPKI/users/csr
mkdir ~/projetPKI/users/certs
chmod 700 ~/projetPKI/ca/private
touch ~/projetPKI/ca/index.txt
echo 3000 > ~/projetPKI/ca/serial
```

- `mkdir -p` creates each directory, including parent directories if needed.
- `chmod 700` grants read, write and execute permissions to the owner only (7), and none to the group (0) or others (0).
- `touch index.txt` creates an empty file used as the database of issued certificates.
- `echo 3000 > serial` initialises the serial number counter: each new certificate increments this value, starting from 3000.

![Project directory structure](../../screenshots/01-arborescence.png)

---

## 3. Method 1: root CA with OpenSSL

We create the root CA directly with OpenSSL. It is the top of the trust hierarchy and signs all other certificates.

### Generate the CA private key

```bash
cd ~/projetPKI/ca
openssl genrsa -aes256 -out private/ca.key 4096
```

| Parameter | Role |
|---|---|
| `openssl genrsa` | Generates an RSA key |
| `-aes256` | Encrypts the key with AES-256 (password protection) |
| `-out private/ca.key` | Key location |
| `4096` | Key size in bits |

The CA private key is the most sensitive element of the PKI, since it signs every certificate. It is therefore protected by a password.

### Secure the permissions

```bash
chmod 600 private/ca.key
```

`600`: only the owner can read and write the file.

### Create the self-signed root CA certificate

```bash
openssl req -x509 -new -key private/ca.key -sha256 -days 3650 -out certs/ca.crt
```

| Parameter | Role |
|---|---|
| `openssl req` | Creates a certificate request or an X.509 certificate |
| `-x509` | Directly outputs a self-signed certificate (instead of a CSR) |
| `-new` | New request |
| `-key private/ca.key` | Uses the private key created above |
| `-sha256` | SHA-256 hash algorithm |
| `-days 3650` | 10-year validity |
| `-out certs/ca.crt` | Certificate file |

**Information entered:** Country `BE`, State `Belgium`, Locality `Bruxelles`, Organization `PKI-ITSCM`, plus the administrator's Common Name and email address.

This certificate contains the name, the validity period and the public key. It is self-signed: it is a root, nobody above signs it.

![Creating the root certificate](../../screenshots/02-ca-racine-creation.png)

### Verify the root certificate

```bash
openssl x509 -in certs/ca.crt -noout -text
```

| Parameter | Role |
|---|---|
| `openssl x509` | X.509 certificate management tool |
| `-in certs/ca.crt` | Certificate to inspect |
| `-noout` | Does not print the Base64-encoded certificate |
| `-text` | Prints all information in readable form |

Things to check:

- the **Issuer** field matches the **Subject** field (self-signed certificate);
- the **CA:TRUE** extension is present;
- the validity period is 10 years.

![Verifying the root certificate](../../screenshots/03-ca-racine-verification.png)

![X509v3 extensions: CA:TRUE](../../screenshots/04-ca-racine-extensions.png)

---

## 4. Method 2: CA with Easy-RSA

Easy-RSA is a set of scripts that simplifies PKI management: where OpenSSL requires several detailed commands, Easy-RSA automates the steps.

### Installation on openSUSE

```bash
sudo zypper install easy-rsa
```

> **Conflict encountered:** PackageKit was blocking the installation. Stop it first with `sudo pkcon quit`, then run the installation again.

Verification:

```bash
rpm -ql easy-rsa
```

![Installing Easy-RSA](../../screenshots/05-easyrsa-installation.png)

### Preparing the environment

```bash
cd ~/projetPKI
mkdir easy-RSA
cd easy-RSA
cp /etc/easy-rsa/vars.example ./vars
cp /etc/easy-rsa/openssl-easyrsa.cnf ./
cp -r /etc/easy-rsa/x509-types ./
```

We use an isolated, project-specific configuration so that the system configuration is left untouched.

### Initialise the PKI

```bash
easyrsa init-pki
```

This command automatically creates `pki/private/`, `pki/reqs/`, `pki/issued/`, `pki/crl/`, as well as `index.txt` and `serial`. It replaces all the commands from [step 2](#2-preparing-the-directory-structure).

![PKI initialisation](../../screenshots/06-easyrsa-init-pki.png)

### Configure the `vars` file

The `vars` file defines the PKI default parameters, so they don't have to be entered again for every certificate.

```bash
nano vars
```

```bash
set_var EASYRSA_REQ_COUNTRY  "BE"
set_var EASYRSA_REQ_PROVINCE "Bruxelles"
set_var EASYRSA_REQ_CITY     "Bruxelles"
set_var EASYRSA_REQ_EMAIL    "<email-address>"
set_var EASYRSA_REQ_OU       "PKI-ITSCM"
set_var EASYRSA_KEY_SIZE     4096
set_var EASYRSA_CA_EXPIRE    3650
```

The full file is available in [`configs/vars`](../../configs/vars).

### Create the CA

```bash
easyrsa build-ca
```

This single command generates the private key (password-protected) and a self-signed certificate valid for 10 years, applies the correct permissions and updates `index.txt` and `serial`.

![build-ca (1/2)](../../screenshots/07-easyrsa-build-ca-1.png)

![build-ca (2/2)](../../screenshots/08-easyrsa-build-ca-2.png)

---

## 5. User and server certificates

We now create certificates signed by the CA. **User** certificates are used for authentication, email signing or data encryption. **Server** certificates secure HTTPS or VPN communications. We use Easy-RSA to speed things up.

### User certificate

**Generate the key and the CSR:**

```bash
cd ~/projetPKI/easy-RSA
easyrsa gen-req user1
```

`gen-req` generates the private key and the certificate signing request (CSR); `user1` is the user's name.

![User gen-req (1/2)](../../screenshots/09-gen-req-utilisateur-1.png)

![User gen-req (2/2)](../../screenshots/10-gen-req-utilisateur-2.png)

**Sign the client certificate:**

```bash
easyrsa sign-req client user1
```

`sign-req` signs a CSR; `client` is the certificate type (user).

![Signing the client certificate](../../screenshots/11-sign-req-client.png)

**Check the database:**

```bash
cat pki/index.txt
```

The certificate is recorded: the **V** at the start of the line means *valid*.

![index.txt: valid certificate](../../screenshots/12-index-utilisateur.png)

### Server certificate

**Generate the key and the CSR:**

```bash
easyrsa gen-req server1
```

![Server gen-req](../../screenshots/13-gen-req-serveur.png)

**Sign as a server certificate:**

```bash
easyrsa sign-req server server1
```

The `server` type adds the *TLS Web Server Authentication* extended key usage.

![Signing the server certificate](../../screenshots/14-sign-req-serveur.png)

---

## 6. Certificate management and PKCS#12

### Display certificate information

```bash
openssl x509 -in ~/projetPKI/easy-RSA/pki/issued/user1.crt -noout -text
openssl x509 -in ~/projetPKI/easy-RSA/pki/issued/user1.crt -noout -dates
openssl x509 -in ~/projetPKI/easy-RSA/pki/issued/server1.crt -noout -subject
```

- `-text` displays all certificate information;
- `-dates` displays the start (`notBefore`) and end (`notAfter`) of validity;
- `-subject` displays the subject, including the Common Name (CN).

![Certificate details](../../screenshots/15-x509-text.png)

![Validity dates](../../screenshots/16-x509-dates.png)

![Certificate subject](../../screenshots/17-x509-subject.png)

### Create a PKCS#12 file

A PKCS#12 file (`.p12`) bundles the user's private key, their certificate and the CA certificate, all protected by a password. It is the convenient format for handing a certificate to a user.

```bash
cd ~/projetPKI/easy-RSA
openssl pkcs12 -export \
  -out pki/issued/user1.p12 \
  -inkey pki/private/user1.key \
  -in pki/issued/user1.crt \
  -certfile pki/ca.crt \
  -name "Certificat user1 - PKI ITSCM"
```

| Parameter | Role |
|---|---|
| `pkcs12 -export` | Creates a PKCS#12 file |
| `-out` | Output file |
| `-inkey` | User's private key |
| `-in` | User's signed certificate |
| `-certfile` | CA certificate |
| `-name` | Display name |

![PKCS#12 export](../../screenshots/18-pkcs12-export.png)

### Display the content of the PKCS#12 file

```bash
openssl pkcs12 -in pki/issued/user1.p12 -info -noout
```

`-info` displays information about the file structure; `-noout` hides the encoded content.

![PKCS#12 content](../../screenshots/19-pkcs12-info.png)

---

## 7. Certificate revocation

Revoking a certificate means cancelling it before its expiry date. Common reasons: compromised private key, an employee leaving, an error in the certificate, a change in security policy.

```bash
easyrsa revoke server1
```

![Revoking the server certificate](../../screenshots/20-revocation.png)

**Check the index:**

```bash
cat pki/index.txt
```

The **R** at the start of the second line confirms that the server certificate has been revoked.

![index.txt: revoked certificate](../../screenshots/21-index-revocation.png)

---

## 8. CRL and OCSP

After every revocation, the CRL must be regenerated to stay up to date. Good practice is to regenerate it regularly, even without any revocation, because a CRL has its own expiry date.

### Generate the CRL

```bash
easyrsa gen-crl
```

![Generating the CRL](../../screenshots/22-gen-crl.png)

### Publish the CRL on the web server

```bash
sudo mkdir -p /var/www/html
sudo cp pki/crl.pem /var/www/html/ca.crl
ls -lh /var/www/html/ca.crl
sudo chmod 644 /var/www/html/ca.crl
```

- We prepare the web publication directory, then copy the CRL into it.
- `ls -lh` confirms the copy.
- `chmod 644` makes the file readable by everyone and writable only by root.

![Publishing the CRL](../../screenshots/23-publication-crl.png)

### Create a certificate for the OCSP responder

OCSP responses must be signed so they cannot be forged. By signing the responder's certificate with our CA, clients know they can trust it.

```bash
easyrsa gen-req ocsp-responder nopass
easyrsa sign-req server ocsp-responder
```

The `nopass` option creates the private key without a password, so the OCSP server can start without manual input.

![OCSP responder certificate](../../screenshots/24-ocsp-responder.png)

### Start the OCSP server

```bash
openssl ocsp \
  -index ~/projetPKI/ca/index.txt \
  -port 8888 \
  -rsigner ~/projetPKI/easy-RSA/pki/issued/ocsp-responder.crt \
  -rkey ~/projetPKI/easy-RSA/pki/private/ocsp-responder.key \
  -CA ~/projetPKI/ca/certs/ca.crt \
  -text
```

| Parameter | Role |
|---|---|
| `openssl ocsp` | Runs OpenSSL in OCSP server mode |
| `-index` | Database containing certificate statuses |
| `-port 8888` | Listening port |
| `-rsigner` | Certificate used to sign OCSP responses |
| `-rkey` | Associated private key |
| `-CA` | CA certificate |
| `-text` | Displays responses in detail |

![OCSP server listening](../../screenshots/25-ocsp-serveur.png)

> **Note after review:** this command points to the index and certificate of the OpenSSL CA (method 1), whereas the tested certificates were issued by the Easy-RSA CA (method 2). To correctly query the status of Easy-RSA certificates, use `-index ~/projetPKI/easy-RSA/pki/index.txt` and `-CA ~/projetPKI/easy-RSA/pki/ca.crt`. The corrected version is in [`scripts/05-ocsp.sh`](../../scripts/05-ocsp.sh).

### Query the OCSP server

In a second terminal:

```bash
openssl ocsp \
  -CAfile ~/projetPKI/easy-RSA/pki/ca.crt \
  -issuer ~/projetPKI/easy-RSA/pki/ca.crt \
  -cert ~/projetPKI/easy-RSA/pki/issued/user1.crt \
  -url http://localhost:8888/ \
  -resp_text
```

| Parameter | Role |
|---|---|
| `-CAfile` | CA used to verify the response signature |
| `-issuer` | Certificate of the authority that issued the tested certificate |
| `-cert` | Certificate whose status we want to check |
| `-url` | OCSP server address |
| `-resp_text` | Displays the OCSP response |

---

## 9. Issue encountered: the missing revoked certificate

When trying to check the status of the revoked certificate through OCSP, the file `server1.crt` no longer existed in `pki/issued/`.

**Explanation:** when revoking a certificate, Easy-RSA moves it to `pki/revoked/certs_by_serial/` and renames it after its **serial number** instead of its Common Name.

```bash
find ~/projetPKI/easy-RSA/pki/ -name "*.crt"
```

![Searching for the revoked certificate](../../screenshots/26-certificat-revoque-recherche.png)

![Revoked certificate content](../../screenshots/27-certificat-revoque-contenu.png)

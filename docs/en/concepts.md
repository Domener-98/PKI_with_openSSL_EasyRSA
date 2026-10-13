# PKI theoretical concepts

[← Back to README](../../README.md) · [Technical procedure →](procedure.md)

## Contents

1. [Introduction to PKI](#1-introduction-to-pki)
2. [Core concepts: keys, certificates and trust](#2-core-concepts-keys-certificates-and-trust)
3. [Roles and components of a PKI](#3-roles-and-components-of-a-pki)
4. [Certificate policy and practice](#4-certificate-policy-and-practice)

---

## 1. Introduction to PKI

### 1.1. Project brief

As part of the cybersecurity course (2nd-year Bachelor in Cybersecurity) at the Institut Technique Supérieur Cardinal Mercier, our group was tasked with designing and deploying a Public Key Infrastructure (PKI). The goal was to master the fundamental mechanisms of digital trust by applying theoretical concepts to a real infrastructure running openSUSE Leap 15.6, using OpenSSL and Easy-RSA.

**Project objectives:**

- Understand and apply the cryptographic principles of a PKI
- Set up a hierarchy of certificate authorities (root CA and end-entity certificates)
- Issue, manage and revoke X.509 digital certificates
- Distribute certificates and CRLs through a web server (Apache)
- Document every step in a professional way

**Real-world use case: HTTPS.** The most visible everyday use of a PKI is securing web connections. Every time a browser shows a padlock in the address bar, a PKI is working behind the scenes.

### 1.2. What is a Public Key Infrastructure?

A Public Key Infrastructure (PKI) is a set of technologies and rules used to create cryptographic keys and their associated certificates.

A PKI secures data exchanges and verifies the identity of users, websites and devices we communicate with.

It relies on a key pair (public and private) and on certificates issued by a Certificate Authority (CA). The public key is shared and visible to everyone, while the private key must remain secret. The certificate proves that the public key really belongs to the expected entity. This system makes it possible to encrypt communications and guarantee their integrity.

Certificates provide three functions:

- **Authentication**: we are communicating with the intended entity
- **Confidentiality**: the communication is encrypted
- **Integrity**: we can detect whether data was altered during transmission

### 1.3. Security and digital trust challenges

PKIs play a key role in security and digital trust:

- They guarantee **authenticity** by confirming the identity of the user or server we are communicating with.
- They ensure the **confidentiality** of exchanges through encryption, preventing intercepted data from being read.
- They preserve the **integrity** of exchanged information, using digital signatures to verify that content has not been modified.

---

## 2. Core concepts: keys, certificates and trust

### 2.1. The padlock and key metaphor

To understand asymmetric cryptography, the core of a PKI, we can use the analogy of a padlock and a key.

Imagine you own an open padlock that you can freely hand out to anyone: that is your **public key**. Anyone who wants to send you a confidential message puts it in a box and snaps your padlock shut on it. Only you own the key that opens this padlock: that is your **private key**. Even the person who closed the padlock can no longer open the box.

This is the principle of asymmetric cryptography (or public key cryptography). Unlike symmetric cryptography, where the same key encrypts and decrypts, two mathematically linked keys play opposite and complementary roles.

### 2.2. The key pair: public and private

|                   | **Public key**                              | **Private key**                                  |
|-------------------|---------------------------------------------|--------------------------------------------------|
| **Distribution**  | Freely shared (inside the certificate)      | Confidential                                     |
| **Main role**     | Encrypt a message / verify a signature      | Decrypt a message / create a signature           |
| **Analogy**       | The open padlock (handed out to everyone)   | The single key that opens this padlock           |
| **If lost**       | A new key pair can be generated             | Compromise = immediate certificate revocation    |

### 2.3. The X.509 digital certificate

How can we be sure that a public key really belongs to the person or server we think we are contacting? This is where the digital certificate comes in.

A digital certificate is an electronic document that binds a public key to an identity (person, server, organisation). It is digitally signed by a certificate authority, which vouches for this binding. It is the equivalent of a digital ID card: the name, the photo (the public key) and the official stamp of a trusted authority (the CA).

---

## 3. Roles and components of a PKI

### 3.1. The Certificate Authority (CA)

A certificate authority is a trusted entity within a PKI. Its main role is to issue digital certificates, which bind a public key to a verified identity. The CA signs certificates with its private key; any entity that trusts the CA can verify a certificate using the CA's public key.

The CA has several roles:

1. **Identity verification**: making sure the requester is who they claim to be.
2. **Certificate issuance**: binding the public key to the verified identity and signing it with its private key.
3. **Publication and distribution**: making certificates available to those who need them.
4. **Lifecycle management**: renewal, and revocation of compromised or expired certificates. Revoked certificates are published in Certificate Revocation Lists (CRL), and their status can be checked in real time through OCSP.
5. **Root of trust**: the CA is the trust anchor of the whole PKI.

### 3.2. The Registration Authority (RA)

A Registration Authority (RA) verifies the legitimacy of the certificate requester, based on the information they provide (identity, address, etc.). Once verified, the RA forwards the request to the CA, which issues the certificate. This separation adds an extra layer of security to the process.

### 3.3. Trust models: hierarchical or distributed

**Hierarchical architecture.** A tree structure with the root CA at the top, acting as the trust anchor. Below it are intermediate CAs, which derive their authority from the root and can issue certificates themselves. At the bottom are the certificate requesters. This model is simple to set up and manage, but it relies on a single point of trust.

**Distributed architecture.** No single CA dominates the structure: several authorities trust each other mutually, like nodes in a peer-to-peer network. If one CA fails, the model does not collapse, but it is much more complex to set up and manage.

Most companies use the hierarchical architecture; the distributed model is reserved for specific cases.

### 3.4. Certificate publication and directory management

Once certificates are generated, the CA must publish the root and intermediate CA certificates, the end-entity certificates (users, servers, etc.) and revocation information (CRL or OCSP service).

This publication relies on repositories:

- **LDAP**, a centralised directory;
- **HTTP/HTTPS**, the most common and accessible method, used to publish CA certificates, CRLs and OCSP responses.

### 3.5. The LDAP v3 protocol

LDAP (Lightweight Directory Access Protocol) v3 is used as a publication repository in a PKI. It centralises the distribution of CA certificates, user certificates and revocation lists. Since it is supported by many systems, it makes this information easy to access.

---

## 4. Certificate policy and practice

### 4.1. The Certificate Policy (CP)

A certificate policy is a named set of rules that indicates the applicability of a certificate to a particular community or class of applications with common security requirements. It helps relying parties decide whether a certificate is trustworthy enough for a given use.

**Main elements of a CP:**

- **Identification and scope**: name, unique identifier (OID), scope (certificate types, target community)
- **Security levels**: classification of certificates by assurance level, with minimum requirements and authorised uses
- **Responsibilities**: obligations of the CA, the certificate holders and the relying parties
- **Operational requirements**: validity period, identity verification, revocation conditions, private key protection
- **Legal aspects**: liability limitations, dispute resolution, regulatory compliance (GDPR, eIDAS)

### 4.2. The Certification Practice Statement (CPS)

The CPS describes in detail the practices a CA follows when issuing and managing certificates. It can be seen as an agreement between the organisation running the CA and the people relying on its certificates.

**CP vs CPS:**

- **CP**: strategic document defining general rules and requirements
- **CPS**: operational document detailing the technical procedures used to implement the CP

**Content of a CPS:**

- **Physical security**: system location, physical protection, access control, video surveillance
- **Logical security**: private key protection, cryptographic algorithms, access management
- **Operational procedures**: key generation, identity verification, issuance and revocation, processing times
- **Personnel management**: roles, responsibilities, training, separation of duties
- **Audits and compliance**: audit frequency, logging, log retention

---

*Sources: see the [bibliography](../bibliography.md).*

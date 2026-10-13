
# Issue user and server certificates, PKCS#12 export


USER_CN="${1:-user1}"
SERVER_CN="${2:-server1}"

cd ~/projetPKI/easy-RSA

# User certificate (client)
easyrsa gen-req "$USER_CN"
easyrsa sign-req client "$USER_CN"

# Server certificate
easyrsa gen-req "$SERVER_CN"
easyrsa sign-req server "$SERVER_CN"

# Database: V = valid
cat pki/index.txt

# Inspection
openssl x509 -in "pki/issued/$USER_CN.crt" -noout -dates
openssl x509 -in "pki/issued/$SERVER_CN.crt" -noout -subject

# PKCS#12 export (key + certificate + CA), password-protected
openssl pkcs12 -export \
  -out "pki/issued/$USER_CN.p12" \
  -inkey "pki/private/$USER_CN.key" \
  -in "pki/issued/$USER_CN.crt" \
  -certfile pki/ca.crt \
  -name "Certificat $USER_CN - PKI ITSCM"

openssl pkcs12 -in "pki/issued/$USER_CN.p12" -info -noout

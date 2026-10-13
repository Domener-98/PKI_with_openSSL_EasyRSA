#!/usr/bin/env bash
# Method 1: manual creation of a root CA with OpenSSL
# Rebuilt from the project documentation (docs/en/procedure.md, sections 2 and 3)
set -euo pipefail

BASE=~/projetPKI

# 1. Directory structure
mkdir -p "$BASE"/ca/{private,certs,new,crl,csr}
mkdir -p "$BASE"/users/{private,csr,certs}
chmod 700 "$BASE/ca/private"
touch "$BASE/ca/index.txt"
echo 3000 > "$BASE/ca/serial"

cd "$BASE/ca"

# 2. CA private key (RSA 4096, AES-256 encrypted -> password prompt)
openssl genrsa -aes256 -out private/ca.key 4096
chmod 600 private/ca.key

# 3. Self-signed root CA certificate (10 years)
openssl req -x509 -new -key private/ca.key -sha256 -days 3650 -out certs/ca.crt

# 4. Check: Issuer = Subject, CA:TRUE, 10-year validity
openssl x509 -in certs/ca.crt -noout -text

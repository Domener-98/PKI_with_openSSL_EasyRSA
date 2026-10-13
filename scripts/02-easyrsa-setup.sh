#!/usr/bin/env bash
# Method 2: Easy-RSA installation and CA creation (openSUSE Leap 15.6)
# Rebuilt from the project documentation (docs/en/procedure.md, section 4)
set -euo pipefail

# Installation (if PackageKit blocks zypper: sudo pkcon quit)
sudo zypper install -y easy-rsa
rpm -ql easy-rsa

# Isolated, project-specific environment
mkdir -p ~/projetPKI/easy-RSA
cd ~/projetPKI/easy-RSA
cp /etc/easy-rsa/vars.example ./vars
cp /etc/easy-rsa/openssl-easyrsa.cnf ./
cp -r /etc/easy-rsa/x509-types ./

# Remember to edit ./vars (see configs/vars)

# Initialise the PKI and create the CA (password prompt)
easyrsa init-pki
easyrsa build-ca

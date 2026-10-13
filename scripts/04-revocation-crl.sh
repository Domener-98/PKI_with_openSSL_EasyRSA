
# Certificate revocation, CRL generation and publication


SERVER_CN="server1"

cd ~/projetPKI/easy-RSA

# Revocation (the certificate is moved to pki/revoked/certs_by_serial/)
easyrsa revoke "$SERVER_CN"
cat pki/index.txt   # R = revoked

# New CRL
easyrsa gen-crl

# Publish on the Apache web server
sudo mkdir -p /var/www/html
sudo cp pki/crl.pem /var/www/html/ca.crl
sudo chmod 644 /var/www/html/ca.crl
ls -lh /var/www/html/ca.crl

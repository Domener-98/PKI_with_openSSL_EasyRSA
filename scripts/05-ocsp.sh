#!/usr/bin/env bash
# OCSP responder for the Easy-RSA CA
# Usage :
#   ./05-ocsp.sh init            -> creates the responder certificate
#   ./05-ocsp.sh server          -> starts the OCSP server (terminal 1)
#   ./05-ocsp.sh check <CN>      -> queries a certificate's status (terminal 2)
#
# Corrected version: the index and CA point to the Easy-RSA PKI,
# which issued the tested certificates (see the note in docs/en/procedure.md).
set -euo pipefail

PKI=~/projetPKI/easy-RSA/pki
PORT=8888

case "${1:-}" in
  init)
    cd ~/projetPKI/easy-RSA
    easyrsa gen-req ocsp-responder nopass
    easyrsa sign-req server ocsp-responder
    ;;
  server)
    openssl ocsp \
      -index "$PKI/index.txt" \
      -port "$PORT" \
      -rsigner "$PKI/issued/ocsp-responder.crt" \
      -rkey "$PKI/private/ocsp-responder.key" \
      -CA "$PKI/ca.crt" \
      -text
    ;;
  check)
    CN="${2:?Specify the certificate CN}"
    CERT="$PKI/issued/$CN.crt"
    # A revoked certificate is renamed by serial number in revoked/certs_by_serial/
    [ -f "$CERT" ] || { echo "Not found in issued/: look in $PKI/revoked/certs_by_serial/"; exit 1; }
    openssl ocsp \
      -CAfile "$PKI/ca.crt" \
      -issuer "$PKI/ca.crt" \
      -cert "$CERT" \
      -url "http://localhost:$PORT/" \
      -resp_text
    ;;
  *)
    echo "Usage: $0 {init|server|check <CN>}"; exit 1 ;;
esac

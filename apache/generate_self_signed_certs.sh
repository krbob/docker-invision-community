#!/bin/bash

CERT_DIR=${HTTPD_PREFIX}/conf/
openssl genrsa -out $CERT_DIR/privkey.pem 2048
openssl req -new -key $CERT_DIR/privkey.pem -out $CERT_DIR/cert.csr -subj "/CN=${DOMAIN_NAME}"
openssl x509 -req -days 365 -in $CERT_DIR/cert.csr -signkey $CERT_DIR/privkey.pem -out $CERT_DIR/fullchain.pem
rm $CERT_DIR/cert.csr

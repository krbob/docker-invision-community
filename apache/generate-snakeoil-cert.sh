#!/bin/bash

CERT_DIR=${HTTPD_PREFIX}/conf/
openssl genpkey -algorithm RSA -out ${CERT_DIR}/snakeoil.key -pkeyopt rsa_keygen_bits:2048
openssl req -new -x509 -key ${CERT_DIR}/snakeoil.key -out ${CERT_DIR}/snakeoil.crt -days 365 -subj "/C=PL/ST=Test/L=Test/O=Test/OU=Test/CN=localhost"

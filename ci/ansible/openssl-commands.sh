#! /bin/bash

mkdir openssl-ca/certs openssl-ca/crl openssl-ca/newcerts openssl-ca/private
touch openssl-ca/index.txt
echo 1000 > openssl-ca/serial

openssl genrsa -aes256 -out openssl-ca/private/ca.key.pem 4096

openssl req -config openssl-ca/openssl.cnf -key openssl-ca/private/ca.key.pem -new -x509 -days 7300 -sha256 -extensions v3_ca -out openssl-ca/certs/ca.cert.pem

openssl x509 -noout -text -in openssl-ca/certs/ca.cert.pem

mkdir openssl-ca/intermediate/certs openssl-ca/intermediate/crl openssl-ca/intermediate/csr openssl-ca/intermediate/newcerts openssl-ca/intermediate/private
touch openssl-ca/intermediate/index.txt

echo 1000 > openssl-ca/intermediate/serial
echo 1000 > openssl-ca/intermediate/crlnumber

openssl genrsa -out openssl-ca/intermediate/private/intermediate.key.pem 4096

openssl req -config openssl-ca/intermediate/openssl.cnf -new -key openssl-ca/intermediate/private/intermediate.key.pem -out openssl-ca/intermediate/csr/intermediate.csr.pem

openssl ca -config openssl-ca/openssl.cnf -extensions v3_intermediate_ca -days 366 -notext -md sha256 -in openssl-ca/intermediate/csr/intermediate.csr.pem -out openssl-ca/intermediate/certs/intermediate.cert.pem

cat openssl-ca/intermediate/certs/intermediate.cert.pem openssl-ca/certs/ca.cert.pem > openssl-ca/intermediate/certs/ca-chain.cert.pem

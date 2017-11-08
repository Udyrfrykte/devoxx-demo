#! /bin/bash

openssl genrsa -out ansible/openssl-ca/intermediate/private/${1}.key.pem 2048

openssl req -config ansible/openssl-ca/intermediate/openssl.cnf -key ansible/openssl-ca/intermediate/private/${1}.key.pem -new -out ansible/openssl-ca/intermediate/csr/${1}.csr.pem  -subj "/C=FR/ST=France/O=OCTO/CN=${1}"

(sleep 1; echo "y"; sleep 1; echo "y") | openssl ca -config ansible/openssl-ca/intermediate/openssl.cnf -extensions server_cert -days 100 -notext -in ansible/openssl-ca/intermediate/csr/${1}.csr.pem -out ansible/openssl-ca/intermediate/certs/${1}.cert.pem

cat ansible/openssl-ca/intermediate/certs/${1}.cert.pem ansible/openssl-ca/intermediate/certs/ca-chain.cert.pem ansible/openssl-ca/intermediate/private/${1}.key.pem >| ansible/openssl-ca/intermediate/certs/${1}.pem
cat ansible/openssl-ca/intermediate/certs/${1}.cert.pem ansible/openssl-ca/intermediate/certs/ca-chain.cert.pem >| ansible/openssl-ca/intermediate/certs/${1}.cert_chain.pem

cp ansible/openssl-ca/intermediate/certs/${1}.pem haproxy/certs/

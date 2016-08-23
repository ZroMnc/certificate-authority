#!/usr/bin/env bash
set -e

PKI_PATH="./pki"
ROOT_CA="$PKI_PATH/root"
INTERMEDIATE_CA="$PKI_PATH/intermediate"
ROOT_CA_PWD="changeit"

if [[ -d "$PKI_PATH" ]]; then
  printf "[ERROR] Path \"$PKI_PATH\" already exists\n"
  exit 1
fi

printf "\n[INFO] Setting things up:\n"
mkdir -p {$ROOT_CA,$INTERMEDIATE_CA}/{certs,crl,newcerts,private,csr}
chmod 700 {$ROOT_CA,$INTERMEDIATE_CA}/private
touch {$ROOT_CA,$INTERMEDIATE_CA}/index.txt

for file in $ROOT_CA/serial $INTERMEDIATE_CA/serial $INTERMEDIATE_CA/crlnumber ; do
  printf 1000 > $file
done

cp root.cnf $ROOT_CA/openssl.cnf
cp intermediate.cnf $INTERMEDIATE_CA/openssl.cnf

printf "\n[INFO] Generating Root CA key:\n"
openssl genrsa -aes256 -passout pass:$ROOT_CA_PWD -out $ROOT_CA/private/ca.key.pem 4096

printf "\n[INFO] Generating Root CA certificate:\n"
openssl req -config $ROOT_CA/openssl.cnf \
        -key $ROOT_CA/private/ca.key.pem \
        -new -x509 -days 3650 -sha256 \
        -extensions v3_ca \
        -passin pass:$ROOT_CA_PWD \
        -out $ROOT_CA/certs/ca.cert.pem

printf "\n[INFO] Generating Intermediate CA key:\n"
openssl genrsa -aes256 -passout pass:$ROOT_CA_PWD -out $INTERMEDIATE_CA/private/intermediate.key.pem 4096

printf "\n[INFO] Generating Intermediate CA certificate request:\n"
openssl req -config $INTERMEDIATE_CA/openssl.cnf \
        -key $INTERMEDIATE_CA/private/intermediate.key.pem \
        -new -sha256 \
        -passin pass:$ROOT_CA_PWD \
        -out $INTERMEDIATE_CA/csr/intermediate.csr.pem

printf "\n[INFO] Requesting Intermediate CA certificate to the Root CA:\n"
openssl ca -config $ROOT_CA/openssl.cnf -extensions v3_ca -days 1825 \
  -notext -md sha256 -passin pass:$ROOT_CA_PWD -in $INTERMEDIATE_CA/csr/intermediate.csr.pem \
  -out $INTERMEDIATE_CA/certs/intermediate.cert.pem

printf "\n[INFO] Building certification chain:\n"
cat $INTERMEDIATE_CA/certs/intermediate.cert.pem $ROOT_CA/certs/ca.cert.pem \
  > $INTERMEDIATE_CA/certs/chain.cert.pem
printf "$INTERMEDIATE_CA/certs/chain.pem\n"

printf "\n[INFO] All done!\n"

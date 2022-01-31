#!/bin/bash

COMMON_NAME=${COMMON_NAME:?required}

SUBJECT=$( \
  printf "/C=JP"; \
  printf "/ST=Tokyo-to"; \
  printf "/L=Chiyoda-ku"; \
  printf "/O=Example Organization CO., LTD."; \
  printf "/OU=Development"; \
  printf "/CN=${COMMON_NAME}"; \
)

cd /tmp

openssl genrsa 2048 > server.key
echo "subjectAltName=DNS:${COMMON_NAME}" > server.ext

openssl req -new \
  -key server.key \
  -subj "${SUBJECT}" > server.csr

openssl x509 -req \
  -days 825 \
  -signkey server.key \
  -in server.csr \
  -out server.crt \
  -extfile server.ext

openssl x509 -text -noout -in server.crt

mv server.key /out/server.key
mv server.crt /out/server.crt

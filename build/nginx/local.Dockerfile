FROM nginx:alpine

ARG COMMON_NAME

RUN : "${COMMON_NAME?:COMMON_NAME is required.}" \
    && set -eux \
    && apk update \
    && apk upgrade \
    && apk add --no-cache --update --virtual needless_libset openssl \
    && cd /tmp \
    && openssl genrsa 2048 > server.key \
    && echo "subjectAltName=DNS:${COMMON_NAME}" > server.ext \
    && SUBJECT=$( \
        printf "/C=JP"; \
        printf "/ST=Tokyo-to"; \
        printf "/L=Chiyoda-ku"; \
        printf "/O=Mythrnr."; \
        printf "/OU=Template Project Golang"; \
        printf "/CN=${COMMON_NAME}"; \
    ) \
    && openssl req -new \
        -key server.key \
        -subj "${SUBJECT}" > server.csr \
    && openssl x509 -req \
        -days 825 \
        -signkey server.key \
        -in server.csr \
        -out server.crt \
        -extfile server.ext \
    && openssl x509 -text -noout -in server.crt \
    && mv server.key /etc/nginx/template-pj-golang.key \
    && mv server.crt /etc/nginx/template-pj-golang.crt \
    && apk del needless_libset \
    && rm -rf /tmp/* \
    && rm -rf /var/cache/apk/*

# syntax=docker/dockerfile:1
FROM nginx:alpine as builder

ARG APP_VERSION
ARG GITHUB_TOKEN
ARG GITHUB_REPO_BASE="https://x-access-token:${GITHUB_TOKEN}@github.com/mythrnr"
ARG HTTP_PROXY
ARG HTTPS_PROXY

WORKDIR "/usr/src/github.com/mythrnr"

RUN <<EOF
    : "${GITHUB_TOKEN:?GITHUB_TOKEN is required.}"
    : "${APP_VERSION:?APP_VERSION is required.}"
    set -eux
    #
    # Update apk packages
    #
    apk update
    apk upgrade
    apk add --no-cache git
    git clone ${GITHUB_REPO_BASE}/template-pj-golang.git
    cd template-pj-golang
    git checkout `git rev-parse ${APP_VERSION}`
EOF

FROM nginx:alpine

COPY --from=builder \
    /usr/src/github.com/mythrnr/template-pj-golang/build/nginx/conf.d/ \
    /etc/nginx/conf.d/
COPY --from=builder \
    /usr/src/github.com/mythrnr/template-pj-golang/build/nginx/www/html/ \
    /var/www/html/

RUN <<EOF
    set -eux
    #
    # Update apk packages
    #
    apk update
    apk upgrade
    chown -R nginx:nginx /etc/nginx /var/www/html
    rm -rf /tmp/* /var/cache/apk/*
EOF

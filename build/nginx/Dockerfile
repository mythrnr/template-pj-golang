FROM nginx:alpine as builder

ARG APP_VERSION
ARG GITHUB_TOKEN
ARG GITHUB_REPO_BASE="https://${GITHUB_TOKEN}:x-oauth-basic@github.com/mythrnr"
ARG HTTP_PROXY
ARG HTTPS_PROXY

WORKDIR "/usr/src/github.com/mythrnr"

RUN : "${GITHUB_TOKEN:?GITHUB_TOKEN is required.}" \
    && : "${APP_VERSION:?APP_VERSION is required.}" \
    && set -x \
    && apk update \
    && apk upgrade \
    && apk add --no-cache git \
    && git clone ${GITHUB_REPO_BASE}/template-pj-golang.git \
    && cd template-pj-golang \
    && git checkout `git rev-parse ${APP_VERSION}`

FROM nginx:alpine

COPY --from=builder \
    /usr/src/github.com/mythrnr/template-pj-golang/build/nginx/conf.d/ \
    /etc/nginx/conf.d/
COPY --from=builder \
    /usr/src/github.com/mythrnr/template-pj-golang/build/nginx/www/html/ \
    /var/www/html/

RUN set -x \
    && apk update \
    && apk upgrade \
    && chown -R nginx:nginx /etc/nginx /var/www/html \
    && rm -f /var/cache/apk/*

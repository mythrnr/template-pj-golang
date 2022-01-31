FROM nginx:alpine

RUN set -eux \
    && apk update \
    && apk upgrade \
    && rm -rf /tmp/* /var/cache/apk/*

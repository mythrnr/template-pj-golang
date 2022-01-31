FROM alpine

WORKDIR /workdir

RUN set -eux \
    && apk update \
    && apk upgrade \
    && apk add --no-cache openssl \
    && rm -rf /tmp/* /var/cache/apk/*

COPY scripts/certs.sh /certs.sh

ENTRYPOINT [ "sh", "/certs.sh" ]

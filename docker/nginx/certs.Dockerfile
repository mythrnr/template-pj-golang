# syntax=docker/dockerfile:1
FROM alpine

WORKDIR /workdir

RUN <<EOF
    set -eux
    #
    # Update apk packages
    #
    apk update
    apk upgrade
    apk add --no-cache openssl
    rm -rf /tmp/*
    rm -rf /var/cache/apk/*
EOF

COPY scripts/certs.sh /certs.sh

ENTRYPOINT [ "sh", "/certs.sh" ]

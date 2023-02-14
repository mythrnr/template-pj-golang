FROM nginx:alpine

RUN <<EOF
    set -eux
    #
    # Update apk packages
    #
    apk update
    apk upgrade
    rm -rf /tmp/* /var/cache/apk/*
EOF

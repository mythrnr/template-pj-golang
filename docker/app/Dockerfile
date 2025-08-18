# syntax=docker/dockerfile:1
FROM golang:1.25 as base

ARG HTTP_PROXY
ARG HTTPS_PROXY
ARG WORK_DIR="/go"

WORKDIR ${WORK_DIR}
SHELL ["/bin/bash", "-eoux", "pipefail", "-c"]

RUN <<EOF
    #
    # Install and update packages
    #
    apt-get update
    apt-get upgrade -y
    apt-get install -y --no-install-recommends \
        autoconf \
        inotify-tools \
        jq \
        libtool \
        socat \
        tar \
        xz-utils

    #
    # Add user
    #
    addgroup golang
    adduser \
        --home /home/golang \
        --ingroup golang golang
    echo "alias ll='ls -ahl'" >> /home/golang/.profile

    #
    # Prepare directories for Golang
    #
    mkdir -p \
        "${WORK_DIR}/bin" \
        "${WORK_DIR}/pkg" \
        "${WORK_DIR}/src"

    cd /tmp || exit 1

    #
    # Install UPX
    #
    UPX_LATEST_TAG_URL="https://api.github.com/repos/upx/upx/releases/latest"
    if [ "" != "${HTTPS_PROXY}" ]; then
        UPX_TAG=$(curl -x "${HTTPS_PROXY}" -sL "${UPX_LATEST_TAG_URL}" | jq -r '.tag_name');
    else
        UPX_TAG=$(curl -sL "${UPX_LATEST_TAG_URL}" | jq -r '.tag_name');
    fi

    UPX_VERSION="${UPX_TAG#v}"
    UPX_BIN_URL_PREFIX="https://github.com/upx/upx/releases/download/${UPX_TAG}/upx-${UPX_VERSION}"
    if [ "$(uname -m)" = "x86_64" ]; then
        UPX_BIN_URL="${UPX_BIN_URL_PREFIX}-amd64_linux.tar.xz";
        UPX_BIN_FILE="upx-${UPX_VERSION}-amd64_linux";
    else
        UPX_BIN_URL="${UPX_BIN_URL_PREFIX}-arm64_linux.tar.xz";
        UPX_BIN_FILE="upx-${UPX_VERSION}-arm64_linux";
    fi

    if [ "" != "${HTTPS_PROXY}" ]; then
        curl -x "${HTTPS_PROXY}" -o "${UPX_BIN_FILE}.tar.xz" -L "${UPX_BIN_URL}";
    else
        curl -o "${UPX_BIN_FILE}.tar.xz" -L "${UPX_BIN_URL}";
    fi

    tar -xvf "${UPX_BIN_FILE}.tar.xz"
    mv "${UPX_BIN_FILE}/upx" /usr/bin/upx
    chmod +x /usr/bin/upx

    #
    # Install Migrate
    #
    GOMIGRATE_LATEST_TAG_URL="https://api.github.com/repos/golang-migrate/migrate/releases/latest"
    if [ "x" != "x${HTTPS_PROXY}" ]; then
        GOMIGRATE_TAG="$(curl -x ${HTTPS_PROXY} -sL ${GOMIGRATE_LATEST_TAG_URL} | jq -r '.tag_name')";
    else
        GOMIGRATE_TAG="$(curl -sL ${GOMIGRATE_LATEST_TAG_URL} | jq -r '.tag_name')";
    fi

    GOMIGRATE_URL="https://github.com/golang-migrate/migrate/releases/download/${GOMIGRATE_TAG}/"
    if [ "$(uname -m)" = "x86_64" ]; then
        GOMIGRATE_FILE="migrate.linux-amd64";
    else
        GOMIGRATE_FILE="migrate.linux-arm64";
    fi

    if [ "x" != "x${HTTPS_PROXY}" ]; then
        curl -x "${HTTPS_PROXY}" -o "${GOMIGRATE_FILE}.tar.gz" -L "${GOMIGRATE_URL}${GOMIGRATE_FILE}.tar.gz";
    else
        curl -o "${GOMIGRATE_FILE}.tar.gz" -L "${GOMIGRATE_URL}${GOMIGRATE_FILE}.tar.gz";
    fi

    tar fvxz "${GOMIGRATE_FILE}.tar.gz"
    mv ./migrate /usr/bin/migrate
    chmod +x /usr/bin/migrate

    #
    # Install Mockery
    #
    MOCKERY_LATEST_TAG_URL="https://api.github.com/repos/vektra/mockery/releases/latest"
    if [ "x" != "x${HTTPS_PROXY}" ]; then
        MOCKERY_TAG="$(curl -x ${HTTPS_PROXY} -sL ${MOCKERY_LATEST_TAG_URL} | jq -r '.tag_name')";
    else
        MOCKERY_TAG="$(curl -sL ${MOCKERY_LATEST_TAG_URL} | jq -r '.tag_name')";
    fi

    MOCKERY_VERSION="${MOCKERY_TAG#v}"
    MOCKERY_BIN_URL_PREFIX="https://github.com/vektra/mockery/releases/download/${MOCKERY_TAG}"
    if [ "$(uname -m)" = "x86_64" ]; then
        MOCKERY_BIN_URL="${MOCKERY_BIN_URL_PREFIX}/mockery_${MOCKERY_VERSION}_Linux_x86_64.tar.gz";
        MOCKERY_BIN_FILE="mockery_${MOCKERY_VERSION}_Linux_x86_64";
    else
        MOCKERY_BIN_URL="${MOCKERY_BIN_URL_PREFIX}/mockery_${MOCKERY_VERSION}_Linux_arm64.tar.gz";
        MOCKERY_BIN_FILE="mockery_${MOCKERY_VERSION}_Linux_arm64";
    fi

    if [ "x" != "x${HTTPS_PROXY}" ]; then
        curl -x "${HTTPS_PROXY}" -o "${MOCKERY_BIN_FILE}.tar.gz" -L "${MOCKERY_BIN_URL}";
    else
        curl -o "${MOCKERY_BIN_FILE}.tar.gz" -L "${MOCKERY_BIN_URL}";
    fi

    tar -zxvf "${MOCKERY_BIN_FILE}.tar.gz"
    mv ./mockery "$(go env GOPATH)/bin/mockery"
    chmod +x "$(go env GOPATH)/bin/mockery"

    #
    # Install golangci-lint
    #
    GOLANGCI_LINT_INSTALL_SHELL="https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh"
    if [ "x" != "x${HTTPS_PROXY}" ]; then
        curl -x "${HTTPS_PROXY}" -L "${GOLANGCI_LINT_INSTALL_SHELL}" \
        | sh -s -- -b "$(go env GOPATH)/bin";
    else
        curl -L "${GOLANGCI_LINT_INSTALL_SHELL}" \
        | sh -s -- -b "$(go env GOPATH)/bin";
    fi

    #
    # Install go tools
    #
    go install github.com/cweill/gotests/gotests@latest
    go install github.com/fatih/gomodifytags@latest
    go install github.com/go-delve/delve/cmd/dlv@latest
    go install github.com/golang/mock/mockgen@latest
    go install github.com/haya14busa/goplay/cmd/goplay@latest
    go install github.com/josharian/impl@latest
    go install github.com/ramya-rao-a/go-outline@latest
    go install github.com/uudashr/gopkgs/v2/cmd/gopkgs@latest
    go install golang.org/x/tools/cmd/godoc@latest
    go install golang.org/x/tools/cmd/goimports@latest
    go install golang.org/x/tools/gopls@latest

    #
    # Change owner
    #
    chown -R golang:golang "${WORK_DIR}" /home/golang

    #
    # Cleanup
    #
    rm -rf \
        /tmp/* \
        /var/cache/apt/* \
        "${WORK_DIR}/pkg/"* \
        "${WORK_DIR}/src/"*
EOF

USER golang

#
# Build app files.
#
FROM base as builder

ARG APP_VERSION
ARG GITHUB_TOKEN
ARG GITHUB_REPO_BASE="https://x-access-token:${GITHUB_TOKEN}@github.com"
ARG GITHUB_ORG="mythrnr"
ARG GITHUB_REPO="template-pj-golang"
ARG HTTP_PROXY
ARG HTTPS_PROXY
ARG SOURCE_COMMIT
ARG WORK_DIR="/go/src/github.com"

WORKDIR ${WORK_DIR}

USER root

RUN <<EOF
    set -eux
    chown -R golang:golang ${WORK_DIR}
EOF

USER golang

RUN <<EOF
    : "${GITHUB_TOKEN:?GITHUB_TOKEN is required.}"
    : "${APP_VERSION:?APP_VERSION is required.}"
    set -eux

    git config --global url."${GITHUB_REPO_BASE}".insteadOf "https://github.com"
    mkdir "${GITHUB_ORG}"
    cd "${GITHUB_ORG}"
    git clone "${GITHUB_REPO_BASE}/${GITHUB_ORG}/${GITHUB_REPO}.git"
    cd "${GITHUB_REPO}"
    git checkout "$(git rev-parse ${APP_VERSION})"
    sh scripts/build.sh
EOF

#
# Build image for Application.
#
FROM gcr.io/distroless/base

USER root

COPY --from=builder --chown=nonroot:nonroot \
    /go/src/github.com/mythrnr/template-pj-golang/bin/app \
    /app

USER nonroot

CMD [ "/bin/app", "serve" ]

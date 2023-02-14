# syntax=docker/dockerfile:1
FROM golang:1.19 as base

ARG HTTP_PROXY
ARG HTTPS_PROXY
ARG WORK_DIR="/go"

WORKDIR ${WORK_DIR}

RUN <<EOF
    set -eux

    #
    # Install and update packages
    #
    apt-get update
    apt-get upgrade
    apt-get install -y \
        autoconf \
        inotify-tools \
        jq \
        libtool \
        socat \
        upx

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
        ${WORK_DIR}/bin \
        ${WORK_DIR}/pkg \
        ${WORK_DIR}/src

    cd /tmp

    #
    # Install Mockery
    #
    MOCKERY_LATEST_TAG_URL="https://api.github.com/repos/vektra/mockery/releases/latest"
    if [ "x" != "x${HTTPS_PROXY}" ]; then
        MOCKERY_TAG=`curl -x ${HTTPS_PROXY} -sL ${MOCKERY_LATEST_TAG_URL} | jq -r '.tag_name'`;
    else
        MOCKERY_TAG=`curl -sL ${MOCKERY_LATEST_TAG_URL} | jq -r '.tag_name'`;
    fi

    MOCKERY_VERSION="${MOCKERY_TAG#v}"
    MOCKERY_BIN_URL_PREFIX="https://github.com/vektra/mockery/releases/download/${MOCKERY_TAG}"
    if [ `uname -m` = "x86_64" ]; then
        MOCKERY_BIN_URL="${MOCKERY_BIN_URL_PREFIX}/mockery_${MOCKERY_VERSION}_Linux_x86_64.tar.gz";
        MOCKERY_BIN_FILE="mockery_${MOCKERY_VERSION}_Linux_x86_64";
    else
        MOCKERY_BIN_URL="${MOCKERY_BIN_URL_PREFIX}/mockery_${MOCKERY_VERSION}_Linux_arm64.tar.gz";
        MOCKERY_BIN_FILE="mockery_${MOCKERY_VERSION}_Linux_arm64";
    fi

    if [ "x" != "x${HTTPS_PROXY}" ]; then
        curl -x ${HTTPS_PROXY} -o ${MOCKERY_BIN_FILE}.tar.gz -L ${MOCKERY_BIN_URL};
    else
        curl -o ${MOCKERY_BIN_FILE}.tar.gz -L ${MOCKERY_BIN_URL};
    fi

    tar -zxvf ${MOCKERY_BIN_FILE}.tar.gz
    mv ./mockery $(go env GOPATH)/bin/mockery
    chmod +x $(go env GOPATH)/bin/mockery

    #
    # Install golangci-lint
    #
    GOLANGCI_LINT_INSTALL_SHELL="https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh"
    if [ "x" != "x${HTTPS_PROXY}" ]; then
        curl -x ${HTTPS_PROXY} -L ${GOLANGCI_LINT_INSTALL_SHELL} \
        | sh -s -- -b $(go env GOPATH)/bin;
    else
        curl -L ${GOLANGCI_LINT_INSTALL_SHELL} \
        | sh -s -- -b $(go env GOPATH)/bin;
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
    chown -R golang:golang ${WORK_DIR} /home/golang

    #
    # Cleanup
    #
    rm -rf \
        /tmp/* \
        /var/cache/apt/* \
        ${WORK_DIR}/pkg/* \
        ${WORK_DIR}/src/*
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
    mkdir ${GITHUB_ORG}
    cd ${GITHUB_ORG}
    git clone ${GITHUB_REPO_BASE}/${GITHUB_ORG}/${GITHUB_REPO}.git
    cd ${GITHUB_REPO}
    git checkout `git rev-parse ${APP_VERSION}`
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

#
# Prepare image to develop.
#
FROM golang:1.17 as base

ARG GOLANGCI_LINT_VERSION=""
ARG GOLANGCI_LINT_INSTALL_SHELL="https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh"
ARG MOCKERY_VERSION="2.9.4"
ARG MOCKERY_BIN_URL_PREFIX="https://github.com/vektra/mockery/releases/download/v${MOCKERY_VERSION}"
ARG HTTP_PROXY
ARG HTTPS_PROXY
ARG INOTIFY_VERSION="3.22.1.0"
ARG WORK_DIR="/go"

ENV GO111MODULE="on"

WORKDIR ${WORK_DIR}

RUN set -x \
    && apt update \
    && apt upgrade \
    && apt install -y autoconf jq libtool socat upx \
    && cd /tmp \
    && curl -OL https://github.com/inotify-tools/inotify-tools/archive/refs/tags/${INOTIFY_VERSION}.tar.gz \
    && tar xzvf /tmp/${INOTIFY_VERSION}.tar.gz \
    && cd inotify-tools-${INOTIFY_VERSION} \
    && ./autogen.sh \
    && ./configure --prefix=/usr --libdir=/lib64 \
    && make \
    && make install \
    && addgroup golang \
    && adduser \
        --home /home/golang \
        --ingroup golang golang \
    && echo "alias ll='ls -ahl'" >> /home/golang/.profile \
    && chown -R golang:golang /home/golang \
    && rm -rf \
        /var/cache/apt/* \
        /tmp/*

RUN set -x \
    && mkdir -p \
        ${WORK_DIR}/bin \
        ${WORK_DIR}/pkg \
        ${WORK_DIR}/src \
    && cd /tmp \
    #
    # Install Mockery
    #
    && if [ `uname -m` = "x86_64" ]; then \
            export MOCKERY_BIN_URL="${MOCKERY_BIN_URL_PREFIX}/mockery_${MOCKERY_VERSION}_Linux_x86_64.tar.gz"; \
            export MOCKERY_BIN_FILE="mockery_${MOCKERY_VERSION}_Linux_x86_64"; \
        else \
            export MOCKERY_BIN_URL="${MOCKERY_BIN_URL_PREFIX}/mockery_${MOCKERY_VERSION}_Linux_arm64.tar.gz"; \
            export MOCKERY_BIN_FILE="mockery_${MOCKERY_VERSION}_Linux_arm64"; \
        fi \
    && if [ "x" != "x${HTTPS_PROXY}" ]; then \
            curl -x ${HTTPS_PROXY} -o ${MOCKERY_BIN_FILE}.tar.gz -L ${MOCKERY_BIN_URL}; \
        else \
            curl -o ${MOCKERY_BIN_FILE}.tar.gz -L ${MOCKERY_BIN_URL}; \
        fi \
    && tar -zxvf ${MOCKERY_BIN_FILE}.tar.gz \
    && ls -al \
    && mv ./mockery $(go env GOPATH)/bin/mockery \
    && chmod +x $(go env GOPATH)/bin/mockery \
    #
    # Install golangci-lint
    #
    && if [ "x" != "x${HTTPS_PROXY}" ]; then \
            curl -x ${HTTPS_PROXY} -L ${GOLANGCI_LINT_INSTALL_SHELL} \
            | sh -s -- -b $(go env GOPATH)/bin ${GOLANGCI_LINT_VERSION}; \
        else \
            curl -L ${GOLANGCI_LINT_INSTALL_SHELL} \
            | sh -s -- -b $(go env GOPATH)/bin ${GOLANGCI_LINT_VERSION}; \
        fi \
    #
    # Install go tools
    #
    && go install github.com/cweill/gotests/gotests@latest \
    && go install github.com/fatih/gomodifytags@latest \
    && go install github.com/go-delve/delve/cmd/dlv@latest \
    && go install github.com/golang/mock/mockgen@latest \
    && go install github.com/haya14busa/goplay/cmd/goplay@latest \
    && go install github.com/josharian/impl@latest \
    && go install github.com/ramya-rao-a/go-outline@latest \
    && go install github.com/uudashr/gopkgs/v2/cmd/gopkgs@latest \
    && go install golang.org/x/tools/cmd/godoc@latest \
    && go install golang.org/x/tools/cmd/goimports@latest \
    && go install golang.org/x/tools/gopls@latest \
    && chown -R golang:golang ${WORK_DIR} /home/golang \
    && rm -rf \
        /tmp/* \
        /var/cache/apt/* \
        ${WORK_DIR}/pkg/* \
        ${WORK_DIR}/src/*

#
# Build app files.
#
FROM base as builder

ARG APP_VERSION
ARG GITHUB_TOKEN
ARG GITHUB_BASE="https://${GITHUB_TOKEN}:x-oauth-basic@github.com"
ARG GITHUB_ORG="mythrnr"
ARG GITHUB_REPO="template-pj-golang"
ARG HTTP_PROXY
ARG HTTPS_PROXY
ARG SOURCE_COMMIT
ARG WORK_DIR="/go/src/github.com"

WORKDIR ${WORK_DIR}

USER root

RUN set -x && chown -R golang:golang ${WORK_DIR}

USER golang

RUN : "${GITHUB_TOKEN:?GITHUB_TOKEN is required.}" \
    && : "${APP_VERSION:?APP_VERSION is required.}" \
    && set -x \
    && git config --global url."${GITHUB_BASE}".insteadOf "https://github.com" \
    && mkdir ${GITHUB_ORG} \
    && cd ${GITHUB_ORG} \
    && git clone ${GITHUB_BASE}/${GITHUB_ORG}/${GITHUB_REPO}.git \
    && cd ${GITHUB_REPO} \
    && git checkout `git rev-parse ${APP_VERSION}` \
    && cd ${WORK_DIR}/${GITHUB_ORG}/${GITHUB_REPO} \
    && sh scripts/build.sh

#
# Build image for Application.
#
FROM gcr.io/distroless/base

USER root

COPY --from=builder --chown=nonroot:nonroot \
    /go/src/github.com/mythrnr/template-pj-golang/bin/app \
    /app

USER nonroot

CMD [ "/app", "serve" ]

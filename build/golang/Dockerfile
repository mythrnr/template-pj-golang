FROM golang:1.15-alpine as base

ARG HTTP_PROXY
ARG HTTPS_PROXY
ARG WORK_DIR="/go"
ENV GO111MODULE="on"

WORKDIR ${WORK_DIR}

RUN set -x \
    && apk update \
    && apk upgrade \
    && apk add --no-cache \
        g++ \
        gcc \
        git \
        make \
        openssh \
        shadow \
        socat \
        upx \
        wget \
    && addgroup -S golang \
    && adduser -D -S \
        -h /home/golang \
        -s /sbin/nologin \
        -G golang golang \
    && mkdir -p \
        ${WORK_DIR}/bin \
        ${WORK_DIR}/pkg \
        ${WORK_DIR}/src \
    && go get -v -u \
        github.com/golang/mock/mockgen \
        github.com/vektra/mockery/.../ \
        golang.org/x/tools/cmd/godoc \
    && go get github.com/golangci/golangci-lint/cmd/golangci-lint@v1.27.0 \
    && GO111MODULE="off" go get -v \
        github.com/oxequa/realize \
    && chown -R golang:golang ${WORK_DIR} \
    && rm -rf \
        /var/cache/apk/* \
        ${WORK_DIR}/pkg/* \
        ${WORK_DIR}/src/*

FROM base as builder

ARG APP_VERSION
ARG GITHUB_TOKEN
ARG GITHUB_REPO_BASE="https://${GITHUB_TOKEN}:x-oauth-basic@github.com/mythrnr"
ARG HTTP_PROXY
ARG HTTPS_PROXY
ARG SOURCE_COMMIT
ARG WORK_DIR="/go/src/github.com/mythrnr"

WORKDIR ${WORK_DIR}

USER root

RUN set -x && chown -R golang:golang ${WORK_DIR}

USER golang

RUN : "${GITHUB_TOKEN:?GITHUB_TOKEN is required.}" \
    && : "${APP_VERSION:?APP_VERSION is required.}" \
    && set -x \
    && git config --global url."${GITHUB_REPO_BASE}".insteadOf "https://github.com/mythrnr" \
    && git clone ${GITHUB_REPO_BASE}/template-pj-golang.git \
    && cd template-pj-golang \
    && git checkout `git rev-parse ${APP_VERSION}` \
    && cd cmd/cli/generator/version \
    && go generate \
    && cd ${WORK_DIR}/template-pj-golang \
    && sh scripts/build.sh

FROM alpine as executer

ARG HTTP_PROXY
ARG HTTPS_PROXY
ARG WORK_DIR="/go"
ARG ZONEINFO_FILE_LOCATION="/usr/local/go/lib/time/zoneinfo.zip"
ARG ZONEINFO_FILE_URL="https://github.com/golang/go/raw/master/lib/time/zoneinfo.zip"

WORKDIR ${WORK_DIR}

RUN set -x \
    && apk update \
    && apk upgrade \
    && apk add --no-cache \
        ca-certificates \
        curl \
    && addgroup -S golang \
    && adduser -D -S \
        -h /home/golang \
        -s /sbin/nologin \
        -G golang golang \
    && mkdir -p /usr/local/go/lib/time \
    && if [ "x" != "x${HTTPS_PROXY}" ]; then \
        curl -x ${HTTPS_PROXY} \
            -L -o ${ZONEINFO_FILE_LOCATION} \
            ${ZONEINFO_FILE_URL}; \
    else \
        curl -L -o ${ZONEINFO_FILE_LOCATION} \
            ${ZONEINFO_FILE_URL}; \
    fi \
    && apk del curl \
    && rm -f /var/cache/apk/* \
    && chown -R golang:golang ${WORK_DIR} \
    && chmod -R 700 ${WORK_DIR}

USER golang

FROM executer as app

ARG WORK_DIR="/go/src/github.com/mythrnr/template-pj-golang"

WORKDIR ${WORK_DIR}

USER root

COPY --from=builder --chown=golang:golang ${WORK_DIR}/bin/http ${WORK_DIR}/bin/http
COPY --from=builder --chown=golang:golang ${WORK_DIR}/configs/config.yml ${WORK_DIR}/configs/config.yml
COPY --from=builder --chown=golang:golang ${WORK_DIR}/configs/lang ${WORK_DIR}/configs/lang

USER golang

CMD [ "./bin/http/api" ]

FROM executer as cli

ARG WORK_DIR="/go/src/github.com/mythrnr/template-pj-golang"

WORKDIR ${WORK_DIR}

USER root

COPY --from=builder --chown=golang:golang ${WORK_DIR}/bin/cli ${WORK_DIR}/bin/cli
COPY --from=builder --chown=golang:golang ${WORK_DIR}/configs/config.yml ${WORK_DIR}/configs/config.yml
COPY --from=builder --chown=golang:golang ${WORK_DIR}/configs/lang ${WORK_DIR}/configs/lang

USER golang

CMD [ "./bin/cli/cli" ]

FROM golang:alpine

LABEL maintainer="benjamin.mccown@solera.com"

RUN adduser -D ansible

RUN echo "**** install Python ****" && \
    apk add --update python3 python3-dev build-base && \
    if [ ! -e /usr/bin/python ]; then ln -sf python3 /usr/bin/python ; fi && \
    \
    echo "**** install pip ****" && \
    python3 -m ensurepip && \
    rm -r /usr/lib/python*/ensurepip && \
    pip3 install --no-cache --upgrade pip setuptools wheel && \
    if [ ! -e /usr/bin/pip ]; then ln -s pip3 /usr/bin/pip ; fi

RUN echo "**** install utils ****" && \
    apk add --update openssh-client git bash openssl curl wget jq 

RUN echo "**** install gox ****" && \
    go get github.com/mitchellh/gox

RUN echo "**** install packer ****" && \
    go get github.com/hashicorp/packer

RUN echo "**** fetch latest vmware-clone/iso plugins for vmware ****" && \
    mkdir -p /home/ansible/.packer.d/plugins && \
    curl -s https://api.github.com/repos/jetbrains-infra/packer-builder-vsphere/releases/latest | jq -r '.assets[].browser_download_url' | grep linux | wget -qi - && \
    mv packer-builder-vsphere* /home/ansible/.packer.d/plugins && \
    chmod ogu+rx /home/ansible/.packer.d/plugins/packer-builder-vsphere*

RUN echo "**** install terraform ****" && \
    export GO111MODULE=on && \
    go get github.com/hashicorp/terraform@v0.12.20

RUN echo "**** install ansible ****" && \
    apk add --no-cache 'ansible<2.10.0'

RUN mkdir -p /usr/local/src
WORKDIR /usr/local/src

USER ansible

ENTRYPOINT ["/bin/sh", "-c"]


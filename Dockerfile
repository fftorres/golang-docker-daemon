FROM golang:1.8.3

LABEL maintainer "Vladimir Garvardt <vga@hellofresh.com>"

RUN apt-get update && \
    apt-get install -y apt-transport-https ca-certificates curl gnupg2 software-properties-common && \
    curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add - && \
    add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable" && \
    apt-get update && \
    sed -i "s/^exit 101$/exit 0/" /usr/sbin/policy-rc.d && \
    apt-get install -y docker-ce && \
    rm -rf /var/lib/apt/lists/*

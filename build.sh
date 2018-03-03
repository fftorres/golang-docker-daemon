#!/bin/sh

FROM=`head -n1 Dockerfile`
GOVERSION=`sed "s/FROM golang\://g" <<< ${FROM}`
DATE=`date "+%Y%m%d"`
docker build -t quay.io/hellofresh/golang-docker-daemon:${GOVERSION}-${DATE} .

echo "\`\`\`" > go-version.md
docker run -it --privileged quay.io/hellofresh/golang-docker-daemon:${GOVERSION}-${DATE} go version >> go-version.md
echo "\`\`\`" >> go-version.md

echo "\`\`\`" > docker-version.md
docker run -it --privileged quay.io/hellofresh/golang-docker-daemon:${GOVERSION}-${DATE} docker version >> docker-version.md
echo "\`\`\`" >> docker-version.md

if [ "$1" = "push" ]; then
    # push tag
    docker push quay.io/hellofresh/golang-docker-daemon:${GOVERSION}-${DATE}
    # push latest
    docker tag quay.io/hellofresh/golang-docker-daemon:${GOVERSION}-${DATE} quay.io/hellofresh/golang-docker-daemon:latest
    docker push quay.io/hellofresh/golang-docker-daemon:latest
fi

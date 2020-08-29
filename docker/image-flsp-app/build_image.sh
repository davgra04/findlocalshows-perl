#!/bin/bash

IMAGE_NAME=flsp-app
VERSION=`git describe --abbrev=0 --tags`
LATEST_VERSION=`git describe --tags \`git rev-list --tags --max-count=1\``

# copy source to local dir
cp -r ../../webapp/ ./webapp

# build image
if [ ${VERSION} == ${LATEST_VERSION} ]; then
    docker build -t ${IMAGE_NAME}:${VERSION} -t ${IMAGE_NAME}:latest .
else
    docker build -t ${IMAGE_NAME}:${VERSION} .
fi

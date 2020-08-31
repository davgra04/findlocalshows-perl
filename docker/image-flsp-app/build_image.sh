#!/bin/bash

IMAGE_NAME=flsp-app
VERSION=`git describe --abbrev=0 --tags`
LATEST_VERSION=`git describe --tags \`git rev-list --tags --max-count=1\``

set -x
# copy source to local dir
rm -rf flsp-app
cp -r ../../flsp-app ./flsp-app

# build image
if [ ${VERSION} == ${LATEST_VERSION} ]; then
    docker build -t ${IMAGE_NAME}:${VERSION} -t ${IMAGE_NAME}:latest .
else
    docker build -t ${IMAGE_NAME}:${VERSION} .
fi

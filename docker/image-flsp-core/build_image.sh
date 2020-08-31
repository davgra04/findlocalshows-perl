#!/bin/bash

IMAGE_NAME=flsp-core
VERSION=`git describe --abbrev=0 --tags`
LATEST_VERSION=`git describe --tags \`git rev-list --tags --max-count=1\``

set -x
# copy source to local dir
rm -rf flsp-core
cp -r ../../flsp-core ./flsp-core

# build image
if [ ${VERSION} == ${LATEST_VERSION} ]; then
    docker build -t ${IMAGE_NAME}:${VERSION} -t ${IMAGE_NAME}:latest .
else
    docker build -t ${IMAGE_NAME}:${VERSION} .
fi

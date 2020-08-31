#!/bin/bash

IMAGE_NAME=flsp-db
VERSION=`git describe --abbrev=0 --tags`
LATEST_VERSION=`git describe --tags \`git rev-list --tags --max-count=1\``

# bring in schema.sql
cp ../../sql/schema.sql .

# build image
if [ ${VERSION} == ${LATEST_VERSION} ]; then
    docker build -t ${IMAGE_NAME}:${VERSION} -t ${IMAGE_NAME}:latest .
else
    docker build -t ${IMAGE_NAME}:${VERSION} .
fi

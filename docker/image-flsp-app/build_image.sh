#!/bin/bash

IMAGE_NAME=flsp-app
VERSION=`git describe --abbrev=0 --tags`
LATEST_VERSION=`git describe --tags \`git rev-list --tags --max-count=1\``

# copy source to local dir
rm -rf findlocalshows-perl
mkdir findlocalshows-perl
cp -R ../../lib ./findlocalshows-perl/lib
cp -R ../../public ./findlocalshows-perl/public
cp -R ../../script ./findlocalshows-perl/script
cp -R ../../t ./findlocalshows-perl/t
cp -R ../../templates ./findlocalshows-perl/templates

# build image
if [ ${VERSION} == ${LATEST_VERSION} ]; then
    docker build -t ${IMAGE_NAME}:${VERSION} -t ${IMAGE_NAME}:latest .
else
    docker build -t ${IMAGE_NAME}:${VERSION} .
fi

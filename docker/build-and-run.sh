#!/bin/bash
# convenience script to rebuild docker images and run docker-compose

HDG_SEP="################################################################################"

heading() {
    # echo -n -e "\e[31m"
    echo -n $(tput setaf 6)
    echo "$HDG_SEP"
    echo "# $1"
    echo -n "$HDG_SEP"
    # echo -n -e "\e[0m"
    echo $(tput sgr0)
}

build_app() {
    heading "building app"
    (cd image-flsp-app && bash build_image.sh)
}

build_db() {
    heading "building db"
    (cd image-flsp-db && bash build_image.sh)
}

failed() {
    echo "failed build"
    exit
}

if [ "$1" == "none" ]; then
    :
elif [ "$1" == "app" ]; then
    build_app || failed
elif [ "$1" == "db" ]; then
    build_db || failed
else
    build_app || failed
    build_db || failed
fi

heading "running docker-compose"
docker-compose -f docker-compose.dgserv3.flsp.yaml up



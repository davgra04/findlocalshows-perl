#!/bin/bash

while true
do
    perl flsp-core.pl
    echo "Restarting flsp-core.pl"
    sleep 5
done

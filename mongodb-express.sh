#!/bin/bash

MONGODB_SERVICE_NAME="mongodb-server"

SERVICE_IMAGE="mongo-express:0.30"
SERVICE_NAME="mongo-express"
SERVICE_STATUS=$(docker ps -a --format "{{.Names}} {{.Status}}" | grep "^$SERVICE_NAME " | cut -d " " -f 2 | awk '{print tolower($0)}')

if [[ -z $SERVICE_STATUS ]] ; then
    echo "Service doesn't exist, creating...";
    docker run \
        --detach \
        --name $SERVICE_NAME \
        --link $MONGODB_SERVICE_NAME:mongo \
        --publish 8081:8081 \
        $SERVICE_IMAGE

    echo "Service should now be running..."
    docker ps | grep $SERVICE_NAME
elif [[ $SERVICE_STATUS == "exited" ]] ; then
    echo "Service stopped, restarting...";
    docker start $SERVICE_NAME
elif [[ $SERVICE_STATUS == "up" ]] ; then
    echo "Service already running";
    docker ps | grep $SERVICE_NAME
fi

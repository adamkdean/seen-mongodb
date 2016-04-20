#!/bin/bash

SERVICE_IMAGE="mongo:3.2"
SERVICE_NAME="mongodb-server"
SERVICE_STATUS=$(docker ps -a --format "{{.Names}} {{.Status}}" | grep "^$SERVICE_NAME " | cut -d " " -f 2 | awk '{print tolower($0)}')

if [[ -z $SERVICE_STATUS ]] ; then
    echo "Service doesn't exist, creating...";

    VOLUME_NAME="mongodb-data"
    VOLUME_PATH="/data/db"
    VOLUME_EXISTS=$(docker volume ls -q | grep "^$VOLUME_NAME$" | wc -l | tr -d ' ')

    if [[ $VOLUME_EXISTS = 0 ]] ; then
        echo "Data volume doesn't exists...creating it"
        docker volume create --name=$VOLUME_NAME
    fi

    docker run \
        --detach \
        --name $SERVICE_NAME \
        --volume $VOLUME_NAME:$VOLUME_PATH \
        --publish 27017:27017 \
        $SERVICE_IMAGE \
            --noprealloc \
            --smallfiles

    echo "Service should now be running..."
    docker ps | grep $SERVICE_NAME
elif [[ $SERVICE_STATUS == "exited" ]] ; then
    echo "Service stopped, restarting...";
    docker start $SERVICE_NAME
elif [[ $SERVICE_STATUS == "up" ]] ; then
    echo "Service already running";
    docker ps | grep $SERVICE_NAME
fi

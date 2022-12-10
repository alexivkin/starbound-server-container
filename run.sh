#!/bin/bash

set -euo pipefail

if [[ $# -eq 0 ]]; then
    echo "Give me the name of the server .env file. Use -f option to run in the foreground mode"
    exit 0
fi
# choose interactive (foreground) or server (background) docker options
if [[ $# -eq 2 && $2 == "-f" ]]; then
    runopt="-it --rm"
elif [[ $# -eq 2 && $2 == "-d" ]]; then # debug (drop to shell
    runopt="-it --rm --entrypoint sh"
else
    # run with -i so the STDIO remains attached, but without -t so commands can be piped (a pipe is not a TTY)
    runopt="-d --restart unless-stopped -i"
fi

# Check if the container is already running, then stop/remove it
check_and_stop() {
    container=$1
    #echo Checking for $container
    if [ "$(docker ps -aq -f name="$container\$")" ]; then
        if [ "$(docker ps -aq -f status=exited -f name="$container\$")" ]; then # if [ $(docker inspect -f '{{.State.Running}}' backend) = "true" ]; then
            echo "Removing $container"
            docker rm $container
        else
            # handle running and restarting containers
            echo "Stopping and removing $container"
            docker stop $container
            docker rm $container
        fi
    fi
}

CONFIG=$1 #"$NAME.env"
NAME=${CONFIG%%.*}

# sanity checks
if [[ ! -f $CONFIG ]]; then
    echo "Missing configuration file $CONFIG. It's a bash env file settings."
    exit 1
fi

# source all the configs now, including version
. $CONFIG

if ! docker images -q alexivkin/starbound-server:$VER | grep . >/dev/null; then
    docker pull alexivkin/starbound-server:$VER || true
    if ! docker images -q alexivkin/starbound-server:$VER | grep . >/dev/null; then
       echo "Missing server image for $VER. Building..."
       docker build -t alexivkin/starbound-server:$VER buildcontext
    fi
fi

# pre-create the folder so docker does not create it as root
mkdir -p $(pwd)/universe-$NAME/storage
mkdir -p $(pwd)/universe-$NAME/mods

# cant use --env-file $CONFIG - does not support multiline envs

check_and_stop starbound-server-$NAME

docker run $runopt --name starbound-server-$NAME -p $PORT:21025 -v $(pwd)/universe-$NAME/storage/:/game/storage/ -v $(pwd)/universe-$NAME/mods/:/game/mods/ alexivkin/starbound-server:$VER

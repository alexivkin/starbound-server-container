#!/bin/bash

# on callback, kill the last background process, which is `tail -f /dev/null` and start the server shutdown
trap 'kill ${!}; server_shutdown' SIGTERM

function server_shutdown() {
    echo "Stopping Starbound server..."
    echo exit  > /in
    # Waiting for it to finish saving
    # cant use "wait" command here because it's not owned by this shell
    pid=$(pgrep -f ^/game/linux/starbound_server)
    if [ -z "$pid" ]; then exit 1; fi
    while [ -e /proc/$pid ]; do
        sleep 1
    done
    echo "done"
    exit 0
}

# fifo is not required, because one can write to /proc/$pid/fd/0 but it makes scripts simpler
mkfifo /in
# run Starbound as the second service
echo "Starting Starbound server..."
# tail to provide stdin for the server, otherwise it will not start
# nohup around the pipe to disown it from process 1 to protect it from being killed by tail processing the SIGTERM from the docker stop command
# subshell works too
( tail -f /in | /game/linux/starbound_server ) &
#nohup sh -c 'tail -f in | /game/linux/starbound_server -config /server.txt' &

# low load sleep forever. Single ampersand allows both comamnds to execute at the same time, without waiting for the tail to finish (which it will not)
# 'wait' is here to handle the incoming process signals
# if you want to terminate container when server crashes comment out the forever wait line below.
tail -f /dev/null & wait ${!}
# could also wait on a stopped process like this
#while :; do :; done & kill -STOP $! && wait $!

pid=$(pgrep -f ^/game/linux/starbound_server)
if [ -z "$pid" ]; then exit 1; fi
while [ -e /proc/$pid ]; do
   sleep 5
done

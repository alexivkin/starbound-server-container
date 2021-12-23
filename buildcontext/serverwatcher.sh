#!/bin/bash

#!/bin/bash

trap 'server_shutdown' SIGTERM

function server_shutdown() {
    echo "Stopping Starbound server..."
    echo exit  > /in
    pid=$(pgrep -f ^/game/linux/starbound_server)
    if [ -z "$pid" ]; then echo "Already stopped"; exit 1; fi
    # Wait for it to finish saving and exit
    while [ -e /proc/$pid ]; do
        sleep 1
    done
    echo "done"
    exit 0
}

# creating a named pipe, so java does not close stdin when moved to the background
mkfifo /in
# block the pipe, so it's open forever
sleep 100000d > /in &
# run terraria as the second service
echo "Starting Starbound server..."
# move to background so we can monitor for SIGTERM in this shell
/game/linux/starbound_server < /in &
# Halt while the server is alive
pid=$(pgrep -f ^/game/linux/starbound_server)
if [ -z "$pid" ]; then echo "Starbound server did not start!"; exit 1; fi
wait $pid

# Starbound server in a docker container

A Starbound server launcher with the following features:

* supports running multiple servers at the same time and servers with mods
* running in a docker container, fully isolated from the host
* performing a graceful stop/shutdown correctly, saving the world data before existing
* automatically restarting the server if it crashes

### Building

Copy the "game" folder from the game into the buildcontext folder. Then use `run.sh` as shown below. It will notice that the image is missing and will build it before starting the server.

### Running

Create a file with a name of your server and extension `.env` using the `server.env.example` as an example. Then run

`./run.sh <server_name>.env [-f|-d]`

* `-f` will run the server in the foreground
* `-d` will drop into an interactive shell rather than starting the server

The universe and the server configuration is mapped to the `storage` and `mods` folders under `universe-$SERVER_NAME`.

* To stop use `docker stop starbound-server-$NAME`
* To restart the server simply use `./run.sh` again
* To check the logs run `docker logs starbound-server-$NAME`

If the server crashes for whatever reason the docker container will keep running. This is so you can see the logs from the crash.
If you want to terminate the container when the server crashes, then comment out the forever wait loop in the `serverwatcher.sh` under the `buildcontext`

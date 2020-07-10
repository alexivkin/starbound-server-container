# Starbound server in a docker container

Allows graceful shutdown by issuing the `exit` command to the server when the docker container is stopped,

* Building

You need to copy the "game" folder from the game into the buildcontext folder. Then run

	docker build -t alexivkin/starbound-server buildcontext

* Running

Start by running `./run.sh`. The universe and the server configuration is mapped to the `storage` folder.

* Checking

Run `docker logs starbound-server`

* Known issues

If the server crashes for whatever reason the docker container will keep running. This is so you can see the logs from the crash.
if you want to terminate container when server crashes comment out the forever wait loop in the `serverwatcher.sh`

#!/bin/bash

# start in the background with interaction for sending commands
docker run -d --restart unless-stopped --name starbound-server -p 21025:21025 -v $PWD/storage/:/game/storage/ alexivkin/starbound-server

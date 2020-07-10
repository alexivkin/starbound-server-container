FROM ubuntu

COPY game /game/
COPY serverwatcher.sh /

WORKDIR /game/linux/

ENTRYPOINT ["/serverwatcher.sh"]
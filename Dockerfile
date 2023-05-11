# JRE base
FROM openjdk:17-slim

ARG MC_MOTD=A Minecraft Server
ARG MC_DIFFICULTY=easy
ARG MC_RESOURCE_PACK
ARG MC_RESOURCE_PACK_SHA1
ARG MC_FORCE_GAMEMODE=false

# Environment variables
ENV MC_VERSION="latest" \
    PAPER_BUILD="latest" \
    MC_RAM="" \
    JAVA_OPTS=""

ENV MC_MOTD=$MC_MOTD \
    MC_DIFFICULTY=$MC_DIFFICULTY \
    MC_RESOURCE_PACK=$MC_RESOURCE_PACK \
    MC_RESOURCE_PACK_SHA1=$MC_RESOURCE_PACK_SHA1 \
    MC_FORCE_GAMEMODE=$MC_FORCE_GAMEMODE

COPY papermc.sh .
RUN apt-get update \
    && apt-get install -y wget \
    && apt-get install -y jq \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir /papermc

# Start script
CMD ["sh", "./papermc.sh"]

# Container setup
EXPOSE 25565/tcp
EXPOSE 25565/udp
VOLUME /papermc

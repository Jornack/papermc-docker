# JRE base
FROM openjdk:17-slim

ARG MC_VERSION=latest \
    PAPER_BUILD=latest \
    MC_RAM \
    JAVA_OPTS

# Environment variables
ENV MC_VERSION=$MC_VERSION \
    PAPER_BUILD=$PAPER_BUILD \
    MC_RAM=$MC_RAM \
    JAVA_OPTS=$JAVA_OPTS

ENV MC_MOTD="A Minecraft Server" \
    MC_BACKUP_ON_STARTUP=$MC_BACKUP_ON_STARTUP \
    MC_DEBUG=$MC_DEBUG \
    MC_STOP_ON_ERROR=$MC_STOP_ON_ERROR \
    MC_GAMEMODE=$MC_GAMEMODE \
    MC_DIFFICULTY=$MC_DIFFICULTY \
    MC_RESOURCE_PACK=$MC_RESOURCE_PACK \
    MC_RESOURCE_PACK_SHA1=$MC_RESOURCE_PACK_SHA1 \
    MC_FORCE_GAMEMODE=$MC_FORCE_GAMEMODE \
    MC_LEVEL_NAME=$MC_LEVEL_NAME \
    MC_SEED=$MC_SEED \
    MC_OPS_JSON=$MC_OPS_JSON \
    MC_WHITELIST_JSON=$MC_WHITELIST_JSON \
    MC_MAX_PLAYERS=20

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

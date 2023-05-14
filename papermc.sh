#!/bin/bash
if [ "${MC_DEBUG}" = "true" ];
then
  set -x
fi
if [ "${MC_STOP_ON_ERROR}" = "true" ];
then
  set -e
fi

# Enter server directory
cd papermc

# Show variables
echo "MC_VERSION=${MC_VERSION}"
echo "PAPER_BUILD=${PAPER_BUILD}"
echo "MC_RAM=${MC_RAM}"
echo "MC_MOTD=${MC_MOTD}"
echo "MC_BACKUP_ON_STARTUP=${MC_BACKUP_ON_STARTUP}"
echo "MC_GAMEMODE=${MC_GAMEMODE}"
echo "MC_DIFFICULTY=${MC_DIFFICULTY}"
echo "MC_RESOURCE_PACK=${MC_RESOURCE_PACK}"
echo "MC_RESOURCE_PACK_SHA1=${MC_RESOURCE_PACK_SHA1}"
echo "MC_FORCE_GAMEMODE=${MC_FORCE_GAMEMODE}"
echo "MC_LEVEL_NAME=${MC_LEVEL_NAME}"
echo "MC_SEED=${MC_SEED}"
echo "MC_OPS_JSON=${MC_OPS_JSON}"
echo "MC_WHITELIST_JSON=${MC_WHITELIST_JSON}"
echo "MC_MAX_PLAYERS=${MC_MAX_PLAYERS}"

# Get version information and build download URL and jar name
URL=https://papermc.io/api/v2/projects/paper
if [ ${MC_VERSION} = latest ]
then
  # Get the latest MC version
  MC_VERSION=$(wget -qO - $URL | jq -r '.versions[-1]') # "-r" is needed because the output has quotes otherwise
fi
URL=${URL}/versions/${MC_VERSION}
if [ ${PAPER_BUILD} = latest ]
then
  # Get the latest build
  PAPER_BUILD=$(wget -qO - $URL | jq '.builds[-1]')
fi
JAR_NAME=paper-${MC_VERSION}-${PAPER_BUILD}.jar
URL=${URL}/builds/${PAPER_BUILD}/downloads/${JAR_NAME}

# Backup on startup
if [ "${MC_BACKUP_ON_STARTUP}" = "true" ];
then
  TODAY=$(date +"%d-%m-%Y-%H-%M-%S")
  BACKUP_DIR=backup
  if [ ! -d "${BACKUP_DIR}" ];
  then
    mkdir "${BACKUP_DIR}"
  fi
  BACKUP_FILENAME="${BACKUP_DIR}/${MC_LEVEL_NAME}.${TODAY}.tar.gz"
  echo "Creating backup : ${BACKUP_FILENAME}"
  tar --exclude="${BACKUP_DIR}" -czf "${BACKUP_FILENAME}" *
fi

# Update if necessary
if [ ! -e ${JAR_NAME} ]
then
  # Remove old server jar(s)
  rm -f *.jar
  # Download new server jar
  wget ${URL} -O ${JAR_NAME}
  
fi

# If this is the first run, accept the EULA
if [ ! -e eula.txt ]
then
  # Run the server once to generate eula.txt
  java -jar ${JAR_NAME}
  # Edit eula.txt to accept the EULA
fi
sed -i 's/false/true/g' eula.txt

# Add RAM options to Java options if necessary
if [ ! -z "${MC_RAM}" ]
then
  JAVA_OPTS="-Xms${MC_RAM} -Xmx${MC_RAM} ${JAVA_OPTS}"
fi

# Generate Seed based on epoch if not provided
if [ -z "${MC_SEED}" ];
then
  MC_SEED="$(date +%s)"
fi
echo "Using seed: ${MC_SEED}"

# Configure server.properties
sed -i "s/^motd=.*/motd=${MC_MOTD}/" server.properties
sed -i "s/^gamemode=.*/gamemode=${MC_GAMEMODE}/" server.properties
sed -i "s/^difficulty=.*/difficulty=${MC_DIFFICULTY}/" server.properties
sed -i "s/^resource-pack=.*/resource-pack=${MC_RESOURCE_PACK}/" server.properties
sed -i "s/^resource-pack-sha1=.*/resource-pack-sha1=${MC_RESOURCE_PACK_SHA1}/" server.properties
sed -i "s/^force-gamemode=.*/force-gamemode=${MC_FORCE_GAMEMODE}/" server.properties
sed -i "s/^level-name=.*/level-name=${MC_LEVEL_NAME}/" server.properties
sed -i "s/^level-seed=.*/level-seed=${MC_SEED}/" server.properties
sed -i "s/^max-players=.*/max-players=${MC_MAX_PLAYERS}/" server.properties

# ops.json
if [ ! -z "${MC_OPS_JSON}" ];
then
  echo 'Setting ops.json'
  echo "${MC_OPS_JSON}" > ops.json
fi

# whitelist.json
if [ ! -z "${MC_WHITELIST_JSON}" ];
then
  echo 'Setting whitelisti.json'
  echo "${MC_WHITELIST_JSON}" > whitelist.json
fi

# Start server
exec java -server ${JAVA_OPTS} -jar ${JAR_NAME} nogui

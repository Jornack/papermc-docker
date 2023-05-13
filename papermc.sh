#!/bin/bash
# set -x
# Enter server directory
cd papermc

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

# Reset all the things
if [ "${MC_RESET_ALL_THE_THINGS}" = "yes" ];
then
  TODAY=$(date +"%d-%m-%Y")
  BACKUP_FILENAME="/tmp/${MC_LEVEL_NAME}.${TODAY}.tar.gz"
  echo "Creating backup : ${BACKUP_FILENAME}"
  tar czf "${BACKUP_FILENAME}" *
  rm -Rf *
  mv "${BACKUP_FILENAME}" .
  echo 'Reset all the things'
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

if [ -z "${MC_SEED}" ];
then
  MC_SEED="$(date +%s)"
fi
# Configure server
echo "MC_MOTD=${MC_MOTD}"
echo "MC_GAMEMODE=${MC_GAMEMODE}"
echo "MC_DIFFICULTY=${MC_DIFFICULTY}"
echo "MC_RESOURCE_PACK=${MC_RESOURCE_PACK}"
echo "MC_RESOURCE_PACK_SHA1=${MC_RESOURCE_PACK_SHA1}"
echo "MC_FORCE_GAMEMODE=${MC_FORCE_GAMEMODE}"
echo "MC_RESET_ALL_THE_THINGS=${MC_RESET_ALL_THE_THINGS}" 
echo "MC_LEVEL_NAME=${MC_LEVEL_NAME}"
echo "MC_SEED=${MC_SEED}"

sed -i "s/^motd=.*/motd=${MC_MOTD}/" server.properties
sed -i "s/^gamemode=.*/gamemode=${MC_GAMEMODE}/" server.properties
sed -i "s/^difficulty=.*/difficulty=${MC_DIFFICULTY}/" server.properties
sed -i "s/^resource-pack=.*/resource-pack=${MC_RESOURCE_PACK}/" server.properties
sed -i "s/^resource-pack-sha1=.*/resource-pack-sha1=${MC_RESOURCE_PACK_SHA1}/" server.properties
sed -i "s/^force-gamemode=.*/force-gamemode=${MC_FORCE_GAMEMODE}/" server.properties
sed -i "s/^level-name=.*/level-name=${MC_LEVEL_NAME}/" server.properties
sed -i "s/^level-seed=.*/level-seed=${MC_SEED}/" server.properties

# Start server
exec java -server ${JAVA_OPTS} -jar ${JAR_NAME} nogui

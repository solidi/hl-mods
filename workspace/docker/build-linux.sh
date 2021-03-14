#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# docker image ls
# docker image rm <tag>
# docker stop $(docker ps -aq)
# docker rm $(docker ps -aq)
# docker run -ti -v $(pwd):/mnt ice-ubuntu-base bash

rm -f ../libs/cl_dlls/client.so
rm -f ../libs/dlls/ice.so
rm -f ../libs/dlls/gravebot.so

# --no-cache ?
docker build -t ice-ubuntu-base -f ../docker/Dockerfile.ubuntu .

cd ../src
docker build -t ice-ubuntu-game -f ../docker/Dockerfile.game .
docker run --rm ice-ubuntu-game cat /usr/local/linux/release/ice.so > ../libs/dlls/ice.so
docker run --rm ice-ubuntu-game cat /usr/local/linux/release/client.so > ../libs/cl_dlls/client.so

cd ../grave-bot-src
docker build -t ice-ubuntu-gravebot -f ../docker/Dockerfile.gravebot .
docker run --rm ice-ubuntu-gravebot cat /usr/local/grave-bot/dlls/Release/gravebot.so > ../libs/dlls/gravebot.so

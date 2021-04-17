#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# docker image ls
# docker image rm <tag>
# docker stop $(docker ps -aq)
# docker rm $(docker ps -aq)
# docker run -ti -v $(pwd):/mnt ice-ubuntu-base bash

#rm -f libs/cl_dlls/client.so
#rm -f libs/dlls/ice.so
#rm -f libs/dlls/gravebot.so

# --no-cache ?
#docker build -t ice-ubuntu-base -f docker/Dockerfile.ubuntu .
#docker build -t ice-ubuntu-game -f docker/Dockerfile.game src
#docker run --rm ice-ubuntu-game cat /usr/local/linux/release/ice.so > libs/dlls/ice.so
#docker run --rm ice-ubuntu-game cat /usr/local/linux/release/client.so > libs/cl_dlls/client.so
#docker build -t ice-ubuntu-gravebot -f docker/Dockerfile.gravebot grave-bot-src
#docker run --rm ice-ubuntu-gravebot cat /usr/local/grave-bot/dlls/Release/gravebot.so > libs/dlls/gravebot.so

# docker run -it \
#    -v $(pwd):/mnt \
#    --rm ice-ubuntu-base /bin/bash -c " \
#cd /mnt/src/linux; \
#make clean; \
#make hl; \
#make hl_cdll; \
#cd ../../grave-bot-src/dlls; \
#make clean; \
#make; \
#exit;"

cfg=release
while getopts c: flag
do
    case "${flag}" in
        c) cfg=${OPTARG};;
    esac
done

docker run -it \
    -v $(pwd):/mnt \
    --rm ice-ubuntu-base /bin/bash -c "cd mnt/; /mnt/build-linux.sh -c $cfg"

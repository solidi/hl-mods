#!/bin/bash

maxplayers=8
while getopts m: flag
do
    case "${flag}" in
        m) maxplayers=${OPTARG};;
    esac
done
echo "maxplayers is $maxplayers...";

cd /media/sf_hl-mods/workspace
./build-linux.sh
cd /media/sf_hl-mods/workspace

rm -r  ~/.steam/debian-installation/steamapps/common/Half-Life/iceg/
rm -r  ~/.steam/debian-installation/steamapps/common/Half-Life/iceg_hd/
cp -a redist/. ~/.steam/debian-installation/steamapps/common/Half-Life/iceg/
cp -a redist_hd/. ~/.steam/debian-installation/steamapps/common/Half-Life/iceg_hd/

cd ~/.steam/debian-installation/steamapps/common/Half-Life/
chgrp -R surreal iceg/
chgrp -R surreal iceg_hd/
chmod 775 -R iceg/
chmod 775 -R iceg_hd/

# export LD_LIBRARY_PATH=.
# /home/surreal/.steam/debian-installation/steamapps/common/Half-Life/hl_linux -steam -console -dev -condebug -game iceg -windowed -gl -w 640 -h 480 +developer 2 +log on +sv_lan 1 +map stalkyard +deathmatch 1 +maxplayers 8 -windowed

steam steam://rungameid/70//-console%20-dev%20-condebug%20-game%20iceg%20-windowed%20-gl%20-w%20640%20-h%20480%20+developer%202%20+log%20on%20+sv_lan%201%20+map%20stalkyard%20+deathmatch%201%20+maxplayers%20${maxplayers}
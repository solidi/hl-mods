#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

icefolder=ice_beta2
maxplayers=16
hiDef=1
while getopts "mh:" flag
do
    case "${flag}" in
        m) maxplayers=${OPTARG};;
        h) hiDef=${OPTARG};;
    esac
done
echo "maxplayers is $maxplayers...";
echo "hi-def models is $hiDef...";

function doCopy() {
    echo 'Copying so libs to redist...'
    sudo cp libs/dlls/ice.so redist/dlls/
    sudo cp libs/dlls/gravebot.so redist/dlls/
    sudo cp libs/cl_dlls/client.so redist/cl_dlls/

    rm -r  /root/.steam/debian-installation/steamapps/common/Half-Life/${icefolder}/
    rm -r  /root/.steam/debian-installation/steamapps/common/Half-Life/${icefolder}_hd/
    cp -a redist/. /root/.steam/debian-installation/steamapps/common/Half-Life/${icefolder}/
    cp -a redist_hd/. /root/.steam/debian-installation/steamapps/common/Half-Life/${icefolder}_hd/
}

doCopy

# cd /home/surreal/.steam/debian-installation/steamapps/common/Half-Life/
# chgrp -R surreal ${icefolder}/
# chgrp -R surreal ${icefolder}_hd/
# chmod 775 -R ${icefolder}/
# chmod 775 -R ${icefolder}_hd/

# export LD_LIBRARY_PATH=.
# /home/surreal/.steam/debian-installation/steamapps/common/Half-Life/hl_linux -steam -console -dev -condebug -game ${icefolder} -windowed -gl -w 640 -h 480 +developer 2 +log on +sv_lan 1 +map snowyard +deathmatch 1 +maxplayers 8 -windowed

/usr/games/steam steam://rungameid/70//-console%20-dev%20-condebug%20-game%20${icefolder}%20-windowed%20-gl%20-w%20640%20-h%20480%20+developer%202%20+log%20on%20+sv_lan%201%20+map%20snowyard%20+deathmatch%201%20+maxplayers%20${maxplayers}%20+_sethdmodels%20${hiDef}

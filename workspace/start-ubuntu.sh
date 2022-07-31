#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

icefolder=ice_beta2
maxplayers=16
hiDef=1
skipDistro=0
while getopts "mhs:" flag
do
    case "${flag}" in
        m) maxplayers=${OPTARG};;
        h) hiDef=${OPTARG};;
        s) skipDistro=${OPTARG};;
    esac
done
echo "maxplayers is $maxplayers...";
echo "hi-def models is $hiDef...";
echo "skip distro is $skipDistro...";

function doCopy() {
    echo 'Copying so libs to redist...'
    sudo cp libs/dlls/ice.so redist/dlls/
    sudo cp libs/dlls/gravebot.so redist/dlls/
    sudo cp libs/cl_dlls/client.so redist/cl_dlls/

    rm -rf  ~/.steam/debian-installation/steamapps/common/Half-Life/${icefolder}/
    rm -rf  ~/.steam/debian-installation/steamapps/common/Half-Life/${icefolder}_hd/
    cp -a redist/. ~/.steam/debian-installation/steamapps/common/Half-Life/${icefolder}/
    cp -a redist_hd/. ~/.steam/debian-installation/steamapps/common/Half-Life/${icefolder}_hd/
}

if [[ $skipDistro -eq 0 ]]; then
    doCopy
fi

steam steam://rungameid/70//-console%20-dev%20-condebug%20-game%20${icefolder}%20-windowed%20-gl%20-w%20640%20-h%20480%20+developer%202%20+log%20on%20+sv_lan%201%20+map%20snowyard%20+deathmatch%201%20+maxplayers%20${maxplayers}%20+_sethdmodels%20${hiDef}

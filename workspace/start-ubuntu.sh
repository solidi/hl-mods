#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

icefolder=ice_beta4
maxplayers=24
hiDef=1
skipDistro=0
debug=0
singlePlayer=0
detailTextures=0
mapName=snowyard
while getopts "m:h:s:d:p:t:w:" flag
do
    case "${flag}" in
        m) maxplayers=${OPTARG};;
        h) hiDef=${OPTARG};;
        s) skipDistro=${OPTARG};;
        d) debug=${OPTARG};;
        p) singlePlayer=${OPTARG};;
        t) detailTextures=${OPTARG};;
        w) mapName=${OPTARG};;
    esac
done
echo "maxplayers is $maxplayers...";
echo "hi-def models is $hiDef...";
echo "skip distro is $skipDistro...";
echo "map is $mapName...";

function doCopy() {
    echo 'Copying so libs to redist...'
    sudo cp libs/dlls/ice.so redist/dlls/
    sudo cp libs/dlls/gravebot.so redist/dlls/
    sudo cp libs/cl_dlls/client.so redist/cl_dlls/
    sudo cp libs/dlls/ice.so redist_sp/dlls/
    sudo cp libs/dlls/gravebot.so redist_sp/dlls/

    installFolder=~/.steam/debian-installation/steamapps/common/Half-Life

    rm -rf  ${installFolder}/${icefolder}/
    rm -rf  ${installFolder}/${icefolder}_hd/
    rm -rf  ${installFolder}/${icefolder}_sp/
    cp -a redist/. ${installFolder}/${icefolder}/
    cp -a redist_hd/. ${installFolder}/${icefolder}_hd/
    cp -a redist_sp/. ${installFolder}/${icefolder}_sp/

    if [[ $detailTextures -eq 1 ]]; then
        echo 'Including detailed textures...'
        cp -a detailed-textures/maps/. ${installFolder}/${icefolder}/maps/
        mkdir ${installFolder}/${icefolder}/gfx/detail
        cp -a detailed-textures/gfx/detail/. ${installFolder}/${icefolder}/gfx/detail/
        cp -a detailed-textures/detailed_textures_readme.txt ${installFolder}/${icefolder}
        echo 'Done including detailed textures.'
    fi
}

if [[ $skipDistro -eq 0 ]]; then
    doCopy
fi

if [[ $singlePlayer -eq 1 ]]; then
    echo "single player is enabled";
    icefolder+="_sp"
fi

if [[ $debug -eq 1 ]]; then
    export LC_ALL="en_US.UTF-8"
    export LD_LIBRARY_PATH=~/.steam/debian-installation/steamapps/common/Half-Life:~/.steam/bin32/steam-runtime/usr/lib/i386-linux-gnu:~/.steam/bin32/steam-runtime/lib/i386-linux-gnu
    ulimit -c unlimited
    cd ~/.steam/debian-installation/steamapps/common/Half-Life
    gdb -ex=r --args hl_linux -console -dev -condebug -game ${icefolder} -zone 8192 -heapsize 131047 -windowed -gl -w 640 -h 480 +fs_perf_warnings 1 +fs_precache_timings 1 +fs_startup_timings 1 +developer 2 +log on +sv_lan 1 +mp_gamemode gungame +deathmatch 1 +map ${mapName} +maxplayers ${maxplayers} +_sethdmodels ${hiDef} +sv_cheats 1
else
    steam steam://rungameid/70//-console%20-dev%20-condebug%20-game%20${icefolder}%20-zone%208192%20-windowed%20-gl%20-w%20640%20-h%20480%20+developer%202%20+log%20on%20+sv_lan%201%20+map%20${mapName}%20+deathmatch%201%20+maxplayers%20${maxplayers}%20+_sethdmodels%20${hiDef}
fi

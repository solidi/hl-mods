#!/bin/bash
# http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail
IFS=$'\n\t'

gameLib=ice.so
clientLib=client.so
cfg=release
clientOnly=0
while getopts ":c:v" flag
do
    case "${flag}" in
        c) cfg=${OPTARG};;
        v) clientOnly=1;;
    esac
done
echo "build config is $cfg...";
echo "clientOnly is $clientOnly...";

cd "$(dirname "$0")"

echo 'Cleaning old libs...'
cd libs
if [[ $clientOnly -eq 0 ]]; then
    rm dlls/${gameLib} || true
    rm dlls/gravebot.so || true
fi
rm cl_dlls/${clientLib} || true

echo 'Cleaning build folder...'
cd ../src/linux
make clean CFG=$cfg

if [[ $clientOnly -eq 0 ]]; then
    echo "Compile Linux ${gameLib}..."
    output=`make hl CFG=$cfg 2>&1` || (echo $output && false)
    mv $cfg/${gameLib} ../../libs/dlls
fi

echo "Compile Linux ${clientLib}..."
output=`make hl_cdll CFG=$cfg 2>&1` || (echo $output && false)
mv $cfg/${clientLib} ../../libs/cl_dlls

if [[ $clientOnly -eq 0 ]]; then
    cd ../../grave-bot-src/dlls
    echo 'Compile Gravebot gravebot.so...'
    make distclean CFG=$cfg
    make clean CFG=$cfg
    output=`make CFG=$cfg 2>&1` || (echo $output && false)
    mv $cfg/gravebot.so ../../libs/dlls
fi

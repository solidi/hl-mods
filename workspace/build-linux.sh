#!/bin/bash
# http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail
IFS=$'\n\t'

gameLib=ice.so
clientLib=client.so
cfg=release
while getopts c: flag
do
    case "${flag}" in
        c) cfg=${OPTARG};;
    esac
done
echo "build config is $cfg...";

echo 'Cleaning old libs...'
cd libs
rm dlls/${gameLib} || true
rm dlls/gravebot.so || true
rm cl_dlls/${clientLib} || true

echo 'Cleaning build folder...'
cd ../src/linux
make clean CFG=$cfg

echo "Compile Linux ${gameLib}..."
output=`make hl CFG=$cfg 2>&1` || (echo $output && false)
echo "Compile Linux ${clientLib}..."
output=`make hl_cdll CFG=$cfg 2>&1` || (echo $output && false)

cd ../../grave-bot-src/dlls
echo 'Compile Gravebot gravebot.so...'
make distclean CFG=$cfg
make clean CFG=$cfg
output=`make CFG=$cfg 2>&1` || (echo $output && false)
mv $cfg/gravebot.so ../../libs/dlls

cd ../../libs
echo 'Copying so libs to redist...'
cp dlls/${gameLib} ../redist/dlls/
cp dlls/gravebot.so ../redist/dlls/
cp cl_dlls/${clientLib} ../redist/cl_dlls/

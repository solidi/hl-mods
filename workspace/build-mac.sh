#!/bin/bash
# http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail
IFS=$'\n\t'

gameLib=ice.dylib
clientLib=client.dylib
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
rm cl_dlls/client.dylib || true

echo 'Cleaning build folder...'
cd ../src/linux
make clean CFG=$cfg

echo "Compile macOS ${gameLib}..."
# https://unix.stackexchange.com/questions/256120/how-can-i-suppress-output-only-if-the-command-succeeds
output=`make hl CFG=$cfg 2>&1` || (echo $output && false)
mv $cfg/${gameLib} ../../libs/dlls

echo "Compile macOS ${clientLib}..."
output=`make hl_cdll CFG=$cfg 2>&1` || (echo $output && false)
mv $cfg/${clientLib} ../../libs/cl_dlls

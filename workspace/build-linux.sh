#!/bin/bash
# http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail
IFS=$'\n\t'

echo 'Cleaning old libs...'
cd libs
rm dlls/hl.so || true
rm dlls/gravebot.so || true
rm cl_dlls/client.so || true

echo 'Cleaning build folder...'
cd ../src/linux
make clean

echo 'Compile Linux hl.so...'
output=`make hl 2>&1` || (echo $output && false)
echo 'Compile Linux client.so...'
output=`make hl_cdll  2>&1` || (echo $output && false)

cd ../../grave-bot-src/dlls
echo 'Compile Gravebot gravebot.so...'
make distclean
make clean
output=`make 2>&1` || (echo $output && false)
mv Release/gravebot.so ../../libs/dlls

cd ../../libs
echo 'Copying so libs to redist...'
cp dlls/hl.so ../redist/dlls/
cp dlls/gravebot.so ../redist/dlls/
cp cl_dlls/client.so ../redist/cl_dlls/

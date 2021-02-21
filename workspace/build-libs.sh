#!/bin/bash
# http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail
IFS=$'\n\t'

echo 'Cleaning old libs...'
cd libs
rm dlls/hl.dylib || true
rm dlls/hl.so || true
rm cl_dlls/client.dylib || true
rm cl_dlls/client.so || true

echo 'Cleaning build folder...'
cd ../src/linux
make clean

echo 'Compile macOS hl.dylib...'
# https://unix.stackexchange.com/questions/256120/how-can-i-suppress-output-only-if-the-command-succeeds
output=`make hl OS=Darwin 2>&1` || (echo $output && false)

echo 'Compile macOS client.dylib...'
output=`make hl_cdll OS=Darwin 2>&1` || (echo $output && false)

echo 'Cleaning build folder...'
make clean

echo 'Compile Linux hl.so...'
output=`make hl OS=Linux 2>&1` || (echo $output && false)
echo 'Compile Linux client.so...'
output=`make hl_cdll OS=Linux 2>&1` || (echo $output && false)

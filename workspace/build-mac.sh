#!/bin/bash
# http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail
IFS=$'\n\t'

echo 'Cleaning old libs...'
cd libs
rm dlls/hl.dylib || true
rm cl_dlls/client.dylib || true

echo 'Cleaning build folder...'
cd ../src/linux
make clean

echo 'Compile macOS hl.dylib...'
# https://unix.stackexchange.com/questions/256120/how-can-i-suppress-output-only-if-the-command-succeeds
output=`make hl 2>&1` || (echo $output && false)

echo 'Compile macOS client.dylib...'
output=`make hl_cdll 2>&1` || (echo $output && false)

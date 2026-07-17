#!/bin/bash
# http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail
IFS=$'\n\t'

gameLib=ice.so
clientLib=client.so
cfg=release
clientOnly=0
clean=0
while getopts ":c:v:x" flag
do
    case "${flag}" in
        c) cfg=${OPTARG};;
        v) clientOnly=1;;
        x) clean=1;;
    esac
done
echo "build config is $cfg...";
echo "clientOnly is $clientOnly...";
echo "client is $clean...";

cd "$(dirname "$0")"
cd libs

if [[ $clean -gt 0 ]]; then
    echo 'Cleaning old libs...'
    if [[ $clientOnly -eq 0 ]]; then
        rm dlls/${gameLib} || true
        rm dlls/gravebot.so || true
    fi
    rm cl_dlls/${clientLib} || true
fi

cd ../src/linux

if [[ $clean -gt 0 ]]; then
    echo 'Cleaning build folder...'
    make clean CFG=$cfg
fi

if [[ $clientOnly -eq 0 ]]; then
    echo "Compile HL ${gameLib}..."
    output=`make hl CFG=$cfg 2>&1` || (echo $output && false)
    mv $cfg/${gameLib} ../../libs/dlls
fi

echo "Compile HL ${clientLib}..."
output=`make hl_cdll CFG=$cfg 2>&1` || (echo $output && false)
mv $cfg/${clientLib} ../../libs/cl_dlls

if [[ $clientOnly -eq 0 ]]; then
    cd ../../grave-bot-src/dlls
    echo 'Compile Gravebot gravebot.so...'
    if [[ $clean -gt 0 ]]; then
        make distclean CFG=$cfg
        make clean CFG=$cfg
    fi
    output=`make -f makefile CFG=$cfg 2>&1` || (echo $output && false)

    graveOut="$cfg/gravebot.so"
    if [[ ! -f "$graveOut" ]]; then
        if [[ -f "Release/gravebot.so" ]]; then
            graveOut="Release/gravebot.so"
        elif [[ -f "release/gravebot.so" ]]; then
            graveOut="release/gravebot.so"
        else
            echo "gravebot.so not found in expected output directories (CFG=$cfg)."
            exit 1
        fi
    fi

    echo "Validating ${graveOut} for unresolved symbols..."
    if ldd -r "$graveOut" 2>&1 | grep -q "undefined symbol"; then
        ldd -r "$graveOut" || true
        echo "gravebot.so contains unresolved symbols; refusing to copy."
        exit 1
    fi

    mv "$graveOut" ../../libs/dlls/gravebot.so
fi

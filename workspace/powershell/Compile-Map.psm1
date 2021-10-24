
function Write-Wad-Config {
    param (
        $mapsDir,
        $wadsDir
    )

    Clear-Content -path $mapsDir\wads.cfg -Force -ErrorAction Ignore
    Add-Content -path $mapsDir\wads.cfg @"
all {
    $wadsDir\coldice.wad
    $wadsDir\decals.wad
    $wadsDir\halflife.wad
    $wadsDir\liquids.wad
    $wadsDir\spraypaint.wad
    $wadsDir\xeno.wad
}
"@
}

function Compile-WPT {
    param (
        $binDir,
        $target,
        $redistDir
    )

    Remove-Item $binDir\BSP_tool.cfg -Force -ErrorAction Ignore
    [void](New-Item $binDir\BSP_tool.cfg)
    '$spawnpoint info_player_deathmatch' | Add-Content $binDir\BSP_tool.cfg
    "`$halflife_dir `"..\`"" | Add-Content $binDir\BSP_tool.cfg

    echo "Writing ${target}.wpt..."
    $out = & .\BSP_tool -w $target | Out-String
    [void](Get-Item -Path "$target.HPB_wpt")
    if (!$?) {
        Write-Error "$out`n> Could not wpt ${target}."
        exit
    }
    Move-Item $binDir\$target.HPB_wpt $redistDir\maps\$target.wpt -Force
    echo "Done writing ${target}.wpt."
}

function Compile-Map {
    param (
        $binDir,
        $target,
        $mapsDir,
        $redistDir,
        $wadsDir
    )

    $bspTimestamp = (Get-Item $redistDir\maps\$target.bsp -ErrorAction Ignore).LastWriteTime
    $lastestSourceFileStamp = 0;
    Get-ChildItem $mapsDir\$target | Foreach-Object {
        if ($_.LastWriteTime -gt $lastestSourceFileStamp) {
            $lastestSourceFileStamp = $_.LastWriteTime
        }
    }

    if ($lastestSourceFileStamp -lt $bspTimestamp) {
        echo "$target.bsp - source files: $lastestSourceFileStamp >? bsp file: $bspTimestamp"
        return
    }

    Write-Wad-Config $mapsDir $wadsDir

    # Clean directory if compile was unsuccessful last time
    Remove-Item $mapsDir\$target -Recurse -Exclude *.map,*wpt -Force -ErrorAction Ignore

    Set-Location -Path $binDir
    echo "Compiling map $target..."
    $out = & .\hlcsg -wadcfgfile $mapsDir\wads.cfg -wadconfig all $mapsDir\$target\$target.map | Out-String
    if (!$?) {
        Write-Error "$out`n> Could not hlcsg ${target}."
        exit
    }
    $out = & .\hlbsp $mapsDir\$target\$target.map | Out-String
    if (!$?) {
        Write-Error "$out`n> Could not hlbsp ${target}."
        exit
    }
    $out = & .\hlvis -full $mapsDir\$target\$target.map | Out-String
    if (!$?) {
        Write-Error "$out`n> Could not hlvis ${target}."
        exit
    }
    $out = & .\hlrad -extra -lights $mapsDir\lights.rad $mapsDir\$target\$target.map | Out-String
    if (!$?) {
        Write-Error "$out`n> Could not hlrad ${target}."
        exit
    }
    Move-Item $mapsDir\$target\$target.bsp $redistDir\maps\$target.bsp -Force

    Compile-WPT $binDir $target $redistDir

    Get-ChildItem $mapsDir\$target -recurse -exclude *.map,*.wpt | Remove-Item -Force -ErrorAction Ignore
    echo "Done compiling $target.bsp."
}


function Select-Wad-List {
    param (
        $wadsDir,
        $noWad
    )

    if ($noWad)
    {
    @"
all {
    $wadsDir\coldice.wad
    $wadsDir\decals.wad
    $wadsDir\halflife.wad
    $wadsDir\liquids.wad
    $wadsDir\spacepirate.wad
    $wadsDir\spraypaint.wad
    $wadsDir\xeno.wad
    $wadsDir\quadfrost.wad
}
"@
    }
    else
    {
    @"
all {
    $wadsDir\coldice.wad
    $wadsDir\decals.wad
    $wadsDir\halflife.wad
    $wadsDir\liquids.wad
    $wadsDir\spacepirate.wad
    $wadsDir\spraypaint.wad
    $wadsDir\xeno.wad
}
"@
    }
}

function Write-Wad-Config {
    param (
        $mapsDir,
        $wadList
    )

    Clear-Content -path $mapsDir\wads.cfg -Force -ErrorAction Ignore
    Add-Content -path $mapsDir\wads.cfg $wadList
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

    $success = $false
    while (!$success) {
        Write-Output "`nWriting ${target}.wpt..."
        $out = & .\BSP_tool -w $target | Out-String
        $success = $?
        if (!$success) {
            Write-Error "$out`n> Could not wpt ${target}, trying again."
        }
    }
    [void](Get-Item -Path "$target.HPB_wpt")
    Move-Item $binDir\$target.HPB_wpt $redistDir\maps\$target.wpt -Force
    Write-Output "Done writing ${target}.wpt."
}

function Compile-Resgen {
    param (
        $target,
        $redistDir
    )

    $success = $false

    Write-Output "Writing ${target}.res..."
    $out = & .\RESGen -ok -f $redistDir\maps\$target.bsp | Out-String
    $success = $?
    Write-Output $out
    if (!$success) {
        Write-Error "$out`n> Could not resgen ${target}."
        exit
    }

    Write-Output "Done writing ${target}.res."
}

function Compile-Map {
    param (
        $binDir,
        $target,
        $mapsDir,
        $redistDir,
        $wadsDir,
        $finalCompile,
        $noWad
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

    $allOptions = if (!$finalCompile) { "-high" } # -chart
    $csgOptions = if ($noWad) { "-nowadtextures" }
    $visOptions = if ($finalCompile) { "-full" } else { "-fast" }
    # -bounce 8 -dscale 1 -smooth 120 -smooth2 120 -scale 1 -sparse
    $radOptions = if ($finalCompile) { "-extra" }

    $wadList = Select-Wad-List $wadsDir $noWad
    Write-Wad-Config $mapsDir $wadList

    # Clean directory if compile was unsuccessful last time
    Remove-Item $mapsDir\$target -Recurse -Exclude *.map,*.wpt,*.txt -Force -ErrorAction Ignore

    Set-Location -Path $binDir
    Write-Output "Compiling map $target..."
    Write-Output "hlcsg $target..."
    if ($noWad) {
        Write-Output "hlcsg will add textures into map [$csgOptions]..."
    }
    $out = & .\hlcsg $allOptions -wadcfgfile $mapsDir\wads.cfg -wadconfig all $csgOptions $mapsDir\$target\$target.map | Out-String
    if (!$?) {
        Write-Error "$out`n> Could not hlcsg ${target}."
        exit
    }
    Write-Output "`nhlbsp $target..."
    $out = & .\hlbsp $allOptions $mapsDir\$target\$target | Out-String
    if (!$?) {
        Write-Error "$out`n> Could not hlbsp ${target}."
        exit
    }
    Write-Output "`nhlvis $target..."
    $out = & .\hlvis $allOptions $visOptions $mapsDir\$target\$target | Out-String
    if (!$?) {
        Write-Error "$out`n> Could not hlvis ${target}."
        exit
    }
    Write-Output "`nhlrad $target..."
    $out = & .\hlrad $allOptions $radOptions -lights $mapsDir\lights.rad $mapsDir\$target\$target.bsp | Out-String
    if (!$?) {
        Write-Error "$out`n> Could not hlrad ${target}."
        exit
    }
    Move-Item $mapsDir\$target\$target.bsp $redistDir\maps\$target.bsp -Force
    Copy-Item $mapsDir\$target\$target*.txt $redistDir\maps -Force -ErrorAction Ignore

    Compile-WPT $binDir $target $redistDir
    Compile-Resgen $target $redistDir

    Get-ChildItem $mapsDir\$target -recurse -exclude *.map,*.wpt,*.txt,*.res | Remove-Item -Force -ErrorAction Ignore
    Write-Output "Done compiling $target.bsp."
}


function Git-Head-Branch-Name {
    $branchName = "unknown-head-branch"

    try {
        $branchName = (git remote show origin | grep 'HEAD branch' | cut -d' ' -f5)
    } catch {
        Write-Error "git is unavailable"
    }

    return $branchName
}

function Git-Current-Branch-Name {
    $branchName = "unknown-current-branch"

    try {
        $branchName = (git rev-parse --abbrev-ref HEAD)
    } catch {
        Write-Error "git is unavailable"
    }

    return $branchName
}

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
    $wadsDir\spacepirate.wad
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

    $success = $false
    while (!$success) {
        Write-Output "`nWriting ${target}.wpt..."
        $out = & .\BSP_tool -w $target | Out-String
        $success = $?
        if (!$success) {
            Write-Output "$out`n> Could not wpt ${target}, trying again."
        }
    }
    [void](Get-Item -Path "$target.HPB_wpt")
    Move-Item $binDir\$target.HPB_wpt $redistDir\maps\$target.wpt -Force
    Write-Output "Done writing ${target}.wpt."
}

function Compile-Map {
    param (
        $binDir,
        $target,
        $mapsDir,
        $redistDir,
        $wadsDir,
        $finalCompile
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

    $allOptions = if (!$finalCompile) { "-high" }
    $visOptions = if ($finalCompile) { "-full" } else { "-fast" }
    # -bounce 8 -dscale 1 -smooth 120 -smooth2 120 -scale 1 -sparse
    $radOptions = if ($finalCompile) { "-extra" }

    Write-Wad-Config $mapsDir $wadsDir

    # Clean directory if compile was unsuccessful last time
    Remove-Item $mapsDir\$target -Recurse -Exclude *.map,*wpt -Force -ErrorAction Ignore

    Set-Location -Path $binDir
    Write-Output "Compiling map $target..."
    Write-Output "hlcsg $target..."
    $out = & .\hlcsg $allOptions -wadcfgfile $mapsDir\wads.cfg -wadconfig all $mapsDir\$target\$target.map | Out-String
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

    Compile-WPT $binDir $target $redistDir

    Get-ChildItem $mapsDir\$target -recurse -exclude *.map,*.wpt | Remove-Item -Force -ErrorAction Ignore
    Write-Output "Done compiling $target.bsp."
}

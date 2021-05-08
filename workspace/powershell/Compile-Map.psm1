
function Write-Wad-Config {
    param (
        $mapsDir,
        $wadsDir
    )

    Clear-Content -path $mapsDir\wads.cfg -Force -ErrorAction Ignore
    Add-Content -path $mapsDir\wads.cfg @"
all {
    $wadsDir\halflife.wad
}
"@
}

function Compile-Map {
    param (
        $binDir,
        $target,
        $mapsDir,
        $redistDir,
        $wadsDir
    )

    Write-Wad-Config $mapsDir $wadsDir

    # Clean directory if compile was unsuccessful last time
    Remove-Item $mapsDir\$target -Recurse -Exclude "$target.map" -Force -ErrorAction Ignore

    Set-Location -Path $binDir
    echo "Compiling map $target..."
    $out = & .\hlcsg -wadcfgfile $mapsDir\wads.cfg -wadconfig all $mapsDir\$target\$target.map | Out-String
    if (!$?) {
        Write-Error  "$out`n> Could not hlcsg ${target}."
        exit
    }
    $out = & .\hlbsp $mapsDir\$target\$target.map | Out-String
    if (!$?) {
        Write-Error  "$out`n> Could not hlbsp ${target}."
        exit
    }
    $out = & .\hlvis $mapsDir\$target\$target.map | Out-String
    if (!$?) {
        Write-Error  "$out`n> Could not hlvis ${target}."
        exit
    }
    $out = & .\hlrad -lights $mapsDir\lights.rad $mapsDir\$target\$target.map | Out-String
    if (!$?) {
        Write-Error "$out`n> Could not hlrad ${target}."
        exit
    }
    Move-Item $mapsDir\$target\$target.bsp $redistDir\maps\$target.bsp
    Get-ChildItem $mapsDir\$target -Exclude *.map | Remove-Item -Force -ErrorAction Ignore
}

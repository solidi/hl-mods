
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

    Set-Location -Path $binDir
    echo "Compiling map $target..."
    $out = & .\hlcsg -wadcfgfile $mapsDir\wads.cfg -wadconfig all $mapsDir\$target\$target.map | Out-String
    if ($lastexitcode -ne 0) {
        echo "$out> Could not qcsp ${target}. Exit code: ${lastexitcode}"
        exit
    }
    $out = & .\hlbsp $mapsDir\$target\$target.map | Out-String
    if ($lastexitcode -ne 0) {
        echo "$out> Could not qbsp ${target}. Exit code: ${lastexitcode}"
        exit
    }
    $out = & .\hlvis $mapsDir\$target\$target.map | Out-String
    if ($lastexitcode -ne 0) {
        echo "$out> Could not vis ${target}. Exit code: ${lastexitcode}"
        exit
    }
    $out = & .\hlrad $mapsDir\$target\$target.map | Out-String
    if ($lastexitcode -ne 0) {
        echo "$out> Could not qrad ${target}. Exit code: ${lastexitcode}"
        exit
    }
    Move-Item $mapsDir\$target\$target.bsp $redistDir\maps\$target.bsp
    Get-ChildItem $mapsDir\$target -Exclude *.map | Remove-Item -Force -ErrorAction Ignore
}

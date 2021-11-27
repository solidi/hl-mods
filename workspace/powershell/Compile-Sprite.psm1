$ErrorActionPreference = "Stop"

function Compile-Sprite {
    param (
        $binDir,
        $target,
        $spritesDir,
        $outDir
    )

    Copy-Item $binDir\sprgen.exe $spritesDir\$target
    Remove-Item $spritesDir\$target.spr -ErrorAction Ignore
    Set-Location -Path $spritesDir\$target
    echo "Compiling sprite $spritesDir\$target.spr..."
    $out = & .\sprgen $spritesDir\$target\$target.qc | Out-String

    if (!$?) {
        Write-Error "$out`n> Could not compile ${target}."
        exit
    }
    Move-Item $spritesDir\$target\$target.spr $outDir\$target.spr -force
    Remove-Item $spritesDir\$target\sprgen.exe
}

function Colorize-Folder {
    param (
        $binDir,
        $target,
        $rgb,
        $tint
    )

    Get-ChildItem -Path $target -Filter "*.bmp" | Foreach-Object {
        Echo "Colorizing $($_.FullName)..."
        $out = & $binDir\convert $_.FullName -colorspace gray -fill "rgb($rgb)" -tint $tint -depth 8 -type palette -remap $target\nuke2001.BMP -compress none BMP3:$_ | Out-String

        if (!$?) {
            Write-Error "$out`n> Could not colorize $($_.FullName)."
            exit
        }
    }
}

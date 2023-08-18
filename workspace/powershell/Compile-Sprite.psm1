$ErrorActionPreference = "Stop"

function Compile-Sprite {
    param (
        $binDir,
        $target,
        $spritesDir,
        $outDir
    )

    $sprTimestamp = (Get-Item $outDir\$target.spr -ErrorAction Ignore).LastWriteTime
    $latestSourceFileStamp = 0;
    Get-ChildItem $spritesDir\$target | Foreach-Object {
        if ($_.LastWriteTime -gt $latestSourceFileStamp) {
            $latestSourceFileStamp = $_.LastWriteTime
        }
    }

    if ($latestSourceFileStamp -lt $sprTimestamp) {
        echo "$target.spr - source files: $latestSourceFileStamp >? spr file: $sprTimestamp"
        return
    }

    Copy-Item $binDir\sprgen.exe $spritesDir\$target
    Remove-Item $spritesDir\$target.spr -ErrorAction Ignore
    Set-Location -Path $spritesDir\$target
    Write-Output "Compiling sprite $spritesDir\$target.spr..."
    $out = & .\sprgen $spritesDir\$target\$target.qc | Out-String

    if (!$?) {
        Throw "$out`n> Could not compile ${target}."
    }
    Move-Item $spritesDir\$target\$target.spr $outDir\$target.spr -force
    Remove-Item $spritesDir\$target\sprgen.exe
}

function Colorize-Folder {
    param (
        $binDir,
        $folder,
        $target,
        $rgb,
        $tint
    )

    Copy-Item $folder\$target\${target}001.BMP -Destination $folder\$target\${target}000.BMP

    $out = & $binDir\convert $folder\$target\${target}000.BMP -colorspace gray -fill "rgb($rgb)" -tint $tint -depth 8 -type palette -compress none BMP3:$folder\$target\${target}000.BMP | Out-String

    if (!$?) {
        Write-Error "$out`n> Could not colorize first image $folder\$target\${target}001.BMP."
        exit
    }

    Get-ChildItem -Path $folder\$target -Filter "*.bmp" | Foreach-Object {
        if ($_.Name.Contains("000.BMP")) {
            return
        }

        Write-Output "Colorizing $($_.FullName)..."
        $out = & $binDir\convert $_.FullName -colorspace gray -fill "rgb($rgb)" -tint $tint -depth 8 -type palette -remap $folder\$target\${target}000.BMP -compress none BMP3:$_ | Out-String

        if (!$?) {
            Write-Error "$out`n> Could not colorize $($_.FullName)."
            exit
        }
    }

    Remove-Item $folder\$target\${target}000.BMP
}

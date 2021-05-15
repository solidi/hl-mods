
function Invert-Skin {
    param (
        $binDir,
        $target,
        $path
    )

    Set-Location -Path $binDir
    Get-ChildItem $path\$target -Filter *.bmp |
    Foreach-Object {
        if (!$_.BaseName.Contains("invert_")) {
            $pathToBmp = "$path\$target\invert_$($_.Name)"
            if (!(Test-Path $pathToBmp)) {
                echo "$_ converting inverted skin!"
                try {
                    $command = ".\convert `"$_`" -negate -compress none BMP3:`"$path\$target\invert_$($_.Name)`""
                    $out = iex $command | Out-String
                } catch {
                    Write-Error "$out> Could not invert skin.`nReason: $_"
                    exit
                }
            } else {
                echo "$_ already generated inverted skin..."
            }
        }
    }

    if (!$?) {
        exit
    }
}

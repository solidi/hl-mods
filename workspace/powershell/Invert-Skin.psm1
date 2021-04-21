
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
            if (!(Test-Path $path\$target\invert_$_)) {
                echo "$_ converting inverted skin!"
                $out = & .\convert $_.FullName -negate -compress none BMP3:$path\$target\invert_$_
                echo $out
            } else {
                echo "$_ already generated inverted skin..."
            }
        }
    }
}


function Compile-Font {
    param (
        $binDir,
        $fontName
    )

    Set-Location -Path $binDir
    echo "Compiling $fontName fonts.wad..."
    $out = & .\makefont.exe -font "$fontName" $redistdir\fonts.wad

    if ($lastexitcode -ne 0) {
        echo "$out> Could not makefont. Exit code: ${lastexitcode}"
        exit
    }
}

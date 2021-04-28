
function Compile-Font {
    param (
        $binDir,
        $redistDir,
        $fontName
    )

    Set-Location -Path $binDir
    echo "Compiling $fontName fonts.wad..."
    try {
        $out = & .\makefont -font "$fontName" $redistDir\fonts.wad | Out-String
    } catch {
        Write-Error "$out> Could not makefont.`nReason: $_.Exception.Message"
        exit
    }
}

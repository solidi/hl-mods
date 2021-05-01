
function Compile-Wad {
    param (
        $binDir,
        $target,
        $wadsDir,
        $redistDir
    )

    Set-Location -Path $binDir
    echo "Compiling wad $wadsDir\$target.wad..."
    try {
        $out = & .\makels $wadsDir\$target $wadsDir\$target $wadsDir\$target.ls | Out-String
    } catch {
        Write-Error "$out> Could not makels ${target}.`nReason: $_.Exception.Message"
        exit
    }
    try {
        $out = & .\qlumpy $wadsDir\$target.ls | Out-String
    } catch {
        Write-Error "$out> Could not qlumpy ${target}.`nReason: $_.Exception.Message"
        exit
    }
    Remove-Item $wadsDir\$target.ls -Recurse -Force -ErrorAction Ignore
    Move-Item $wadsDir\$target.wad $redistDir -Force
}


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
        echo "& .\makels $wadsDir\$target $wadsDir\$target $wadsDir\$target.l"
        $out = & .\makels $wadsDir\$target $wadsDir\$target $wadsDir\$target.l | Out-String
        if (!$?) {
            throw
        }
    } catch {
        Write-Error "$out> Could not makels ${target}.`nReason: $($_.Exception)"
        exit
    }
    try {
        $out = & .\qlumpy $wadsDir\$target.l | Out-String
        if (!$?) {
            throw
        }
    } catch {
        Write-Error "$out> Could not qlumpy ${target}.`nReason: $($_.Exception)"
        exit
    }
    Remove-Item $wadsDir\$target.l -Recurse -Force -ErrorAction Ignore
    Copy-Item $wadsDir\$target.wad $redistDir -Force
}

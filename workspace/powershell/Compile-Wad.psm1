
function Compile-Wad {
    param (
        $binDir,
        $target,
        $wadsDir,
        $redistDir
    )

    Set-Location -Path $binDir
    echo "Compiling wad $wadsDir\$target.wad..."
    $out = & .\makels $wadsDir\$target $wadsDir\$target $wadsDir\$target.ls | Out-String
    if ($lastexitcode -ne 0) {
        echo "$out> Could not makels ${target}. Exit code: ${lastexitcode}"
        exit
    }
    $out = & .\qlumpy $wadsDir\$target.ls | Out-String
    if ($lastexitcode -ne 0) {
        echo "$out> Could not qlumpy ${target}. Exit code: ${lastexitcode}"
        exit
    }
    Remove-Item $wadsDir\$target.ls -Recurse -Force -ErrorAction Ignore
    Move-Item $wadsDir\$target.wad $redistDir -Force
}

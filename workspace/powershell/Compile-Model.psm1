
function Compile-Model {
    param (
        $binDir,
        $target,
        $modelsDir,
        $outDir
    )

    Copy-Item $binDir\studiomdl.exe $modelsDir\$target
    Remove-Item $modelsDir\$target.mdl -ErrorAction Ignore
    Set-Location -Path $modelsDir\$target
    echo "Compiling model $modelsDir\$target\$target.qc..."
    try {
        $out = & .\studiomdl $modelsDir\$target\$target.qc | Out-String
    } catch {
        Write-Error "$out> Could not compile ${target}.`nReason: $_.Exception.Message"
        exit
    }
    Move-Item $modelsDir\$target\$target.mdl $outDir\$target.mdl -force
    Remove-Item $modelsDir\$target\studiomdl.exe
}

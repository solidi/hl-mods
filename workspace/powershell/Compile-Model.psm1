$ErrorActionPreference = "Stop"

function Compile-Model {
    param (
        $binDir,
        $target,
        $modelsDir,
        $outDir
    )

    Remove-Item $modelsDir\$target.mdl -ErrorAction Ignore
    Set-Location -Path $modelsDir\$target
    echo "Compiling model $modelsDir\$target\$target.qc..."
    $out = & $binDir\studiomdl $modelsDir\$target\$target.qc | Out-String
    if (!$?) {
        Write-Error "$out`n> Could not compile ${target}."
        exit
    }
    Move-Item $modelsDir\$target\$target.mdl $outDir\$target.mdl
}

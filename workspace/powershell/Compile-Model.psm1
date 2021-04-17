
function Compile-Model {
    param (
        $binDir,
        $target,
        $modelsdir,
        $outDir
    )

    Copy-Item $binDir\studiomdl.exe $modelsdir\$target
    Remove-Item $modelsdir\$target.mdl -ErrorAction Ignore
    Set-Location -Path $modelsdir\$target
    echo "Compiling model $modelsdir\$target\$target.qc..."
    $out = & $modelsdir\$target\studiomdl $modelsdir\$target\$target.qc | Out-String
    if ($lastexitcode -ne 0) {
        echo "$out> Could not compile ${target}. Exit code: ${lastexitcode}"
        exit
    }
    Move-Item $modelsdir\$target\$target.mdl $outDir\$target.mdl -force
    Remove-Item $modelsdir\$target\studiomdl.exe
}

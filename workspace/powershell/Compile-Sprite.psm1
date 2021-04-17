
function Compile-Sprite {
    param (
        $binDir,
        $target,
        $spritesDir,
        $outDir
    )

    Copy-Item $binDir\sprgen.exe $spritesDir\$target
    Remove-Item $spritesDir\$target.spr -ErrorAction Ignore
    Set-Location -Path $spritesDir\$target
    echo "Compiling sprite $spritesDir\$target.spr..."
    $out = & .\sprgen $spritesDir\$target\$target.qc | Out-String
    if ($lastexitcode -ne 0) {
        echo "$out> Could not compile ${target}. Exit code: ${lastexitcode}"
        exit
    }
    Move-Item $spritesDir\$target\$target.spr $outDir\$target.spr -force
    Remove-Item $spritesDir\$target\sprgen.exe
}

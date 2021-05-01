
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
    try {
        $out = & .\sprgen $spritesDir\$target\$target.qc | Out-String
    } catch {
        write-Error "$out> Could not compile ${target}.`nReason: $_.Exception.Message"
        exit
    }
    Move-Item $spritesDir\$target\$target.spr $outDir\$target.spr -force
    Remove-Item $spritesDir\$target\sprgen.exe
}

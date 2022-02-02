$ErrorActionPreference = "Stop"

function Compile-Model {
    param (
        $binDir,
        $target,
        $modelsDir,
        $outDir
    )

    $mdlTimestamp = (Get-Item $outDir\$target.mdl -ErrorAction Ignore).LastWriteTime
    $lastestSourceFileStamp = 0;
    Get-ChildItem $modelsDir\$target | Foreach-Object {
        if ($_.LastWriteTime -gt $lastestSourceFileStamp) {
            $lastestSourceFileStamp = $_.LastWriteTime
        }
    }
    $containsCommon = Select-String -Path $modelsDir\$target\$target.qc -Pattern "common"
    if ($containsCommon -ne $null)
    {
        Get-ChildItem $modelsDir\common | Foreach-Object {
            if ($_.LastWriteTime -gt $lastestSourceFileStamp) {
                $lastestSourceFileStamp = $_.LastWriteTime
            }
        }
    }
    echo "$target source files: $lastestSourceFileStamp >? mdl file: $mdlTimestamp"

    if ($lastestSourceFileStamp -gt $mdlTimestamp) {
        Remove-Item $modelsDir\$target.mdl -ErrorAction Ignore # Clean up a failed move prior.
        Set-Location -Path $modelsDir\$target
        echo "Compiling model $modelsDir\$target\$target.qc..."
        $out = & $binDir\studiomdl $modelsDir\$target\$target.qc | Out-String
        if (!$?) {
            Write-Error "$out`n> Could not compile ${target}."
            exit
        }
        Move-Item $modelsDir\$target\$target.mdl $outDir\$target.mdl -Force
    } else {
        echo "Skipping model $target as mdl timestamp is greater than source files."
    }
}

function Compile-Player($name, $binDir, $modelsdir, $redistDir) {
    Compile-Model $binDir $name $modelsdir $redistDir\models\player\$name
    Copy-Item $modelsdir\$name\$name.bmp $redistDir\models\player\$name
    Copy-Item $modelsdir\$name\$name.txt $redistDir\models\player\$name -ErrorAction SilentlyContinue
}

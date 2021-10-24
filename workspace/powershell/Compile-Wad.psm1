
function Compile-Wad {
    param (
        $binDir,
        $target,
        $wadsDir,
        $redistDir
    )

    $wadTimestamp = (Get-Item $redistDir\$target.wad -ErrorAction Ignore).LastWriteTime
    $lastestSourceFileStamp = 0;
    Get-ChildItem $wadsDir\$target | Foreach-Object {
        if ($_.LastWriteTime -gt $lastestSourceFileStamp) {
            $lastestSourceFileStamp = $_.LastWriteTime
        }
    }

    if ($lastestSourceFileStamp -lt $wadTimestamp) {
        echo "$target.wad - source files: $lastestSourceFileStamp >? wad file: $wadTimestamp"
        return
    }

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

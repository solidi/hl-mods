
function PAK-File {
    param (
        $binDir,
        $targetDir,
        $targets
    )

    Copy-Item $binDir\qpakman.exe $targetDir -Force
    Set-Location -Path $targetDir
    $folders = [String]::Join(" ", $targets)
    $in = ".\qpakman.exe ${folders} -o pak0.pak"
    echo "Creating pak0 file..."
    try {
        $out = iex $in | Out-String
    } catch {
        Write-Error "$out> Could not pak project.`nReason: $_.Exception.Message"
        exit
    }

    # qpakman does not exit with failure.
    if ($out -match '[1-9] failures' -or $out.Contains("FAILURE")) {
        echo "$out> Could not create pak file."
        exit
    }

    foreach ($folder in $targets) {
        Remove-Item "${targetDir}\${folder}\\*" -Recurse -Force
    }
    Remove-Item "${targetDir}\qpakman.exe"
}

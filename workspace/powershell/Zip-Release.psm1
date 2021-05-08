
function Zip-Release {
    param (
        $rootDir,
        $redistDir,
        $redistHdDir
    )
    
    try {
        echo "Creating zipped release..."
        $zipFile = "${rootDir}\last-build.zip"

        New-Item -Force -ItemType Directory $env:TEMP\release
        Copy-Item -Recurse -Force $redistDir $env:TEMP\release
        Remove-Item $env:TEMP\release\redist\dev.cfg
        Rename-Item $env:TEMP\release\redist $env:TEMP\release\ice
        Copy-Item -Recurse -Force $redistHdDir $env:TEMP\release
        Rename-Item $env:TEMP\release\redist_hd $env:TEMP\release\ice_hd
        Compress-Archive -LiteralPath $env:TEMP\release\ice -DestinationPath $zipFile -Force
        Compress-Archive -LiteralPath $env:TEMP\release\ice_hd -DestinationPath $zipFile -Update
        Remove-Item $env:TEMP\release -Recurse -Force -ErrorAction Ignore
    } catch {
        Write-Error "Could not create zip file.`nReason: $_.Exception.Message"
        exit
    }
}

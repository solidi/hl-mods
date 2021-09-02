
function Git-Hash {
    $commitHash = "unknown"

    try {
        $commitHash = (git rev-parse HEAD).Substring(0,7)
    } catch {
        Write-Error "git is unavailable"
    }

    $versionDate = [System.DateTime]::Now.ToString('yyyy-MM-dd.HH:mm:ss')
    $version = "$versionDate-git-$commitHash"

    return $version
}

function Zip-Release {
    param (
        $rootDir,
        $redistDir,
        $redistHdDir
    )
    
    try {
        echo "Creating zipped release..."
        $zipFile = "${rootDir}\last-build.zip"

        [void](New-Item -Force -ItemType Directory $env:TEMP\release)

        Copy-Item -Recurse -Force $redistDir $env:TEMP\release
        Remove-Item $env:TEMP\release\redist\dev.cfg
        Remove-Item $env:TEMP\release\redist\models\\* -Recurse -Force
        Remove-Item $env:TEMP\release\redist\models -Force
        Remove-Item $env:TEMP\release\redist\sound\\* -Recurse -Force
        Remove-Item $env:TEMP\release\redist\sound -Force
        Remove-Item $env:TEMP\release\redist\sprites\\* -Recurse -Force
        Remove-Item $env:TEMP\release\redist\sprites -Force

        $version = "`r`nPackage version: $(Git-Hash)`r`n"
        echo $version
        $version | Add-Content $env:TEMP\release\redist\readme.txt

        Rename-Item $env:TEMP\release\redist $env:TEMP\release\ice
        Copy-Item -Recurse -Force $redistHdDir $env:TEMP\release
        Rename-Item $env:TEMP\release\redist_hd $env:TEMP\release\ice_hd
        Compress-Archive -LiteralPath $env:TEMP\release\ice -DestinationPath $zipFile -Force
        Compress-Archive -LiteralPath $env:TEMP\release\ice_hd -DestinationPath $zipFile -Update
        Remove-Item $env:TEMP\release -Recurse -Force -ErrorAction Ignore
    } catch {
        Write-Error "Could not create zip file.`nReason: $($_.Exception.Message)"
        exit
    }
}


function Git-Hash {
    param (
        $withDate
    )

    $commitHash = "unknown"

    try {
        $commitHash = (git rev-parse HEAD).Substring(0,7)
    } catch {
        Write-Error "git is unavailable"
    }

    if ($withDate) {
        $versionDate = [System.DateTime]::Now.ToString('yyyy-MM-dd.HH:mm:ss') + "-"
    }
    $version = "${versionDate}git-$commitHash"

    return $version
}

function Zip-Release {
    param (
        $rootDir,
        $redistDir,
        $redistHdDir,
        $gameFolder
    )
    
    try {
        $gitHash = $(Git-Hash)
        echo "Creating $Package version: $gitHash`r`n..."
        $zipFile = "${rootDir}\cold-ice-remastered-${gitHash}.zip"

        [void](New-Item -Force -ItemType Directory $env:TEMP\release)

        Copy-Item -Recurse -Force $redistDir $env:TEMP\release
        Remove-Item $env:TEMP\release\redist\dev.cfg
        Remove-Item $env:TEMP\release\redist\userconfig.cfg
        Remove-Item $env:TEMP\release\redist\models\\* -Recurse -Force
        Remove-Item $env:TEMP\release\redist\models -Force
        Remove-Item $env:TEMP\release\redist\sound\\* -Recurse -Force
        Remove-Item $env:TEMP\release\redist\sound -Force
        Remove-Item $env:TEMP\release\redist\sprites\\* -Recurse -Force
        Remove-Item $env:TEMP\release\redist\sprites -Force

        "`r`nPackage version: $(Git-Hash 1)`r`n" | Add-Content $env:TEMP\release\redist\readme.txt
        "`r`nPackage version: $(Git-Hash 1)`r`n" | Add-Content $env:TEMP\release\redist\motd.txt

        Rename-Item $env:TEMP\release\redist $env:TEMP\release\$gameFolder
        Copy-Item -Recurse -Force $redistHdDir $env:TEMP\release
        Rename-Item $env:TEMP\release\redist_hd $env:TEMP\release\${gameFolder}_hd
        Compress-Archive -LiteralPath $env:TEMP\release\$gameFolder -DestinationPath $zipFile -Force
        Compress-Archive -LiteralPath $env:TEMP\release\${gameFolder}_hd -DestinationPath $zipFile -Update
        Remove-Item $env:TEMP\release -Recurse -Force -ErrorAction Ignore
    } catch {
        Write-Error "Could not create zip file.`nReason: $($_.Exception.Message)"
        exit
    }
}


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

function Package-Release {
    param (
        $rootDir,
        $redistDir,
        $redistHdDir,
        $redistSpDir,
        $gameFolder
    )

    Install-Module 7Zip4PowerShell -MinimumVersion 2.2.0 -Scope AllUsers -Force -Verbose

    try {
        $gitHash = $(Git-Hash)
        echo "Creating version: $gitHash`r`n..."
        $zipFile = "${rootDir}\cold-ice-remastered-${gitHash}.7z"

        [void](New-Item -Force -ItemType Directory $env:TEMP\release)

        Copy-Item -Recurse -Force $redistDir $env:TEMP\release
        Remove-Item $env:TEMP\release\redist\dev.cfg
        Remove-Item $env:TEMP\release\redist\userconfig.cfg
        Remove-Item $env:TEMP\release\redist\models\\* -Recurse -Force -ErrorAction Ignore

        # Special move of the player folder as it cannot be paked
        [void](New-Item -ItemType directory -Path $env:TEMP\release\redist\models\player)
        Copy-Item -Recurse -Force $redistDir\player $env:TEMP\release\redist\models -ErrorAction Ignore
        Copy-Item -Recurse -Force $redistDir\player $redistDir\models -ErrorAction Ignore
        Remove-Item $redistDir\player\\* -Recurse -Force -ErrorAction Ignore
        Remove-Item $redistDir\player -Force -ErrorAction Ignore
        Remove-Item $env:TEMP\release\redist\player\\* -Recurse -Force -ErrorAction Ignore
        Remove-Item $env:TEMP\release\redist\player -Force -ErrorAction Ignore

        Remove-Item $env:TEMP\release\redist\sound\\* -Recurse -Force -ErrorAction Ignore
        Remove-Item $env:TEMP\release\redist\sound -Force -ErrorAction Ignore
        Remove-Item $env:TEMP\release\redist\sprites\\* -Recurse -Force -ErrorAction Ignore
        Remove-Item $env:TEMP\release\redist\sprites -Force -ErrorAction Ignore

        "`r`nPackage version: $(Git-Hash 1)`r`n" | Add-Content $env:TEMP\release\redist\readme.txt
        "`r`nPackage version: $(Git-Hash 1)`r`n" | Add-Content $env:TEMP\release\redist\motd.txt

        Rename-Item $env:TEMP\release\redist $env:TEMP\release\$gameFolder
        Copy-Item -Recurse -Force $redistHdDir $env:TEMP\release -ErrorAction Ignore
        Rename-Item $env:TEMP\release\redist_hd $env:TEMP\release\${gameFolder}_hd -ErrorAction Ignore
        # SP Special package items ---
        Copy-Item -Recurse -Force $redistSpDir $env:TEMP\release -ErrorAction Ignore
        Rename-Item $env:TEMP\release\redist_sp $env:TEMP\release\${gameFolder}_sp -ErrorAction Ignore
        Copy-Item $env:TEMP\release\$gameFolder\readme.txt $env:TEMP\release\${gameFolder}_sp
        Copy-Item $env:TEMP\release\$gameFolder\config.cfg $env:TEMP\release\${gameFolder}_sp
        # ---
        Remove-Item $zipFile -Force -ErrorAction Ignore
        Compress-7Zip -Path $env:TEMP\release -ArchiveFileName $zipFile
        Remove-Item $env:TEMP\release -Recurse -Force -ErrorAction Ignore
    } catch {
        Throw "Could not create zip file.`nReason: $($_.Exception.Message)"
    }
}

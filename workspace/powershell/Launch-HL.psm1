
function copyDistributionFiles {
    param (
        $rootDir,
        $redistDir,
        $redisthddir,
        $redistSpDir,
        $iceDir,
        $icehddir,
        $iceSpDir,
        $detailedTextures
    )

    Write-Output "Copying distribution files..."

    Remove-Item $iceDir\\* -Recurse -Force -ErrorAction Ignore
    Remove-Item $icehddir\\* -Recurse -Force -ErrorAction Ignore
    Remove-Item $iceSPDir\\* -Recurse -Force -ErrorAction Ignore
    if (!(Test-Path $iceDir)) {
        New-Item -ItemType directory -Path $iceDir
    }
    if (!(Test-Path $icehddir)) {
        New-Item -ItemType directory -Path $icehddir
    }
    if (!(Test-Path $iceSpDir)) {
        New-Item -ItemType directory -Path $iceSpDir
    }
    Copy-Item $rootDir\libs\dlls\ice.dll $redistDir\dlls
    Copy-Item $rootDir\libs\dlls\ice.dll $redistSpDir\dlls
    Copy-Item $rootDir\libs\dlls\grave_bot.dll $redistDir\dlls
    Copy-Item $rootDir\libs\dlls\grave_bot_mm.dll $redistDir\dlls
    Copy-Item $rootDir\libs\cl_dlls\client.dll $redistDir\cl_dlls
    Copy-Item $redistdir\\* $iceDir -Recurse -Force
    Copy-Item $redisthddir\\* $icehddir -Recurse -Force
    Copy-Item $redistSpDir\\* $iceSpDir -Recurse -Force

    if ($detailedTextures -eq $true) {
        $detailedTexturesDir = "$rootDir\detailed-textures"
        Write-Output "Including detailed textures..."
        Copy-Item -Recurse -Force $detailedTexturesDir\maps $iceDir
        [void](New-Item -ItemType directory -Path $iceDir\gfx\detail)
        Copy-Item -Recurse -Force $detailedTexturesDir\gfx\detail $iceDir\gfx
        Copy-Item -Recurse -Force $detailedTexturesDir\detailed_textures_beta2_readme.txt $iceDir
        Write-Output "Done including detailed textures."
    }

    Write-Output "Done with distribution files."
}

function unzipDistributionFiles {
    param (
        $rootDir,
        $hldir,
        $iceDir,
        $icehddir
    )

    Write-Output "Unzipping distribution files..."

    Remove-Item $iceDir\\* -Recurse -Force -ErrorAction Ignore
    Remove-Item $icehddir\\* -Recurse -Force -ErrorAction Ignore
    if (!(Test-Path $iceDir)) {
        New-Item -ItemType directory -Path $iceDir
    }
    if (!(Test-Path $icehddir)) {
        New-Item -ItemType directory -Path $icehddir
    }

    Expand-Archive -LiteralPath $rootDir\cold-ice-remastered-git-unknown.zip -DestinationPath $hlDir

    Write-Output "Done with unzipping distribution files."
}

function Launch-HL {
    param (
        $botcount,
        $hdModels,
        $map,
        $hlDir,
        $hlExe,
        $gameParameters,
        $gameFolder
    )

    $players = $botcount + 2
    $hlexe = ".\$hlExe"
    $startProgram = "$hlexe $gameParameters -game $gameFolder +developer 2 " `
                    + " +log on +sv_lan 1 +map $map +deathmatch 1 " `
                    + " +maxplayers $players"

    # Set hdmodels or +_sethdmodels <0 or 1>
    Get-ItemProperty -Path HKCU:\Software\Valve\Half-Life\Settings
    Set-ItemProperty -Path HKCU:\Software\Valve\Half-Life\Settings -Name hdmodels -Value $hdModels

    # https://developer.valvesoftware.com/wiki/Command_Line_Options
    Set-Location -Path $hlDir
    $out = iex $startProgram | Out-String

    if (!$?) {
        echo $out
        echo "Something went wrong with Half-Life. Exit code: $?"
        exit -1
    }
}

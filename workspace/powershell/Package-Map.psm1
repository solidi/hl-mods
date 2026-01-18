Import-Module $PSScriptRoot\Git-Utils.psm1 -Force -DisableNameChecking

function Copy-ResAssets {
    param (
        [string]$mapBspPath,
        [string]$redistDir,
        [string]$tempRoot
    )

    # Derive .res file path from .bsp path
    $resFilePath = $mapBspPath -replace '\.bsp$', '.res'
    
    if (-not (Test-Path $resFilePath)) {
        Write-Host "  No .res file found: $resFilePath"
        return
    }

    Write-Host "Processing .res file: $resFilePath"

    $resLines = Get-Content -Path $resFilePath -Encoding UTF8 -ErrorAction SilentlyContinue
    
    foreach ($line in $resLines) {
        # Skip comments and empty lines
        if ($line -match '^\s*//|^\s*$') {
            continue
        }
        
        # Skip .wad files
        if ($line -imatch '\.wad$') {
            continue
        }
        
        # Extract asset path
        $assetPath = $line.Trim()
        if ($assetPath) {
            # Validate asset path to prevent path traversal attacks
            if ($assetPath -match '\.\.|^/|^\\|:') {
                Write-Host "  Skipping potentially malicious path: $assetPath" -ForegroundColor Red
                continue
            }
            
            # Source file in redist directory
            $sourceFile = Join-Path $redistDir $assetPath
            
            # Verify the resolved source path is still within the redist directory
            $resolvedSourcePath = [System.IO.Path]::GetFullPath($sourceFile)
            $resolvedRedistPath = [System.IO.Path]::GetFullPath($redistDir).TrimEnd([System.IO.Path]::DirectorySeparatorChar, [System.IO.Path]::AltDirectorySeparatorChar) + [System.IO.Path]::DirectorySeparatorChar
            if (-not $resolvedSourcePath.StartsWith($resolvedRedistPath, [StringComparison]::OrdinalIgnoreCase)) {
                Write-Host "  Skipping path outside redist directory: $assetPath" -ForegroundColor Red
                continue
            }
            
            if (Test-Path $sourceFile) {
                # Destination file in temp directory
                $destFile = Join-Path $tempRoot $assetPath
                
                # Verify the resolved destination path is still within the temp directory
                $resolvedDestPath = [System.IO.Path]::GetFullPath($destFile)
                $resolvedTempPath = [System.IO.Path]::GetFullPath($tempRoot).TrimEnd([System.IO.Path]::DirectorySeparatorChar, [System.IO.Path]::AltDirectorySeparatorChar) + [System.IO.Path]::DirectorySeparatorChar
                if (-not $resolvedDestPath.StartsWith($resolvedTempPath, [StringComparison]::OrdinalIgnoreCase)) {
                    Write-Host "  Skipping path outside temp directory: $assetPath" -ForegroundColor Red
                    continue
                }
                
                # Create destination directory if it doesn't exist
                $destDir = Split-Path -Parent $destFile
                if (-not (Test-Path $destDir)) {
                    New-Item -ItemType Directory -Force -Path $destDir | Out-Null
                }
                
                # Copy the file
                Copy-Item -Path $sourceFile -Destination $destFile -Force
                Write-Host "  Copied: $assetPath"
            } else {
                Write-Host "  Asset not found: $sourceFile" -ForegroundColor Yellow
            }
        }
    }
}

function Copy-DetailTextures {
    param (
        [string]$mapName,
        [string]$detailedTexturesDir,
        [string]$tempGfxDetail,
        [string]$tempMaps
    )

    $detailTxtPath = Join-Path $detailedTexturesDir (Join-Path 'maps' "$($mapName)_detail.txt")
    Write-Host "Looking for detail texture file: $detailTxtPath"
    
    if (Test-Path $detailTxtPath) {
        Write-Host "Found detail texture file, processing..."
        $detailLines = Get-Content -Path $detailTxtPath -ErrorAction SilentlyContinue
        $detailSourceDir = Join-Path $detailedTexturesDir (Join-Path 'gfx' 'detail')
        
        foreach ($line in $detailLines) {
            # Match lines containing detail/textureName pattern (without .tga extension in the file)
            if ($line -match 'detail/([^\s]+)') {
                $textureName = $matches[1]
                $detailTgaPath = Join-Path $detailSourceDir "$textureName.tga"
                if (Test-Path $detailTgaPath) {
                    Copy-Item -Path $detailTgaPath -Destination $tempGfxDetail -Force
                    Write-Host "  Copied detail texture: $textureName.tga"
                } else {
                    Write-Host "  Detail texture not found: $detailTgaPath"
                }
            }
        }
        
        # Copy the _detail.txt file itself to $tempMaps
        Copy-Item -Path $detailTxtPath -Destination $tempMaps -Force
        Write-Host "  Copied detail texture mapping file to maps folder"
    } else {
        Write-Host "  No detail texture file found for this map"
    }
}

function New-MapReadme {
    param (
        [string]$mapName,
        [string]$destPath
    )

    $readmeContent = @(
        "Cold Ice Remastered Map: $mapName",
        "https://www.moddb.com/mods/cold-ice-remastered",
        "",
        "This map is an original map (or reskin) compiled at high resolution.",
        "See the text file within the maps/ for more information on this wondrous level."
    )

    $readmeContent -join "`r`n" | Out-File -FilePath $destPath -Encoding UTF8
}

function Remove-EmptyDirectories {
    param (
        [string[]]$directories
    )

    foreach ($dir in $directories) {
        if (Test-Path $dir) {
            $hasFiles = Get-ChildItem -Path $dir -Recurse -Force -File -ErrorAction SilentlyContinue | Select-Object -First 1
            if (-not $hasFiles) {
                Remove-Item -Recurse -Force -ErrorAction SilentlyContinue $dir
                Write-Host "Removed empty folder: $dir"
            }
        }
    }
}

function Package-Map {
    param (
        [string]$mapName,
        [string]$rootDir,
        [string]$redistDir,
        [string]$detailedTexturesDir
    )

    if (-not (Get-Module -ListAvailable -Name '7Zip4PowerShell')) {
        Install-Module 7Zip4PowerShell -MinimumVersion 2.2.0 -Scope CurrentUser -Force -Verbose
    }
    Import-Module 7Zip4PowerShell -Force -ErrorAction Stop

    # Clean temp root directory before copying
    if (Test-Path $env:TEMP) {
        Get-ChildItem -Path $env:TEMP -ErrorAction SilentlyContinue | 
            Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
    }

    # Create temporary directories
    $tempMaps = Join-Path $env:TEMP 'maps'
    $tempOverviews = Join-Path $env:TEMP 'overviews'
    $tempGfxEnv = Join-Path $env:TEMP 'gfx\env'
    $tempGfxDetail = Join-Path $env:TEMP 'gfx\detail'
    New-Item -ItemType Directory -Force -Path $tempMaps, $tempOverviews, $tempGfxEnv, $tempGfxDetail | Out-Null

    Write-Host "`nPackaging map: $mapName"
    Write-Host "================================"

    # Copy compiled map files from redist
    Write-Host "`nCopying compiled map files..."
    $redistMapsDir = Join-Path $redistDir 'maps'
    if (Test-Path $redistMapsDir) {
        Get-ChildItem -Path $redistMapsDir -Filter "$($mapName).*" -File -ErrorAction SilentlyContinue |
            ForEach-Object { 
                Copy-Item -Path $_.FullName -Destination $tempMaps -Force
                Write-Host "  Copied: $($_.Name)"
            }
    }

    $mapBspPath = Join-Path $redistMapsDir "$mapName.bsp"

    # Copy assets from .res file
    Write-Host "`nProcessing .res assets..."
    Copy-ResAssets -mapBspPath $mapBspPath -redistDir $redistDir -tempRoot $env:TEMP

    # Process detail textures
    Write-Host "`nProcessing detail textures..."
    Copy-DetailTextures -mapName $mapName -detailedTexturesDir $detailedTexturesDir -tempGfxDetail $tempGfxDetail -tempMaps $tempMaps

    # Create readme
    Write-Host "`nCreating readme..."
    $readmePath = Join-Path $env:TEMP "${mapName}_readme.txt"
    New-MapReadme -mapName $mapName -destPath $readmePath

    # Build package root
    Write-Host "`nBuilding package structure..."
    $packageRoot = Join-Path $env:TEMP $mapName
    Remove-Item -Recurse -Force -ErrorAction SilentlyContinue $packageRoot
    New-Item -ItemType Directory -Force -Path $packageRoot | Out-Null

    # Copy prepared folders to package root
    Copy-Item -Recurse -Force -ErrorAction SilentlyContinue $tempMaps (Join-Path $packageRoot 'maps')
    Copy-Item -Recurse -Force -ErrorAction SilentlyContinue (Join-Path $env:TEMP 'gfx') (Join-Path $packageRoot 'gfx')
    Copy-Item -Recurse -Force -ErrorAction SilentlyContinue $tempOverviews (Join-Path $packageRoot 'overviews')

    # Copy additional asset folders from .res processing (sound, sprites, models, etc.)
    $additionalFolders = @('sound', 'sprites', 'models')
    foreach ($folder in $additionalFolders) {
        $sourceFolder = Join-Path $env:TEMP $folder
        if (Test-Path $sourceFolder) {
            Copy-Item -Recurse -Force -ErrorAction SilentlyContinue $sourceFolder (Join-Path $packageRoot $folder)
            Write-Host "  Copied $folder folder to package"
        }
    }

    Copy-Item -Force -ErrorAction SilentlyContinue $readmePath (Join-Path $packageRoot "${mapName}_readme.txt")

    # Clean up empty directories
    Write-Host "`nCleaning up empty directories..."
    $gfxDir = Join-Path $packageRoot 'gfx'
    $gfxEnvDir = Join-Path $gfxDir 'env'
    $gfxDetailDir = Join-Path $gfxDir 'detail'
    Remove-EmptyDirectories -directories @($gfxDetailDir, $gfxEnvDir, $gfxDir)

    # Create 7z archive
    Write-Host "`nCreating archive..."
    $gitHash = Git-Hash -shortHash $true
    Write-Host "Git hash: $gitHash"
    
    $sevenArchivePath = Join-Path $rootDir "${mapName}-${gitHash}.7z"
    
    if (Test-Path $sevenArchivePath) {
        Remove-Item -Force -ErrorAction SilentlyContinue $sevenArchivePath
    }

    try {
        Write-Host "Archive path: $sevenArchivePath"
        Compress-7Zip -Path $packageRoot -ArchiveFileName $sevenArchivePath -ErrorAction Stop
        Write-Host "Archive created successfully"
    } catch {
        Throw "Failed to create .7z archive: $($_.Exception.Message)"
    }

    # Verify archive was created
    if (Test-Path $sevenArchivePath) {
        $fileSize = (Get-Item $sevenArchivePath).Length / 1MB
        Write-Host "Archive size: $([math]::Round($fileSize, 2)) MB"
        Write-Host "`nPackage completed: $sevenArchivePath"
    } else {
        Throw "Archive was not created at expected location: $sevenArchivePath"
    }

    # Clean up temp files
    Remove-Item -Recurse -Force -ErrorAction SilentlyContinue $packageRoot
}

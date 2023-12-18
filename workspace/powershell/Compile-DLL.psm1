
function Git-Hash {
    try {
        $commitHash = (git rev-parse HEAD).Substring(0,7)
    } catch {
        $commitHash = "unknown"
    }

    return $commitHash
}

function Compile-DLL {
    param (
        $msBuild,
        $slnpath,
        $dllname,
        $buildConfiguration,
        $definitions,
        $rebuildall
    )

    [string]$grapplinghook = "GRAPPLING_HOOK"
    $preprocess = "`"$definitions`""
    $gitHash = Git-Hash
    $buildValues = if ($gitHash -ne "unknown") { "GIT=\`"$gitHash\`"" }

    echo "Compiling dll $slnpath > $dllname.dll..."
    # https://docs.microsoft.com/en-us/visualstudio/msbuild/msbuild-command-line-reference?view=vs-2019
    try {
        $out = & $msBuild $slnpath /t:"$rebuildall" `
                    /p:NoWarn=C4996 `
                    /p:Configuration=$buildConfiguration `
                    /p:GrapplingHook=$grapplinghook `
                    /p:Weapons=$preprocess `
                    /p:BuildValues=$buildValues `
                    | Out-String
    } catch {
        Write-Error "$out> Could not compile $dllname.dll`nReason: $_.Exception.Message"
        exit
    }

    if ($out -like "*FAILED*") {
        Write-Error "$out> Could not compile $dllname.dll."
        exit
    }

    if ($out -match '^[1-9]\d* Error') {
        Write-Error "$out> Could not compile $dllname.dll."
        exit
    }
}

function Compile-Exe {
    param (
        $msBuild,
        $slnPath,
        $exeName,
        $buildConfiguration,
        $rebuildAll
    )

    echo "Compiling exe $slnPath > $exeName.exe..."

    try {
        $out = & $msBuild $slnpath /t:"$rebuildAll" /p:Configuration=$buildConfiguration | Out-String
        if (!$?) {
            throw
        }
    } catch {
        Write-Error "$out> Could not compile $exeName.exe`nReason: $_.Exception.Message"
        exit
    }

    if ($out -like "*FAILED*") {
        Write-Error "$out> Could not compile $exeName.exe."
        exit
    }
}

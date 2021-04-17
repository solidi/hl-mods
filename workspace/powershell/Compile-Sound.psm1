
function Compile-Sound {
    param (
        $bindir,
        $redistDir,
        $soundDir,
        $target,
        [float]$volume,
        $outsound,
        $type="wav",
        [int]$trimfrom=0,
        [int]$trimto=0
    )

    $trimcmd = ""
    if ($trimto -gt 0) {
        $trimcmd = "-ss $trimfrom -to $trimto"
    }

    if ($type -eq "mp3") {
       $typecmd = "-acodec libmp3lame"
    } else {
        $typecmd = "-ar 22050 -ac 1 -acodec pcm_u8 "
    }

    Set-Location -Path $binDir
    echo "Converting sound $outsound..."
    $in = ".\ffmpeg -y -i $soundDir\$target " `
          + "$typecmd " `
          + "-filter:a volume=$volume " `
          + "$trimcmd " `
          + "-hide_banner -loglevel error " `
          + "$redistDir\$outsound"

    $out = iex $in | Out-String
    if ($lastexitcode -ne 0) {
        echo "$out> Could not convert sound ${target}. Exit code: ${lastexitcode}"
        exit
    }
}

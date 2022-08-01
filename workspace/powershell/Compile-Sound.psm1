
function Compile-Sound {
    param (
        $bindir,
        $redistDir,
        $soundDir,
        $target,
        $volume,
        $outsound,
        $type="wav",
        [float]$trimfrom=0,
        [float]$trimto=0
    )

    $trimcmd = ""
    if ($trimto -gt 0) {
        $trimcmd = "-ss $trimfrom -to $trimto"
    }

    if ($type -eq "mp3") {
       $typecmd = "-acodec libmp3lame"
    } elseif ($type -eq "wav") {
        $typecmd = "-ar 22050 -ac 1 -acodec pcm_u8 "
    } else {
        Write-Error "Invalid sound file type $type."
        exit
    }

    Set-Location -Path $binDir
    echo "Converting sound $outsound..."
    $in = ".\ffmpeg -y -i $soundDir\$target " `
          + "$typecmd " `
          + "-filter:a volume=$volume " `
          + "$trimcmd " `
          + "-hide_banner -loglevel error " `
          + "$redistDir\$outsound"
    echo "command: $in"
    #+ "-af `"firequalizer=gain_entry='entry(0,8);entry(250,4);entry(1000,-8);entry(4000,0);entry(16000,-8)'`" " `

    $out = iex $in | Out-String
    if ($lastexitcode -ne 0) {
        echo "$out> Could not convert sound ${target}. Exit code: ${lastexitcode}"
        exit
    }
}


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

    $soundTimestamp = (Get-Item $redistDir\$outsound -ErrorAction Ignore).LastWriteTime
    $lastestSourceFileStamp = 0;
    Get-ChildItem $soundDir\$target | Foreach-Object {
        if ($_.LastWriteTime -gt $lastestSourceFileStamp) {
            $lastestSourceFileStamp = $_.LastWriteTime
        }
    }
    echo "$target source files: $lastestSourceFileStamp >? sound file: $soundTimestamp"

    if ($lastestSourceFileStamp -gt $soundTimestamp) {
        $rmsmax = -4
        $rmsmin = -67

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
        Write-Output "Converting sound $outsound..."
        $in = ".\ffmpeg -y -i $soundDir\$target " `
            + "$typecmd " `
            + "-filter:a volume=$volume " `
            + "$trimcmd " `
            + "-hide_banner -loglevel error " `
            + "$redistDir\$outsound"
        Write-Output "command: $in"
        #+ "-af `"firequalizer=gain_entry='entry(0,8);entry(250,4);entry(1000,-8);entry(4000,0);entry(16000,-8)'`" " `

        $out = iex $in | Out-String
        if ($lastexitcode -ne 0) {
            Throw "$out> Could not convert sound ${target}. Exit code: ${lastexitcode}"
        }

        Write-Output "Converting sound $outsound..."
        $in = ".\ffmpeg -i $redistDir\$outsound -af astats=metadata=1:reset=1,ametadata=print:key=lavfi.astats.Overall.RMS_level -f null - 2>&1"
        $out = Invoke-Expression -Command $in
        $pattern = ".*RMS peak dB: (-?[0-9]\d*\.\d+)"
        $MatchList = [regex]::Matches($out, $pattern)

        foreach ($Match in $MatchList) {
            for ($i = 1; $i -lt $Match.Groups.Count; $i++) {
                # "RMS is: $($Match.Groups[$i].Value)"
                $rms = [int]$($Match.Groups[$i].Value)
                if ($rms -le $rmsmin -Or $rms -ge $rmsmax) {
                    Throw "$out> RMS is out of bounds - RMS average is ${rms}."
                }
            }
        }
    }
}

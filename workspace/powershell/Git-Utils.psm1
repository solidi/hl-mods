
function Git-Head-Branch-Name {
    $branchName = "unknown-head-branch"

    try {
        $branchName = (git remote show origin | grep 'HEAD branch' | cut -d' ' -f5)
    } catch {
        Write-Error "git is unavailable"
    }

    return $branchName
}

function Git-Current-Branch-Name {
    $branchName = "unknown-current-branch"

    try {
        $branchName = (git rev-parse --abbrev-ref HEAD)
    } catch {
        Write-Error "git is unavailable"
    }

    return $branchName
}

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

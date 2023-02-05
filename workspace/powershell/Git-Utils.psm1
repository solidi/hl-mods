
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


function Test-Manifest {
    param (
        $manifest,
        $target
    )

    # Read $mainfest files to directory
    $files = Get-Content -Path $manifest
    Set-Location -Path $target
    foreach ($file in $files) {
        echo "locating $file in directory..."
        if (!(Test-Path "${file}")) {
            Throw "Could not find $file in $target"
        }
    }

    # Read directory files to $manifest
    $rawfiles = Get-ChildItem -Path $target -Recurse
    foreach ($file in $rawfiles) {
        $fileName = $file.FullName.Replace("$target\","")
        echo "locating $file in $manifest..."
        if (!$files.Contains($fileName)) {
            Throw "Could not find $fileName in $manifest"
        }
    }
}


function Launch-HL {
    param (
        $botcount,
        $hdModels,
        $map,
        $hlDir,
        $gameFolder
    )

    $players = $botcount + 2
    $hlexe = "${hlDir}\hl.exe"

    # Set hdmodels or +_sethdmodels <0 or 1>
    Get-ItemProperty -Path HKCU:\Software\Valve\Half-Life\Settings
    Set-ItemProperty -Path HKCU:\Software\Valve\Half-Life\Settings -Name hdmodels -Value $hdModels

    # https://developer.valvesoftware.com/wiki/Command_Line_Options
    $out = & $hlexe `
            -console -dev -condebug `
            -game $gameFolder `
            -windowed -gl -w 640 -h 480 `
            +developer 2 +log on `
            +sv_lan 1 +map $map +deathmatch 1 +maxplayers $players | Out-String

    if (!$?) {
        echo $out
        echo "Something went wrong with Half-Life. Exit code: $?"
        exit -1
    }
}

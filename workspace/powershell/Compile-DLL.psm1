
function Compile-DLL {
    param (
        $slnpath,
        $dllname,
        $buildConfiguration,
        $rebuildall
    )

    [string]$grapplinghook = "GRAPPLING_HOOK"
    [string]$weaponvest = "VEST"
    [string]$weaponhandgun = "SILENCER"
    [string]$weaponclustergrenades = "CLUSTER_GRENADES"
    [string]$weaponcrowbar = "CROWBAR"
    [string]$weaponknife = "KNIFE"
    [string]$weaponrpg = "RPG"
    [string]$weapontripmine = "TRIPMINE"
    [string]$weaponchumtoad = "CHUMTOAD"
    [string]$weaponsniperrifle = "SNIPER_RIFLE"
    [string]$weaponboltgun = "BOLT_GUN"
    [string]$weaponrailgun = "RAILGUN"

    #$msdev = "C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\MSBuild\Current\Bin\MSBuild"
    $msdev = "C:\BuildTools\MSBuild\Current\Bin\MSBuild"

    echo "Compiling dll $slnpath > $dllname.dll..."
    # https://docs.microsoft.com/en-us/visualstudio/msbuild/msbuild-command-line-reference?view=vs-2019
    $out = & $msdev $slnpath /t:"$rebuildall" `
                    /p:Configuration=$buildConfiguration `
                    /p:GrapplingHook=$grapplinghook `
                    /p:Vest=$weaponvest `
                    /p:Silencer=$weaponhandgun `
                    /p:ClusterGrenades=$weaponclustergrenades `
                    /p:Knife=$weaponknife `
                    /p:Crowbar=$weaponcrowbar `
                    /p:Rpg=$weaponrpg `
                    /p:Tripmine=$weapontripmine `
                    /p:Chumtoad=$weaponchumtoad `
                    /p:SniperRifle=$weaponsniperrifle `
                    /p:Boltgun=$weaponboltgun `
                    /p:Railgun=$weaponrailgun `
                    | Out-String

    if ($lastexitcode -ne 0) {
        echo "$out> Could not compile $dllname.dll. Exit code: ${lastexitcode}"
        exit
    }

    if ($out -match '^[1-9]\d* Error') {
        echo "$out> Could not compile $dllname.dll."
        exit
    }
}

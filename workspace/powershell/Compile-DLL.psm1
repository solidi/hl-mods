
function Compile-DLL {
    param (
        $msBuild,
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
    [string]$weaponcannon = "CANNON"

    echo "Compiling dll $slnpath > $dllname.dll..."
    # https://docs.microsoft.com/en-us/visualstudio/msbuild/msbuild-command-line-reference?view=vs-2019
    try {
        $out = & $msBuild $slnpath /t:"$rebuildall" `
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
                    /p:Cannon=$weaponcannon `
                    | Out-String
    } catch {
        Write-Error "$out> Could not compile $dllname.dll`nReason: $_.Exception.Message"
        exit
    }

    if ($out -match '^[1-9]\d* Error') {
        echo "$out> Could not compile $dllname.dll."
        exit
    }
}

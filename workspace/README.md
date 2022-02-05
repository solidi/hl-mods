# Work for Cold Ice Remastered

This is the directory for all assets of Cold Ice Remastered, including its submodule for game libraries. Building is holistic (all assets are built from sources). It is heremetic for all small utils.

## Dependencies Needed

1. See `.github/workflows/packacge.yml` for full details on how its built on a remote machine.
1. All valve/mod small utils are built or included in pipeline (for recombination experimentation, e.g. changes to studiomdl can automatically rebuild models.)
1. Two dependenices are required
    1. On Windows (10, or 11), install portable [Powershell 7.2.0+](https://github.com/PowerShell/PowerShell/releases/tag/v7.2.1).
    1. MSVC 2019+ or Buildtools 16+
        1. Build tools:
            1. `--add Microsoft.VisualStudio.Component.VC.Tools.x86.x64`
            1. `--add Microsoft.VisualStudio.Component.Windows10SDK.19041`

## To Build

1. Clone repo, and all its submodules.
1. Create config file for switches in `workspace/`
```powershell
# Example
$Config = @{ 
    'projectName' = 'Cold Ice Remastered'
    'gameFolder' = 'ice_beta1'
    'binDir' = 'Z:\workspace\bin'
    'msBuild' = 'C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\MSBuild\Current\Bin\MSBuild'
    'defintions' = 'VEST;SILENCER;CLUSTER_GRENADES;CROWBAR;KNIFE;RPG;TRIPMINE;CHUMTOAD;SNIPER_RIFLE;BOLT_GUN;RAILGUN;CANNON;DECOY;MAG60;CHAINGUN;GLAUNCHER;SMG;USAS;FISTS;WRENCH;SNOWBALL;CHAINSAW;_12GAUGE;REVOLVER;EGON;M16;SHOTGUN;NUKE;GAUSS;HIVEHAND;SNARK;DEAGLE;DUALDEAGLE;DUALRPG;DUALSMG;DUALWRENCH'
    'hlDir' = 'C:\xash3d-fwgs-win32-i386'
    'hlExe' = 'xash3d.exe'
    'gameParameters' = '-console -dev 5 -log -windowed -width 640 -height 480'
}
```
1. Execute each script `Build-*.ps1 -ConfigFile <your file>`
    1. Start with `Build-Tools.ps1 -ConfigFile <your file>` first. Then run
        1. `Build-Maps.ps1 -ConfigFile <your file>`
        1. `Build-Models.ps1 -ConfigFile <your file>`
        1. `Build-Sprites.ps1 -ConfigFile f<your file>ile`
        1. `Build-Sound.ps1 -ConfigFile <your file>`
        1. `Build-Windows.ps1 -ConfigFile <your file>`
1. Execute `Start-Windows.ps1 -ConfigFile <your file>` to run

## Build for Linux and MacOS

1. At this time, only on Windows can you build all assets (maps, models, sprites, etc). Do above first in a shared drive. 
1. One can build Linux libs or MacOS dlybs using the scripts `build-linux.sh` and `build-mac.sh` on a native machine
1. Run `start-ubuntu.sh` to copy and run the package on Ubuntu.

## Independent OS Building with Docker 

Docker support is available in `docker/`. However its building time is very slow (30 minutes to an hour) for the full pipeline, so was abandoned. It remains a work in progress. Your milage may vary.

## Support Scripts

1. Execute `Copy-Distribution.ps1` to copy files to game directory
1. Execute `Build-Release.ps1` to generated a distributable zip file with pak file.

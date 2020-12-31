# Learnings

1. An update to Half-Life model viewer v1.24 is Jed's Half-Life Model Viewer v1.36
1. Gimp 2.8 and 2.10 does not export 8-bit bmp files correctly so that Half-Life/Jed's model viewer will import the files.
    Use IrFanView to convert the bmps.
1. MSVC 6 can be run from the [command line](https://docs.microsoft.com/en-us/previous-versions/visualstudio/visual-studio-6.0/aa699274(v=vs.60)) using the msdev executable.
1. Git submodules are repos within repos. Checkout branch in the submodule folder, commit, and then update the outter repo git commit reference.
1. Continue to reduce the pipeline time to get to test the game changes.
1. Goldsrc requires gcc 4.x to to compile correctly. However, macOS Catalina has removed the header source files for compilation from the xcode toolchain.
1. `user.scr` is for configuration of advanced player options. `settings.scr` is for advanced server options. [Valves wiki](https://developer.valvesoftware.com/wiki/Non-code_mod_settings) is partially accurate for GoldSrc games.
1. `mapcycle.txt` is used to declare available maps. A map list will appear as soon as one map is added to `maps/` folder in the mod game launch menu.
1. `kb_act.lst` and `kb_def.lst` files coordinate keyboard bindings.
1. Some important [quake tools](https://quakewiki.org/wiki/Quake_tools) that can be useful for pipelining the work.
1. Learned about `dev_overview` in the HLSDK 2.3 docs titled `HLTV`. In game, this mode provides a visual overview snapshot for use in spectate mode.
1. Can define macros in C using `#if !defined ( MACRO ) ... #define MACRO`.
1. Half-Life has enabled the use of client side messaging for weapons. See `cl_dll\ev_hldm.cpp` for details. This reduces network latency and use of server sided bandwidth.
1. Cannot search forked repos on github? This can cause a problem with searching deltas on the forked repo. Only [forks with more stars](https://docs.github.com/en/free-pro-team@latest/github/searching-for-information-on-github/searching-code) are searchable on GitHub.
1. Important conditional information for Windows batch scripting can be [found here](https://ss64.com/nt/errorlevel.html) and [here](https://stackoverflow.com/questions/1164049/batch-files-error-handling).
1. Here is a [good list](https://sr-team.clan.su/K_stat/hlcommandsfull.html) of console variables cvars for half-life.
1. Here is a [good list](https://developer.valvesoftware.com/wiki/Command_Line_Options) of Half-Life executable parameters and switches.
1. Half-Life has entity limits, ex. `num_edicts <variable>` - Sets the entity limit for map/game entities (not temporary entities, which is still locked to 500). 900 is default. 4096 is a good limit, beyond that seems to cause hunk_alloc errors. Both clients and servers need matching values for best compatibility.
1. VAC means [Valve Anti-Cheat](https://developer.valvesoftware.com/wiki/Valve_Anti-Cheat).
1. Here is the [current liblist.gam format](https://developer.valvesoftware.com/wiki/The_liblist.gam_File_Structure) for Half-Life 1 mods.
1. cl_dll compile problems - things I've tried
    1. Compile debug and release
    1. Compile in MSVC directly and copy over
    1. Changed liblist.gam from type "multiplayer_only" to "singleplayer_only"
    1. [Followed this thread](https://github.com/ValveSoftware/halflife/issues/1610), added cg dlls, removed MousePointer virtual function declaration
1. In WindowsXP, to see file permissions, disable `Simpel File Share` in Explorer Options.
1. Will need to further investigate `edicts "2048"` in the `liblist.gam`cfile for more entities.
1. For modeling, "splines" are slats or spokes in a wheel. UWW is used as a metaphor for XYZ for texturing coordinates.
1. MSVC 6.0 `msdev` compilation is [attainable](https://stackoverflow.com/questions/19856468/running-visual-studio-6-c-in-windows-8-1) in Windows Pro 8.1. `msdev.exe` requires a rename to `msdev3.exe`
1. Here is a cool list of [dos console colors](https://stackoverflow.com/questions/29014820/color-echo-in-batch-files) when using the command `COLOR 3F`.
1. More info on creating [basic player config files](https://hldm.cz/how-to-create-config/) in Half-Life.
1. The current version of the [GoldSrc cl_dll](https://github.com/ValveSoftware/halflife) is not compatible with `1.1.0.0`.
1. Powershell has commands called `commandlets` that are long formed aliases like `Remove-Items` and `Copy-Items`
1. When compiling a reference model with `studiomdl`, to apply the chrome effect, the texture name must have `Chrome` in the filename. [It must also be 64x64.](https://forums.alliedmods.net/showthread.php?p=2322742)
1. In powershell, adding `-force` to any cmdlet makes things work.
1. Adding a git fork is straightforward, and more importantly, [fetching from upstream](https://garygregory.wordpress.com/2016/11/10/how-to-catch-up-my-git-fork-to-master/) is also painless.
1. How to use [passed parameters](https://www.red-gate.com/simple-talk/sysadmin/powershell/how-to-use-parameters-in-powershell/) in PowerShell.
1. How to set execution policy of powershell on the system [to run unsigned scripts](https://superuser.com/questions/106360/how-to-enable-execution-of-powershell-scripts).
1. Some of the [oddness explained](https://stackoverflow.com/questions/18877580/powershell-and-the-contains-operator) attempting equality operations in Powershell.
1. Syntax changes from cmd to powershell, [see here](https://www.meziantou.net/convert-cmd-script-to-powershell.htm). Here is a (style guide)[https://github.com/PoshCode/PowerShellPracticeAndStyle] to powershell.
1. Numerous [threads](https://stackoverflow.com/questions/3592851/executing-a-command-stored-in-a-variable-from-powershell) on [running](https://stackoverflow.com/questions/51690708/run-powershell-commands-sequentially-in-their-own-windows-and-prevent-them-from) exes [in powershell](https://stackoverflow.com/questions/1741490/how-to-tell-powershell-to-wait-for-each-command-to-end-before-starting-the-next). This was difficult to get right since we want to run the programs sequentially but not have to deal with Coammand Argument escaping.
1. 3D Acceleration on Windows 10 in virtual box causes wierd display behaviors. This includes the display properly to decrement over and over, locking the vm. [Transparency could be an issue](https://forums.virtualbox.org/viewtopic.php?f=2&t=98570), but will also need to activate windows.
1. Windows 10 transparency can be disabled by editing this registry key [HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize](https://www.tenforums.com/tutorials/5556-turn-off-transparency-effects-windows-10-a.html).

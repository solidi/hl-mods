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
1. Map compilation requires a lights.rad file, and here is [a community version](https://gamebanana.com/gamefiles/download/9025).
1. Here is a helpful [list of all entities](https://developer.valvesoftware.com/wiki/List_of_Half-Life_entities) in the Half-life game.
1. Registry keys for pre-steam Half-Life can [be found here](https://www.regfiles.net/registry/half-life-registry). For steam related keys, `hdmodels` is stored to switch  `CrashInitializingVideoMode` is [also of interest](https://github.com/ValveSoftware/halflife/issues/343). Items can be found in `Computer\HKEY_CURRENT_USER\Software\Valve\Half-Life\Settings`
1. Unsuccessful at unpacking the `gfx.wad` for Half-Life. I used both `hllib 118` and `hllib 246` from [nems tools](https://nemstools.github.io/subpages/Comments/HLLib.html). 118 extracted only some of the files. 246 crashed on both x86 and x64 on Windows 8.
1. Learned that `.lmp` files are [lump files](https://quakewiki.org/wiki/.lmp).
1. A [full listening of all cvars](https://developer.valvesoftware.com/wiki/Console_Command_List) in the Half-Life engine. This helped discover the cvar `+deathmatch 1`.
1. Use the `listenserver.cfg` to exec cvars that are required on every deathmatch.
1. #Valve string interpolation is provided in the [resource/valve.english.txt](https://github.com/SteamDatabase/GameTracking-CSGO/blob/master/csgo/resource/valve_english.txt) file.
1. A nice listing of bsp [map compilation warnings](https://www.slackiller.com/tommy14/errors.htm#swap).
1. For wad editing, I went with [HLLib](https://developer.valvesoftware.com/wiki/HLLib) 2.46 to extract out wad bmp files.
1. The [gfx file](http://quakeone.com/forum/quake-help/general-help/12956-anyone-have-experience-modifying-gfx-file) for half-life has a unique mapping for the console characters. I am unsure how to extract and recompile this file. Here is the [best example](https://www.betaarchive.com/forum/viewtopic.php?t=20106) of how to reconstruct the Half-Life gfx file.
1. Here is a good list of [wad editors](https://wiki.srb2.org/wiki/WAD_editors). Additionally, I tried [unwad](https://github.com/RomanHargrave/unwad/tree/master/release/windows), but [failed to unpack WAD3 format](https://forum.zdoom.org/viewtopic.php?f=4&t=52738).
1. [GDCC](https://github.com/DavidPH?tab=repositories) is the [latest toolchain](https://forum.zdoom.org/viewtopic.php?f=3&t=51947) to compile WAD2, but does not support WAD3.
1. When adding [preprocessor definitions](https://docs.microsoft.com/en-us/cpp/build/reference/d-preprocessor-definitions?view=msvc-160) like `CLIENT_WEAPONS`, always rebuild both libraries otherwise the flag will not work correctly.
1. On Windows 8 using the `Start-Job` cmdlet experienced a weird behaviro where I had to restart powershell to clear a missing `Compile-DLL` function reference.
1. "PM" means `player move` in Half-Life.
1. [Older versions of MSVC, including 2010, 2012, 2013, etc.](https://visualstudio.microsoft.com/vs/older-downloads/). The Half-Life SDK supports VS 2010 solution files.
1. Powershell 5.1 supports [zip](https://blog.netwrix.com/2018/11/06/using-powershell-to-create-zip-archives-and-unzip-files/) functionality using `Compress-Archive` and `Expand-Archive`. Download Powershell 5.1 from the [Windows Management Framework](https://www.microsoft.com/en-us/download/details.aspx?id=54616).
1. Use `Get-Host` to understand which version of PowerShell is running.
1. By creating the grappling hook, I've learned about origin, angles, and velocity setting.
1. Here is a [basic primer](https://www.educative.io/edpresso/what-are--sharpifndef-and--sharpdefine-used-for-in-cpp) on the use of `#ifdef` and `#ndef` usage in C++.
1. Attempted the use of  parallel processing for the powershell script using `start-job` [discussed here](https://stackoverflow.com/questions/4016451/can-powershell-run-commands-in-parallel). I had difficulty getting it run correctly, where `exit` did not abort the script, only the sub process. Will dig deeper on on to abort the script entirely.
1. `iex` [is an alias for](https://stackoverflow.com/questions/6338015/how-do-you-execute-an-arbitrary-native-command-from-a-string) `Invoke-Command` cmdlet. It can be used to pass in a full string to be executed.
1. [A primer](https://morgantechspace.com/2016/08/powershell-check-if-string-contains-word.html) on the use of string comparsions in PowerShell. Also see the `-match` parameter that takes in regex.
1. `UTIL_MakeVectors( anglesAim );` macro aligns the angles to the target of the current call, otherwise, angles are aligned to the last entity.
1. To wrap a command to numerous lines in Powershell, [use the grave](https://stackoverflow.com/questions/2608144/how-to-split-long-commands-over-multiple-lines-in-powershell/2608186) ` character.
1. To require a version running Powershell, use the `#Requires` [attribute here](https://stackoverflow.com/questions/36166262/powershell-version-check-prior-to-script-execution).
1. Learned abou C++ forward declaration. For instance, `class AClass` to promise to the compiler that the defintion will be defined later.
1. In powershell, the registry can be (directly edited)[https://docs.microsoft.com/en-us/powershell/scripting/samples/working-with-registry-keys?view=powershell-7.1] with the protocol HKLM (local machine), HKCU (current user), etc. [See here](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.management/set-itemproperty?view=powershell-7.1) for more information on how to edit.
1. Current notes on how to [move a submodule](https://stackoverflow.com/questions/4604486/how-do-i-move-an-existing-git-submodule-within-a-git-repository) and how to [delete a submodule](https://stackoverflow.com/questions/1260748/how-do-i-remove-a-submodule) from a git repository.
1. Started to look into bot implementations for Half-Life, and found this excellent resource called [Bots-United](http://www.bots-united.com/). Two bots, [grave_bot](http://gravebot.bots-united.com/?section=about) and [jk_botti](http://forums.bots-united.com/forumdisplay.php?f=83) look to fit the criteria, HLDM focused, git hosted, and fresh up to date commits.
1. MSVC++ 6.0 prevented a build due to endlines with the grave_bot.dsp file. I copied the dsp file from the original zip file, and then it built ok. See [this](https://stackoverflow.com/questions/5834014/lf-will-be-replaced-by-crlf-in-git-what-is-that-and-is-it-important) for more info on endlines.
1. `globalvars_t` reference is "stomped" on during each frame rendered. The result is when calculating angles, it is required to use macros such as `UTIL_MakeVectors` to capture the current reference. See `CRpg` for this comment.
1. Learned about gearbox Zoner's Half-Life Tools to compile maps [found here](http://zhlt.info/).
1. The cutting floor room [for Half-Life](https://tcrf.net/Half-Life_(Windows)) has documented excellent models, weapons, [textures](https://tcrf.net/Half-Life_(Windows)/Textures), and [sounds](https://tcrf.net/Half-Life_(Windows)/Sounds) for the Half-Life game.
1. Client hook message name has a maximum character limit. The use of `AnnounceWeapon` crashed the server.Keep under 10 characters.
1. `$externaltextures` is used to split the textures from a model for optimization purposes. In Half-Life it's mainly used for world models (`w_`). Textures [cannot be used](https://twhl.info/thread/view/19095) by other models.
1. Convert [references and addressof](https://stackoverflow.com/questions/19032461/convert-reference-to-pointer-representation-in-c) in C++, and interest suggestions of how to [intiatize a struct](https://stackoverflow.com/questions/11516657/c-structure-initialization).
1. Using [header guards](https://stackoverflow.com/questions/15042470/redefinition-of-struct-error-i-only-defined-it-once) can avoid recompilation of the same header file.
1. Copying a struct to a reference caused garbage data to be passed into CHudMessage. Must provide copy to the member class.
1. Learned about the Xash3D engine, which is a fully compatible HL assets engine, that will take in maps, models, etc. See [early documentation](https://documentation.help/Xash3D/documentation.pdf).
1. In the latest version of goldsource, it does not appear that fonts.wad is used.
1. To file archived files for Half-Life, including maps from Radium, and tools from Wavelength, [checkout this resource from dukeworld](http://dukeworld.duke4.net/planetquake/planethalflife/).
1. Documentation on the wad3 and sprite file format specifics that are used in Half-Life [can be found here](https://yuraj.ucoz.com/half-life-formats.pdf).
1. [Helpful thread](https://twhl.info/thread/view/19504) on the differences between enginefonts, vgui fonts, and everything inbetween.
1. A helpfull full compilation command guidelines to the qc files/smd/model making for Half-Life [can be found here](https://the303.org/tutorials/gold_qc.htm).
1. Updated compilation to Visual Studio 2019 and building on the command line [can be found here](https://social.msdn.microsoft.com/Forums/en-US/3ed198c7-756e-44f4-bfc8-de90b0faf798/how-to-build-c-program-from-command-line-for-vs-2019?forum=msbuild).
1. [This repro](https://github.com/Solokiller/halflife-updated/commit/e19fe4703583a7ef793034c2b119b884e8e97693) was helpful in understanding how to update `abs` in the upgrade to Visual Studio 2019.
1. A good thread on how to handle [the copy function](https://stackoverflow.com/questions/834270/visual-studio-post-build-event-copy-to-relative-directory-location) in visual studio 2019.
1. Changing values in a `SetThink` for client sided weapons will not reflect the value on the client.
1. Mirroring view models may not provide back polygons (back culling). Noted this on view models with Milkshape.
1. Animated sprites in Half-Life require 256 indexed color. If there is more than one frame, the same palette is used for all bmps. [IrfanView](https://www.irfanview.com/) is a good tool to export and import these plaettes.
1. Polygon count of Half-Life 1 to Half-Life 2 appears to be 5x-10x times. Here is [a source](https://developer.valvesoftware.com/wiki/Model_Creation_Overview) confirming poly counts.
1. Although original modeling doc states that p_model attachments can override attachments declared in a player model, this is not the case. In order to tweak the muzzleflash placements, [the player model muzzle flash event and its position attatchment](https://forums.alliedmods.net/showthread.php?t=309330) has to be edited and recompiled.
1. I learned at un-raring files on Macos requires a third party util. [I used an install from homebrew called unrar](https://github.com/Homebrew/discussions/discussions/285).
1. Learned about the updated `studiomdl.exe` update from Sven-Coop that improves the model compilation experience. [It can be downloaded here](https://www.gvme.org/1837).
1. `pev->body` group setting will work with v_weapon models, as long as each `SendWeaponAnim()` sends the body.
1. For humorous movie sound clips, check out [here](http://www.moviesoundclips.net/).
1. To convert sound effects for half-life, the easiest pipeline would be to use ffmpeg, with the example command: `./ffmpeg -i ../in.mp3 -ar 22000 -ac 1 -acodec pcm_u8  -filter:a "volume=1.0" ../out.wav`.
1. A [nice post](https://stackoverflow.com/questions/1878001/how-do-i-check-if-a-c-stdstring-starts-with-a-certain-string-and-convert-a) on how to check for pure substring comparsion in C++. Also `strncmp(str, substr, strlen(substr))`

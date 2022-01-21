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
1. Will need to [further investigate](https://www.moddb.com/mods/half-life-anti-climax/tutorials/fixing-ed-alloc-no-free-edicts) `edicts "2048"` in the `liblist.gam`cfile for more entities.
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
1. I learned how to stub out operators and primative types in C++. For instance, `CBaseEntity * EHANDLE::operator ->() { return NULL; }` and `EHANDLE::operator int () { return 0; }`. Primative types do not allow for typer qualifiers, and use of `operator` after scope.
1. How to use `texturegroup` with numerous skins [can be found here](https://developer.valvesoftware.com/wiki/$texturegroup).
1. `extern "C"` prevents the compiler for "mangling." So if you specify a function to be extern C, the compiler doesn't performs name mangling with it and it can be directly accessed using its symbol name as the function name.
1. Excellent walkthrough of all sprite types and their properties [can be found here](http://the303.org/tutorials/gold_sprite_p1.htm).
1. Excellent resource for all HLDM bot waypoints [can be found here](https://github.com/Bots-United/jk_botti/tree/master/addons/jk_botti/waypoints) at jk_botti repo. Do not use [this page](http://www.oocities.org/thesirclan/frames/hl.htm), as the waypoint for stalkyard caused a crash for `mp_teamplay`.
1. Very good resource on the details of the steampipe directory format. [See this article](https://developer.valvesoftware.com/wiki/GoldSource_SteamPipe_Directories) for <game>_hd and others. `-nohdmodels` can also be used for low res models.
1. ffmeg windows builds [can be found here](https://www.gyan.dev/ffmpeg/builds/).
1. Numerous important Half-Life tools and resources can be found [on this url](https://twhl.info/wiki/page/Tools_and_Resources).
1. To compile macOS dylibs, this project requires a legacy version of the SDK. Legacy verions of the SDK [can be found here](https://github.com/phracker/MacOSX-SDKs).
1. A useful [command guide](https://clang.llvm.org/docs/UsersManual.html#options-to-control-error-and-warning-messages) for all the switches for clang.
1. `libstdc++` has been removed in later versions of the MacOSX sdk since 10.9. Half-Life does not compile when switching from libstdc++ to `libc++` using `-stdlib=libc++`
1. Defining the macOS library for the mod includes `gamedll_osx` in the [liblist.gam file here](https://www.reddit.com/r/HalfLife/comments/c3j4sk/getting_science_and_industry_to_work_on_macbook/)
1. [Cross-compilation on docker](https://docs.conan.io/en/latest/howtos/run_conan_in_docker.html) appears to be a very good approach for building linux projects.
1. `malloc.h` is [not present on all systems](https://github.com/open62541/open62541/issues/834). Use `stdlib.h` where possible, and then use `__WIN32` to include `malloc.h` only when needed.
1. `script` is a command that captures all [console output to a file](https://askubuntu.com/questions/161935/how-do-i-log-all-input-and-output-in-a-terminal-session). It was useful when debuging g++.
1. A small list of interesting flags for `gcc` that was [used to suppress](https://stackoverflow.com/questions/3378560/how-to-disable-gcc-warnings-for-a-few-lines-of-code) verbose output.
1. `g++` less [than 6.3](https://github.com/Homebrew/homebrew-core/issues/4812) has a problem with `coal text` output stream.
1. The HUD in Half-Life is a linked list of components. To flag a component to draw, set `m_iFlags |= HUD_ACTIVE`, where `m_iFlags` is the component member variable.
1. `gamedll_linux “dlls/gravebot.so"` caused a 'Non-shared library' error, which had nothing to do with architecture compile, but instead had to do with the expected `"` was missing.
1. Here is an [important thread](https://steamcommunity.com/app/70/discussions/0/490123938425659006/) about the execution sequence of configuration files on the Half-Life Gold Source engine.
1. [This reference](https://developer.valvesoftware.com/wiki/SteamCMD) has information about the use of SteamCMD. This is a replacement to [HLDS](https://www.joe.to/cstrike/ents/command_line_options.html), and other utils.
1. I learned numerous basic points of linux operation. `sudo su -` to switch to root, `/media/` to see mapped drives, `/var/logs/` to see logs, `gparted` and `df -h` to resize a [vm drive](https://www.howtogeek.com/124622/how-to-enlarge-a-virtual-machines-disk-in-virtualbox-or-vmware/) when it [ran low](https://askubuntu.com/questions/101715/resizing-virtual-drive/558215#558215) on space, and `Cmd+H` in Nautilus to see hidden files.
1. A small article on how to run [Steam protocol](https://scrapmechanic.gamepedia.com/Launch_options) with options to Half-Life
1. A nice small article of [Linux on Steam](https://developer.valvesoftware.com/wiki/Steam_under_Linux).
1. To normalize the endlines of files between Windows and Linux, first set git configurations `git config --global core.eol lf` and `git config --global core.autocrlf false` and [follow this guide](https://gist.github.com/ajdruff/16427061a41ca8c08c05992a6c74f59e). [This thread](https://stackoverflow.com/questions/9976986/force-lf-eol-in-git-repo-and-working-copy) was also helpful.
1. See [this stackoverflow thread](https://stackoverflow.com/questions/1675351/typedef-struct-vs-struct-definitions) on how typedef and struct are used together
1. Learned about the `git add --patch` method for partial updates to files.
1. `dos2unix` is a small util that can handle file conversion of end lines.
1. ImageMagik has a util called [identify](https://imagemagick.org/script/identify.php) that was very hopefully in determinating that BMP3 was required for the transfer.
1. [This dev.to post](https://dev.to/serhatteker/changing-git-submodule-repository-to-other-url-branch-356p) was important in determining how best to rename a submodule url for git origin.
1. [This thread](https://stackoverflow.com/questions/18847145/loop-through-files-in-a-directory-using-powershell) with very helpful for looping through files in powershell.
1. For more learnings on [imageMagick](https://imagemagick.org/script/download.php) using negate, see this [legacy document](https://legacy.imagemagick.org/Usage/color_mods/#negate) and how to use the [BMP format tag](https://legacy.imagemagick.org/discourse-server/viewtopic.php?t=34554).
1. Here is an [excellent basic tutorial](http://homepage.eircom.net/~abyrne/Models/model9/tutorials_tut09.htm) on how to animate bones in MilkShape3d.
1. Docker runs its containers by using the kernel of the operating system it is running on. So, there will be no way to virtualize a container to run Windows applcations on macOS. See [this post](https://www.reddit.com/r/docker/comments/4re2fo/can_the_new_docker_for_windows_and_mac_allow_a/) for more information.
1. I learned about how to set the relative root path of the powershell shell by using [PSScriptRoot](https://stackoverflow.com/questions/5466329/whats-the-best-way-to-determine-the-location-of-the-current-powershell-script/5466355)
1. [A good post](https://www.baeldung.com/linux/use-command-line-arguments-in-bash-script) on the different commandline parameter options to accept input for bash scripts.
1. Docker can be used for reproducible build environments between developers. See [this thread](https://sweetcode.io/using-docker-reproducible-build-environments/) for details.
1. Docker [COPY](https://nickjanetakis.com/blog/docker-tip-2-the-difference-between-copy-and-add-in-a-dockerile) is used specifically for local files.
1. For the Linux builds, make sure to add the `-m32` [attribute](https://stackoverflow.com/questions/27733964/linking-kernel-i386-architecture-of-input-file-is-incompatible-with-i386x86-6) at the front of the parameters so that i386/32 bit compilation happens.
1. A good post on the [best practices](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/) of docker containers.
1. A technique to [add numerous directories](https://stackoverflow.com/questions/37789984/how-to-copy-folders-to-docker-image-from-dockerfile) from the host to a single docker image is to tar up the files and using `ADD` will extract those files to a folder.
1. A possible solution of running a macOS [virtual machine](https://github.com/AlexanderWillner/runMacOSinVirtualBox) on virtual box.
1. Use the `-f` option to [point to a dockerfile](https://stackoverflow.com/questions/17466699/not-able-to-build-a-specific-dockerfile) outside of the current root directory.
1. [Docker commands](https://blog.baudson.de/blog/stop-and-remove-all-docker-containers-and-images) to start, stop, and remove containers and their associated images.
1. Options [to explore](https://stackoverflow.com/questions/20813486/exploring-docker-containers-file-system) the structures of docker containers.
1. The scope resolution operator, `::`, when used by itself in front of a function call, forces the compiler to look in the [global scope](https://stackoverflow.com/questions/8937824/scope-resolution-operator-in-front-of-a-template-function-call-in-c), not the local scope. [This post](https://stackoverflow.com/questions/51062160/sc-create-binpath-error) was also helpful to get past the `sc.exe` issue.
1. An [excellent post](https://poweruser.blog/docker-on-windows-10-without-hyper-v-a529897ed1cc) on how to setup docker on windows without Hyper-V support.
1. I learned that there is a nested VT-x mode in virtualbox, [following this post](https://stackoverflow.com/questions/54251855/virtualbox-enable-nested-vtx-amd-v-greyed-out). This was critical for enabling linux docker on [VirtualBox VMs](https://www.tactig.com/enable-intel-vt-x-amd-virtualization-pc-vmware-virtualbox/). I used this command `VBoxManage modifyvm YourVirtualBoxName --nested-hw-virt on`.
1. To run docker on Windows machines prior to Windows 10, use the [Docker Toolbox](https://github.com/docker/toolbox/releases) project. To start the installation of the toolbox on a VM, use the `--virtualbox-no-vtx-check` option in `start.sh`. This [this thread](https://superuser.com/questions/1443294/docker-toolbox-doesnt-have-vt-x-amd-v-even-if-it-is-enabled) for details.
1. See this list of [microsoft window docker containers](https://hub.docker.com/_/microsoft-windows) and [their compatibility](https://docs.microsoft.com/en-us/virtualization/windowscontainers/deploy-containers/version-compatibility?tabs=windows-server-20H2%2Cwindows-10-20H2).
1. How to [disable](https://stackoverflow.com/questions/41128258/docker-virtual-box-vt-x-is-not-available-verr-vmx-no-vmx) Hyper-V on Windows, but this wasnt helpful in the docker intitive.
1. How to increase space on a [Windows Virtual Partition](https://www.techrepublic.com/article/how-to-increase-virtual-disk-size-when-running-windows-10-in-a-vm/). The key was to delete the restore partition, so the space is contiguous for formatting.
1. For [sharing multiple drives](https://stackoverflow.com/questions/18861834/mounting-multiple-volumes-on-a-docker-container/18861869) on docker. And for pathing oddities on Windows and sharing drives to Docker, [see this post](https://stackoverflow.com/questions/33312662/docker-toolbox-mount-file-on-windows). Finally, here is the thread on how [best to share](https://headsigned.com/posts/mounting-docker-volumes-with-docker-toolbox-for-windows/) a network partitioned drive on a Windows Virtual Machine.
1. Some good notes on [docker file](https://stackoverflow.com/questions/22049212/docker-copying-files-from-docker-container-to-host) sharing in the ecosystem.
1. `strtok` was used to tokenize a string for a console var setting. A copy of the class name was required to `GiveNamedItem` otherwise the weapon would not deploy.
1. Tommy14's [error list](http://www.slackiller.com/tommy14/errors.htm) is a very good resource to understand why compilation and map error detail.
1. Windows Subsystem for Linux 2 has a problem with VirtualBox. [See this github post](https://github.com/MicrosoftDocs/WSL/issues/798) as the latest info about the incompatibility.
1. A possible solution to run windows containers on macOS. See [this thread](https://stackoverflow.com/questions/42158596/can-windows-containers-be-hosted-on-linux#:~:text=No%2C%20you%20cannot%20run%20windows,can%20run%20Linux%20on%20Windows.&text=You%20can%20change%20between%20OS,the%20docker%20in%20tray%20menu.) for more detail using Vargant / Packer.
1. For debugging the number of current edicts, use the macro `NUMBER_OF_ENTITIES()` or the global parameter `gpGlobals->maxEntities`.
1. I learned that using the git patch tool for commits may require splitting hunks manually. See [this thread](https://stackoverflow.com/questions/56892981/how-to-solve-sorry-cannot-split-this-hunk) about "Sorry cannot split this hunk."
1. To show the full diff of a stash in git, use `git stash show -p`. See [this thread](https://stackoverflow.com/questions/3573623/is-it-possible-to-preview-stash-contents-in-git) as well.
1. An interesting read on how the Source engine implements the Server-Client networking architecture. See [this thread here](https://developer.valvesoftware.com/wiki/Source_Multiplayer_Networking).
1. To fake lag (and to test weapon prediction), use the command `fakelag` to simulate the behavior one would experience with a less than ideal ping.
1. Windows 8 does not support running native windows docker containers. [Support began](https://stackoverflow.com/questions/53310744/cant-switch-docker-os-on-window-8) with Server 2016 / Windows 10.
1. An interesting document on how to compile Half-Life 2 models [here](https://www.cs.vu.nl/~eliens/design/local/game/documents_modeling_files.html). Goves full breakdown of all formats.
1. An [excellent post](https://powershellexplained.com/2017-05-27-Powershell-module-building-basics/) on the breakdown of Powershell modules. Describes best practices for spliting up large scripts. Additionally [a post](https://stackoverflow.com/questions/53871494/how-to-disable-the-warning-about-unapproved-verbs-when-importing-modules/53871495) on unapproved verbs warning.
1. To runn ffmpeg on a docker container using servercore, there are two missing dlls that must be added. See [this thread](https://lists.ffmpeg.org/pipermail/ffmpeg-user/2017-November/038028.html) on the detail of those dependencies, and [the dlls themselves](https://github.com/moiamond/docker-ffmpeg-base-windowsservercore/tree/master/System32).
1. To dockerize visual studio 2019, [here is the full list](https://docs.microsoft.com/en-us/visualstudio/install/workload-component-id-vs-build-tools?view=vs-2019&preserve-view=true) of workload segments that can be installed. This thread was also helpful in the [commands to dockerize](https://docs.microsoft.com/en-us/visualstudio/install/build-tools-container?view=vs-2019) Visual Studio.
1. [How to add](https://stackoverflow.com/questions/49650969/add-multiple-folders-in-one-zip-file-in-powershell) numerous folders to a zip file in succession.
1. Powershell modules are cached in each session. If changes are made to a module in that session, which happens in development frequently, use the `-force` paramerer. [See this thread](https://www.reddit.com/r/PowerShell/comments/61x59s/unloading_and_reloading_a_module/).
1. Dot sourcing in Powershell requires a fully qualified path to the [script to be imported](https://mcpmag.com/articles/2017/02/02/exploring-dot-sourcing-in-powershell.aspx). It does not accept relative paths. Also, [this was helpful](https://stackoverflow.com/questions/684217/include-relative-files-in-powershell).
1. Wad locations can be split outside of the map file using a wad configuration. [See this post from zhlt here](http://zhlt.info/using-wad.cfg.html). This [parameter list](http://zhlt.info/command-reference.html) was helpful as well.
1. Here is a thread on how best [to unrar a file](https://www.reddit.com/r/PowerShell/comments/g8x669/unrar_with_powershell/) in powershell.
1. Use caution with the use of `pev->nextthink = -1`. If used incorrectly, it may shortcircuit the entities removal, e.g. when inheriting from `CGrenade`.
1. Powershell escape characters are backticks, not slashes. See [this thread](https://stackoverflow.com/questions/36737410/echo-newline-to-powershell-console) for more info.
1. When investigting how to convert old version of milkshape model files from 2000, [this changelog](https://web.archive.org/web/20140117155314/http://chumbalum.swissquake.ch/ms3d/Release%20Notes.txt) was valuable to pinpoint the version that had the tool to perform the conversion. [Version 1.65 on the milkshape3d forums](https://www.chumba.ch/chumbalum-soft/forum/showthread.php?t=20111) had the conversion tool available.
1. A small thread about how to obtain the last status code in powershell `$?` [can be found here.](https://www.saotn.org/powershell-return-value-exit-code-or-errorlevel-equivalent/)
1. When attempting to bring in libpng for qpakman, [these](https://docs.microsoft.com/en-us/cpp/build/how-to-create-a-cpp-project-from-existing-code?view=msvc-160) [posts](https://stackoverflow.com/questions/33534498/how-to-use-libpng-in-visual-studio) about [importing](http://pididu.com/wordpress/blog/compile-libpng-as-a-static-library-for-windows-with-visual-studio-2010-express/) libraries was an important find.
1. To correctly evaluate expressions in Powershell, use `$($_.Name)`. [This thread was helpful.](https://superuser.com/questions/899990/why-does-name-include-full-path-when-within-quotes-in-powershell)
1. In Powershell 5.1, `Compress-Archive` is [incompatible with macOS extract util](https://github.com/PowerShell/PowerShell/issues/2140). I went ahead and upgraded the Powershell version to Powershell Core, [7.1](https://github.com/PowerShell/PowerShell/releases/tag/v7.1.3), as an installation. I followed [repacking the release zip file](https://stackoverflow.com/questions/51392050/compress-archive-and-preserve-relative-paths).
1. Running more than one VM on macOS will stop Core Audio service from playing sound. The service can be restarted using this command `sudo kill -9 `ps ax|grep 'coreaudio[a-z]' | awk '{print $1}'``. See [this thread](https://apple.stackexchange.com/questions/16842/restarting-sound-service) for details.
1. When passing build parameters to msbuild for pre-processor definitions, make sure to include the string separated by semi-colons with quotes. See [this thread](https://stackoverflow.com/questions/6051054/how-do-i-pass-a-property-to-msbuild-via-command-line-that-could-be-parsed-into-a) for details.
1. See this thread on nots on how to execute a msi installer [during building](https://stackoverflow.com/questions/55846416/installing-msi-on-a-docker-container) a docker image.
1. I learned that `Start-Process` is slow in comparison to the call operation `&`. Ulimately the use of the last command `$?` is a good option to check execution. See [this thread](https://stackoverflow.com/questions/49375418/start-process-redirect-output-to-null) for more detail.
1. The texture pack in [Half-Life: Snow Edition](https://www.moddb.com/mods/half-life-snow-edition/images/last-testing-of-mod#imagebox) may be useful to be merged into Cold Ice.
1. The `Invoke-Expression` and the call operator in PowerShell [produce different results](https://stackoverflow.com/questions/50018274/why-does-invoke-operator-and-invoke-expression-produce-different-results-for).
1. Github actions [is free](https://docs.github.com/en/actions/reference/usage-limits-billing-and-administration#artifact-and-log-retention-policy) for open source and public repos.
1. Github actions has set `ubuntu-latest` as 20.04 [since October 2020](https://github.blog/changelog/2020-10-29-github-actions-ubuntu-latest-workflows-will-use-ubuntu-20-04/).
1. To set the macOS.sdk, it is best to symlink the sdk folder following [these](https://apple.stackexchange.com/questions/225558/what-is-the-macosx-sdk-file-where-do-i-find-it) [threads](https://itectec.com/askdifferent/macos-the-macosx-sdk-file-where-do-i-find-it/).
1. [This script](https://stackoverflow.com/questions/8557202/how-do-i-write-a-bash-script-to-download-and-unzip-file-on-a-mac) was helpful in download the macOS.sdk folder to Github actions. cURL needs the `-L` command to [follow redirects](https://stackoverflow.com/questions/16261100/cant-download-github-project-with-curl-command).
1. [Tar bombs](https://stackoverflow.com/questions/51689294/how-to-extract-tar-file-in-mac-terminal) are still impossible for me.
1. In yaml files there are literal scalar (`|`) and folded scalar (`>`) to represent the lines of code to be run in a block. See [this thread](https://stackoverflow.com/questions/59954185/github-action-split-long-command-into-multiple-lines) for details.
1. Here [is a thread](https://stackoverflow.com/questions/2741708/makefile-contains-string) to find a substring in a `make` file.
1. Here is a thread about [null coalesing](https://stackoverflow.com/questions/10623907/null-coalescing-in-powershell/17647824) in Powershell. Additionally [some notes](https://stackoverflow.com/questions/7909167/how-to-quietly-remove-a-directory-with-content-in-powershell) about deleting folders in Powershells.
1. In Github actions workflow, I had to force the script to end using `exit 1`. See [this thread](https://stackoverflow.com/questions/21901377/powershell-return-error-exit-code-if-not-match-a-string/21902496) for more info.
1. Like a tar bomb, how to [check out](http://nicolasgallagher.com/git-checkout-specific-files-from-another-branch/) files from another branch to the current working directory. Use `git checkout <branch> -- <files>`
1. [These](https://github.com/actions/download-artifact) [threads](https://github.com/actions/upload-artifact) for `upload-artifact` and `download-artifact` where helpful in developing the build pipeline.
1. The linux and macOS scripts in the github actions workflow were not tuned for the local setup. [This thread](https://www.tjelvarolsson.com/blog/using-relative-paths-in-linux-scripts/) was helpful in using `cd "$(dirname "$0")"`
1. The source code for Half-Life mods has user available fields on `pev->` (`integer`, `float`, `vec3_t`, and `edict_t`). See [github source here.](https://github.com/ValveSoftware/halflife/blob/master/engine/progdefs.h#L204)
1. `git status -uno` is useful for status of tracked files only. See [this thread](https://stackoverflow.com/questions/594757/how-do-i-do-a-git-status-so-it-doesnt-display-untracked-files-without-using) for more detail.
1. A straight forward way to [remove lfs objects](talvbansal.me/blog/remove-git-lfs-from-a-repository/) from a repo.
1. Escaping characters in Powershell still is gives me problems. Just [use a back tick](https://stackoverflow.com/questions/17452401/escaping-dollar-signs-in-powershell-path-is-not-working). Also, `@ { }` is a hasktable, and [one can separate](https://stackoverflow.com/questions/56965510/what-is-meaning-in-powershell/56965729) key values with a semi-colon.
1. When developing the left handed model view mirroring, this [creativedeathmatch](https://github.com/phoenixprojectsoftware/creativedeathmatch-client/commit/8df40eaf03a01f2b2c218e45fe0a539d134b781a) repo was helpful. Going through internet archives, [this tutorial](https://webcache.googleusercontent.com/search?q=cache:E3Cg5NMX2uEJ:https://www.gvme.org/4167+&cd=1&hl=en&ct=clnk&gl=us) was also helpful. However, the [Headcrab Frenzy repo](https://github.com/HLSources/Headcrab-Frenzy/blob/c005748790c36a2ce1d9bb550156275c92414d70/cl_dll/StudioModelRenderer.cpp#L1669) held the key to cull faces effectively.
1.  These resources to [split docker files](https://stackoverflow.com/questions/27409761/docker-multiple-dockerfiles-in-project) and to [mix platforms](https://devblogs.microsoft.com/premier-developer/mixing-windows-and-linux-containers-with-docker-compose/) may be important later.
1. A good thread on [how to share artifacts](https://stackoverflow.com/questions/57498605/github-actions-share-workspace-artifacts-between-jobs) between jobs and [to version them](https://docs.github.com/en/actions/guides/storing-workflow-data-as-artifacts) in Github Actions.
1. The guide for Github Actions that includes the versions of [the runners and platforms](https://docs.github.com/en/actions/reference/workflow-syntax-for-github-actions).
1. [How to effectively](https://www.tutorialspoint.com/find-out-the-current-working-directory-in-c-cplusplus) print out the [folder paths](https://docs.microsoft.com/en-us/cpp/c-runtime-library/reference/getcwd-wgetcwd?view=msvc-160) in Windows.
1. To stash certain folders, use this command `git stash push -- path/to/folder`. [This thread](https://stackoverflow.com/questions/16434267/how-to-stash-changes-in-current-folder) gave the answer.
1. Using `/m` with [MSBuild](https://learningapprentice.com/optimizing-your-build-using-msbuild/) kicks off the builds in a multi-threaded fashion.
1. `Invoke-WebRequest` [is a cmdlet](https://stackoverflow.com/questions/33759381/how-to-save-url-output-into-a-file-in-powershell) that is used to [download files](https://adamtheautomator.com/powershell-download-file/) from the internet in Powershell.
1. Dated executables in Windows may require stdio legacy with this statement `#pragma comment(lib, "legacy_stdio_definitions.lib")`. This was found in [this thread](https://stackoverflow.com/questions/31053670/unresolved-external-symbol-vsnprintf-in-dxerr-lib).
1. [This thread](https://forums.alliedmods.net/archive/index.php/t-126403.html) was critical in determining that verticles are associated to bones. In Milkshape 3D, SelAssign/Assign in that view is key.
1. [This thread](https://forum.blockland.us/index.php?topic=229530.0) helped me determine that Ctrl+Swipe is zoom in/out with MilkShape. Shift+Right click will unselect items (vertices).
1. To fix the broken view in Milk Shape 3D, [this thread](https://gamebanana.com/tuts/12753) was important to uncover the config files needed to be cleaned here: `C:\Users\USERNAME\AppData\Roaming\MilkShape 3D 1.x.x`
1. To create numerous directories at once in Powershell, use `New-Item -Path @('abc','def','jkl') -ItemType Directory`. See [this thread](https://superuser.com/questions/1128113/multiple-directories-powershell-equivalent-of-mkdir-dir1-9) for details.
1. In Milkshape 3d, a reference model can be generated from a sequence animation frame. Load the frame in animation mode, and then select all joints. In the `Animate` menu, select `Adjust SMD Keys.` Select the default values. Click the button to lock in the reference for use.
1. An [excellent video](https://www.youtube.com/watch?v=AQNznlxlmNE) in animating in Milkshape 3d by MTB.
1. When ready to [compile ImageMagick](https://imagemagick.org/script/install-source.php), use [this github repo here](https://github.com/ImageMagick/ImageMagick) and for Windows [here](https://github.com/ImageMagick/ImageMagick-Windows).
1. For switches in msbuild.exe, see [this thread](https://docs.microsoft.com/en-us/visualstudio/msbuild/msbuild-command-line-reference?view=vs-2019). For msbuild project switches, [see this thread](https://docs.microsoft.com/en-us/previous-versions/visualstudio/visual-studio-2015/msbuild/common-msbuild-project-properties?view=vs-2015&redirectedfrom=MSDN)
1. Valves overview of Half-Life modeling guide [can be found here](https://mrl.cs.nyu.edu/~dzorin/ig04/lecture22/modeling.pdf).
1. To unrar a file to a path, use `rar x archive.rar path/to/extract/to`
1. Here is an old tutorial of how to build a [Half-Life model](https://www.oocities.org/vs49688/hlsdk2/sdk/MS3d_to_HL.htm).
1. Here [is a full breakdown](https://www.shouldiremoveit.com/Ricochet-48209-program.aspx) of all libraries in the valve folder with labels. This includes cg.dll and cgGL.dll. The [NativeDllTester](https://github.com/Solokiller/NativeDllTester) was helpful in discovering loaded libraries from [this problem thread](https://github.com/ValveSoftware/halflife/issues/2086).
1. [The Half-Life Overhaul model pack](https://www.moddb.com/mods/half-life-overhaul-pack/downloads/half-life-overhaul-pack-v10) includes refreshed models that are more modern.
1. [A good tutorial](http://www.half-lifecreations.com/forums/index.php?topic=1632.0) on how to replace arms within Half-Life models using MilkShape 3d.
1. [The Restore-Life mod](https://gamebanana.com/mods/36047) replaces weapon animations with beta ones, and restores some old behaviors.
1. [The Half-Life 2: Classic Mod](https://www.moddb.com/mods/half-life-2-classic) attempts to rebuild Half-Life 2 in the GoldSec engine. This mod has Half-Life 2 models compiled in the old styled mdl format.
1. These [two](https://superuser.com/questions/591438/how-can-i-display-the-time-stamp-of-a-file-with-seconds-from-the-command-line) [posts](https://stackoverflow.com/questions/1018934/simple-powershell-lastwritetime-compare) where critical on how to get file attributes in Powershell such as `LastWriteTime`.
1. In Powershell, [the type Boolean](https://stackoverflow.com/questions/26015072/why-is-false-eq-true) is noted at `bool` and it takes the values of `$true` and `$false`.
1. [Here](https://twhl.info/wiki/page/Tutorial%3A_Rain) [are](https://web.archive.org/web/20061028200741/http://collective.valve-erc.com/index.php?doc=1046838887-64569500) [numerous](https://gamebanana.com/tuts/10887) [posts](https://gamebanana.com/tuts/10768) [on](http://web.archive.org/web/20000615022248/http://www.halflife.gamedesign.net/tutorials/rain.shtml) how to make rain effect in Half-Life. [Snow War mod](https://www.youtube.com/watch?v=dSlQbJhbmho) contains snow sprite assets where it could be plugged into a rain like effect.
1. To invert the weapon skins, I've used the [convert.exe](https://www.thebest3d.com/dogwaffle/patches/im/) from ImageMagick.
1. Here are some demo commands I've learned. `viewdemo`, `playdemo`, `listdemo`, `stopdemo`, `timedemo`, `appenddemo`, `record`, and `stop`.
1. To adjust treble and bass settings in ffmpeg, [this thread was helpful](https://stackoverflow.com/questions/39607741/ffmpeg-how-to-reduce-bass-and-increase-treble-like-audacity) in discovering `fireequalizer`.
1. [This thread](https://www.pcmag.com/how-to/how-to-convert-youtube-videos-to-mp3-files) was a good primer on how to record audio from YouTube videos. [YouTubeToMp3Song](https://youtubetomp3song.com/) is useful tool.
1. [whereis](https://kb.iu.edu/d/acec) tool is good to find the path of an executable on Linux.
1. The use of `#ifndef CLIENT_DLL` is important for entities and items that should not be included in the `client.dll` library. I learned that this was critical for the snowball implementation.
1. I learned there are major weapon mods in the community. There is [MMOD](https://www.moddb.com/mods/half-life-mmod) inwhich changes the weapons and explosions. There is [brutal mod](https://www.moddb.com/mods/brutal-half-life), adding more weapons, gore and realism with physics. There is [overhauled](https://www.moddb.com/mods/half-life-overhaul-pack), which revamps all viewmodels. And finally there is the [overhaul supercharged](https://www.youtube.com/watch?v=ktk0wxVhFqs), inwhich adds new animations and physics.
1. [Here](https://twhl.info/wiki/page/Half-Life_Programming_-_Debugging) is a very good article on how to set up debugging with both Windows and Linux using gdb.
1. Using `min(max(x, some_min), some_max)` allows for a [range without branching](https://stackoverflow.com/questions/2868439/is-there-a-way-to-limit-an-integer-value-to-a-certain-range-without-branching).
1. The letters as switches [are required](https://sookocheff.com/post/bash/parsing-bash-script-arguments-with-shopts/) in the `getopts` portion in bash.
1. This is a good thread on how [to constrain the framerate](https://stackoverflow.com/questions/19764018/controlling-fps-with-requestanimationframe) for animation frames.
1. The [file transer util](https://www.android.com/filetransfer/) can be used to upload files to Android devices.
1. The latest xash3d builds [can be found here](https://github.com/FWGS/xash3d-fwgs/releases/tag/continuous).
1. The `gameinfo.txt` file is automatically generated when a mod is loaded into xash3d. See [this code](https://github.com/FWGS/xash3d/blob/master/engine/common/filesystem.c) for full details.
1. [A good guide](https://stackoverflow.com/a/43966266) on how to get the  git hash within Powershell.
1. When escaping a path for execution in Powershell is difficult, use the `Set-Location` as a hack. See [this thread](https://stackoverflow.com/a/26981940) for details.
1. [All output in a function is returned](https://stackoverflow.com/a/10288256) in Powershell.
1. [This graphic](https://en.wikipedia.org/wiki/Aircraft_principal_axes#/media/File:Yaw_Axis_Corrected.svg) helps better understand the three axises of yaw, pitch, and roll.
1. [SteamCharts](https://steamcharts.com/search/?q=half-life) is a great place to understand how many players are playing steam games.
1. [The use of %p](https://stackoverflow.com/questions/9053658/correct-format-specifier-to-print-pointer-or-address) in debug statements is used to print out the address of the pointer. 
1. [Directory.Build.props](https://newbedev.com/how-to-set-preprocessordefinitions-as-a-task-propery-for-the-msbuild-task) file can be used for configuration of the current build.
1. <signal.h> and `raise(SIGSEV)` [can be used](https://stackoverflow.com/questions/8481783/what-is-the-easiest-way-to-make-a-c-program-crash) to raise and crash a c++ program.
1. I learned that vertices should be arranged in a counter-clockwise fashion. Each face ihas a front face and a back face. To switch between bace and front face, use reverse vertex under faces.
1. As of October 2021, [Virtual Box 6.1.26](https://docs.microsoft.com/en-us/windows/release-health/status-windows-11-21h2#1704msgdesc) has compatbility problems with Windows 11. Oracle is working on a fix.
1. There is a hard limit of 500 temporary entities in Half-Life - even a NULL check will not work.
1. [This webpage](http://zhlt.info/settings-for-final-compiles.html) discusses the full listing of "final" settings recommended in compiling Half-Life maps using ZHLT tools.
1. [This webpage](https://valvedev.info/guides/goldsrc-map-decompilers-bsptwomap-vs-winbspc/) discusses the differences between bsptwomap and winbspc decompile outcomes.
1. HPB has created a suite of tools to generate overviews and waypoints. See [this thread](http://hpb-bot.bots-united.com/bsp_tool.html) on the tools. This [original thread](https://steamcommunity.com/app/30/discussions/0/351660338712291564/) pointed me to automatic waypoint generation.
1. The fix to the game icon was found in [this thread](https://twhl.info/wiki/page/Icons_for_Half-Life_mods_%28game.tga%29)
1. VHE (Valve Hammer Editor) requires a new line at the end of the file, otherwise it will not load the file.
1. To install Windows 11 on macOS virtuabox, [this thread](https://forums.macrumors.com/threads/windows-11-on-boot-camp-no-tpm-2-0.2302214/) and these [registry keys](https://dannyda.com/2021/06/29/how-to-fix-bypass-this-pc-cant-run-windows-11-error-when-installing-microsoft-windows-11/) are needed to bypass TPMS,SecureBoot.
1. [This thread](https://devconnected.com/how-to-add-and-update-git-submodules/) was helpful in setting up a new git submodule to hl-mods.
1. [This guide](https://techrechard.com/install-macos-mojave-on-virtualbox-on-windows-pc/) walks through setting up Mojave on VirtalBox, which may be useful.
1. This [stackoverflow thread](https://stackoverflow.com/questions/44035920/functions-in-powershell-can-they-be-called-within-a-string) does a good job in explaining how parameters are passed to Powershell functions.
1. Pass in `_sethdmodels 1` to hl.exe for support of [high-definition models](http://profile.lunaticrage.com/drippy/forum.php?a=rt&f=1&t=17288&m=348303).
1. Always forgetting pointers and addresses, this [stackoverflow thread](https://stackoverflow.com/a/44013360) confirms what they mean.
1. I learned a bit on how to mdoel in Milkshape 3D from scratch. These two tutorials in [creating a sword](https://www.hiveworkshop.com/threads/milkshape-attachment-modeling.53734/) and [unwrapping a model](https://www.hiveworkshop.com/threads/milkshape-tutorial-a-simple-way-to-unwrap-your-models.156766/) were helpful.
1. I learned alittle bit about extruding and low poly modeling with [this thread](https://www.moddb.com/tutorials/milkshape-3d-basics-fundamentals) and [building a human body](https://www.hiveworkshop.com/threads/making-a-humanbody-from-scratch-in-milkshape-3d.110990/) from nothing.
1. [This thread](https://developer.valvesoftware.com/wiki/Half-Life.fgd) hosts the latest Half-Life fgd dated from 2003.
1. [This thread](https://quakewiki.org/wiki/Quake_Map_Format) discusses the original map format, and Valve's "220" version. There are [converters](https://www.ogier-editor.com/mapconv/) out there that change the format between 220 and original formats. I also learned that the map file structure all devires from [worldspawn classname](https://twhl.info/wiki/page/worldspawn).
1. A short post on [how to pass parameters to a steam uri](https://steamcommunity.com/discussions/forum/1/144513128846060662/?ref=dtf.ru)
1. In case there are questions about the parameter usage of the engine calls, use the [xash3d engine codebase](https://github.com/FWGS/xash3d-fwgs/blob/e5e1570aed435acc3216bf73a39e812853d2aa0c/engine) to determine what it may determine.
1. Use `-dev 5` and `-log` [when debugging](https://github.com/FWGS/xash3d/issues/58) on xash3d.
1. These [three](http://www.garagegames.com/community/forums/viewthread/87197) [threads](https://forum.blockland.us/index.php?topic=75076.0) [where](https://modthesims.info/t/515221) helpful in understanding how to flip faces drawn backward.
1. A [thread](https://stackoverflow.com/questions/17461079/how-to-get-the-error-code-when-there-is-error-in-powershell/17461604) on how to silently continue in a powershell script.
1. There are nine ways to [multi-line text](https://stackoverflow.com/questions/3790454/how-do-i-break-a-string-in-yaml-over-multiple-lines/21699210) in yaml.
1. A [hint](https://github.com/HLSources/Tyrian-GroundAssault/blob/9411deab882dd4ae444c0e24debe5bbbff9cfc50/cl_dll/cdll_int.cpp#L266) on how to detect the xash3d engine in a game modification, which uses cvar detection `host_clientloaded`.
1. A [Windows 11](https://news.ycombinator.com/item?id=29129358) thread that has hints of how to install the version without checks.
1. I learned that the zip version on the mac was incompatible with `.7z` that caused corruption of file unpacks. I [looked for a cmd util](https://apple.stackexchange.com/questions/307377/how-can-i-unpack-7z-files-via-macos-terminal) and found `p7zip`.
1. A [thread](https://github.com/ValveSoftware/halflife/issues/2955) on the old feature of glowing textures in early versions of Half-Life.
1. Temporary entities seems unconfigurable in the Half-Life version, [stuck at 500](https://developer.valvesoftware.com/wiki/Temporary_Entity at any time.)
1. [This is](https://valvedev.info/tools/) a good list of modern Half-Life development tools.
1. The steam wiki has information about entities key values, like [func_conveyor](https://developer.valvesoftware.com/wiki/Func_conveyor).
1. [This wiki](https://twhl.info/wiki/page/Entity_Programming_-_Overview) was important to understand alittle bit more on how the Half-Life engine handles `edict_t` and `entvars_t`.
1. [This thread](https://legacy.imagemagick.org/discourse-server/viewtopic.php?t=33380) and understanding imagemagick's convert util using `tint` comes close to [colorizing](https://legacy.imagemagick.org/Usage/color_mods/#tinting) images to blue. 
1. I learned that `Wrie-Information` [does not](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/write-information?view=powershell-7.2) print to console under a default setting.
1. `convert` in 6.x was changed to `magick` in 7.x. [This thread](https://legacy.imagemagick.org/discourse-server/viewtopic.php?t=35929) was [the source](https://legacy.imagemagick.org/discourse-server/viewtopic.php?t=29582) of [this information](https://tex.stackexchange.com/questions/419958/standalone-convert-doesnt-work).
1. Use `-remap` in convert.exe to use a [pallette of the same](https://legacy.imagemagick.org/discourse-server/viewtopic.php?t=33582) for image conversion.
1. `Throw` [is recommended](https://stackoverflow.com/questions/2022326/terminating-a-script-in-powershell) to terminate a Powershell script that cannot recover, with a message.
1. I learned that bash will have a problem [executing a script](https://askubuntu.com/questions/834853/ubuntu-bash-functions-syntax-error-or-unexpected) if the line breaks are CRLF instead of LF.
1. The two most important commands in Half-Life are `cvarlist` and `cmdlist.` These commands print out all possible bindings in the game.
1. My Ubuntu virtual machine locked up every 30 minutes. The solution was to disable 3d acceleration following [this guide](https://tipsmake.com/how-to-fix-ubuntu-freezing-in-virtualbox).
1. In GIMP, to promote a selection to a layer, use the [select -> float](https://logosbynick.com/gimp-make-selection-new-layer/) option. There is also no default shortcut to quickly delete layers. Use [this guide](https://superuser.com/questions/603406/whats-the-shortcut-to-delete-selected-layer-in-gimp) on how to set the shortcuts.
1. Using Loopback, [this article](https://blogs.reed.edu/ed-tech/recording-your-macs-video-screen-with-audio/) was important in understanding how to record audio to a screen recording.
1. If the HLDS server from steamcmd is not visible, make sure that the Windows firewall rules are enabled for hlds.exe to connect from the outside.
1. I learned that SteamCmd will report a 0x202 error when file permissions rejected or out of disk space. See [this thread](https://steamcommunity.com/groups/linuxgsm/discussions/0/135508031951230808/) for details, or look in `logs/` folder of steamcmd.
1. I learned that Github workflow archives are [only available](https://github.com/actions/upload-artifact/issues/51) to those that are logged into Github.
1. ffmpeg volume controls also support the flag NdB, for example, `-filter:a volume=25dB`. [See this guide](https://trac.ffmpeg.org/wiki/AudioVolume) for more information about volume controls.
1. To see all those that star a Github repository, use the `/stargazers` [path](https://webapps.stackexchange.com/questions/41799/how-can-i-list-people-who-have-starred-my-github-repository) at the end of the repo path.
1. For the [download-artifact](https://giters.com/actions/download-artifact), all artifacts can be downloaded at once if no name is specified.
1. To temporary stop a Github workflow, use the declaration `on: push: branches-ignore: - '**'`
1. The [Github Community board for actions](https://github.community/c/code-to-cloud/github-actions/41) was important to determine when an outtage occured. The [status page](https://www.githubstatus.com/) was not sufficient.
1. Audacity is a good free audio editor. It includes support to [reduce background noise](https://filmstro.com/blog/how-to-remove-background-noise-in-audacity).
1. A [very good article](https://flatline-arena.droppages.com/tutorials/Skelswapping/) on how to swap player skeletons in GoldSrc using Milkshape3d.
1. I learned that you can control framerate by using the commands `fps_override 1` and `fps_max`. This is helpful to debug ironsights. [This thread](https://steamcommunity.com/app/70/discussions/0/3315110799612677127/) was the source.
1. You can combine gif's by simply using Imagemagick command `convert gi1 gif2 combined`. [See this thread](https://askubuntu.com/questions/833842/how-can-i-combine-two-animated-gif-images-into-one) for details.
1. [A good article](https://help.steampowered.com/en/faqs/view/081A-106F-B906-1A7A) on how to setup a dedicate Half-Life server. Included is [setting up a router](https://help.steampowered.com/en/faqs/view/6F46-9698-9682-8DB8) and [starting the server](https://steamcommunity.com/sharedfiles/filedetails/?id=2028698488)
1. How to [setup SteamCMD](https://blog.eldernode.com/install-and-run-steamcmd-on-windows/) and and [setting up a game server on Azure](https://pumpingco.de/blog/your-own-game-server-on-azure-create-a-dedicated-counter-strike-server/)
1. I learned during editing Quicktime videos, editing videos [in the middle](https://apple.stackexchange.com/questions/37426/how-can-i-remove-a-portion-of-from-the-middle-of-a-movie) is possible with the `Split Clip` feature.
1. [This commit](https://github.com/SamVanheer/halflife-updated/commit/e01645e239f730870041bb9e10e728f896b1a736) was helpful in understanding how to update to 64 weapons with predictive client weapon support in Half-Life.
1. [Here is an article](http://www.half-life.ru/forum/showthread.php?threadid=6129) on how to update the Half-Life SDk to 64 weapons using the data point `iuser4` as a mask for another 32 weapons.
1. [Here is a matrix](https://www.arj.no/2013/10/18/bits/) of bit conversions for figuring out which integer number to declare in `delta.lst`
1. To save a dump file in Microsoft Visual Studio, select [Edit > Save Debug Dump File As](https://docs.microsoft.com/en-us/visualstudio/debugger/using-dump-files?view=vs-2022)
1. [gl_polyoffset 0.1](https://steamcommunity.com/app/70/discussions/0/3615773009892169726/?l=greek) maybe useful for clearing up flickering decals in Half-Life
1. In Gimp, [here is a good guide](https://tipsmake.com/how-to-create-clipping-mask-in-gimp) on creating a clipping mask within a layer.
1. I learned that the three last values in the skeleton model is `pitch`, `roll`, and `yaw`, also known as AZR, AXR, AYR.
1. The reference in weapons as `m_pPlayer` is not reliable for giving or assessing weapon inventory.
1. In order to provide a mirror of a left arm in milkshape, copied from a right arm, use the mirror front to back, and allow the attached joint to flip itself naturally when recombining it.
1. I learned that in order to flip verticies after mirroring front to back, invert the value of pitch (AZR) and roll (AXR).

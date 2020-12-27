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

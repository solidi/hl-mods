# Microsoft Developer Studio Project File - Name="mp" - Package Owner=<4>
# Microsoft Developer Studio Generated Build File, Format Version 6.00
# ** DO NOT EDIT **

# TARGTYPE "Win32 (x86) Dynamic-Link Library" 0x0102

CFG=mp - Win32 Release
!MESSAGE This is not a valid makefile. To build this project using NMAKE,
!MESSAGE use the Export Makefile command and run
!MESSAGE 
!MESSAGE NMAKE /f "mp.mak".
!MESSAGE 
!MESSAGE You can specify a configuration when running NMAKE
!MESSAGE by defining the macro CFG on the command line. For example:
!MESSAGE 
!MESSAGE NMAKE /f "mp.mak" CFG="mp - Win32 Release"
!MESSAGE 
!MESSAGE Possible choices for configuration are:
!MESSAGE 
!MESSAGE "mp - Win32 Release" (based on "Win32 (x86) Dynamic-Link Library")
!MESSAGE "mp - Win32 Debug" (based on "Win32 (x86) Dynamic-Link Library")
!MESSAGE "mp - Win32 Profile" (based on "Win32 (x86) Dynamic-Link Library")
!MESSAGE 

# Begin Project
# PROP AllowPerConfigDependencies 0
# PROP Scc_ProjName ""$/SDKSrc/Public/dlls", NVGBAAAA"
# PROP Scc_LocalPath "."
CPP=cl.exe
MTL=midl.exe
RSC=rc.exe

!IF  "$(CFG)" == "mp - Win32 Release"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 0
# PROP BASE Output_Dir ".\Release"
# PROP BASE Intermediate_Dir ".\Release"
# PROP BASE Target_Dir ""
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 0
# PROP Output_Dir ".\Releasemp"
# PROP Intermediate_Dir ".\Releasemp"
# PROP Target_Dir ""
# ADD BASE CPP /nologo /MT /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_WINDOWS" /YX /c
# ADD CPP /nologo /G5 /MT /W3 /GX /Zi /O2 /I "..\engine" /D "NDEBUG" /D "WIN32" /D "_WINDOWS" /D "VALVE_DLL" /YX /FD /c
# SUBTRACT CPP /Fr
# ADD BASE MTL /nologo /D "NDEBUG" /win32
# ADD MTL /nologo /D "NDEBUG" /mktyplib203 /win32
# ADD BASE RSC /l 0x409 /d "NDEBUG"
# ADD RSC /l 0x409 /d "NDEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:windows /dll /machine:I386
# ADD LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib /nologo /subsystem:windows /dll /map /debug /machine:I386 /def:".\mp.def"
# SUBTRACT LINK32 /profile
# Begin Custom Build - Copying to \half-life\mp\dlls
TargetPath=.\Releasemp\mp.dll
TargetName=mp
InputPath=.\Releasemp\mp.dll
SOURCE="$(InputPath)"

"$(TargetName)" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
	copy $(TargetPath) \half-life\mp\dlls

# End Custom Build

!ELSEIF  "$(CFG)" == "mp - Win32 Debug"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 1
# PROP BASE Output_Dir ".\mp___Win"
# PROP BASE Intermediate_Dir ".\mp___Win"
# PROP BASE Target_Dir ""
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 1
# PROP Output_Dir ".\debugmp"
# PROP Intermediate_Dir ".\debugmp"
# PROP Target_Dir ""
# ADD BASE CPP /nologo /MTd /W3 /Gm /GX /Zi /Od /D "WIN32" /D "_DEBUG" /D "_WINDOWS" /YX /c
# ADD CPP /nologo /G5 /MTd /W3 /Gm /GX /ZI /Od /I "..\engine" /D "_DEBUG" /D "WIN32" /D "_WINDOWS" /D "VALVE_DLL" /FR /YX /FD /c
# ADD BASE MTL /nologo /D "_DEBUG" /win32
# ADD MTL /nologo /D "_DEBUG" /mktyplib203 /win32
# ADD BASE RSC /l 0x409 /d "_DEBUG"
# ADD RSC /l 0x409 /i "..\engine" /d "_DEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:windows /dll /debug /machine:I386
# ADD LINK32 user32.lib advapi32.lib /nologo /subsystem:windows /dll /debug /machine:I386 /def:".\mp.def" /implib:".\Debug\mp.lib"
# SUBTRACT LINK32 /profile
# Begin Custom Build - Copying to \half-life\mp\dlls
TargetPath=.\debugmp\mp.dll
TargetName=mp
InputPath=.\debugmp\mp.dll
SOURCE="$(InputPath)"

"$(TargetName)" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
	copy $(TargetPath) \half-life\mp\dlls

# End Custom Build

!ELSEIF  "$(CFG)" == "mp - Win32 Profile"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 0
# PROP BASE Output_Dir ".\mp___Win"
# PROP BASE Intermediate_Dir ".\mp___Win"
# PROP BASE Target_Dir ""
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 0
# PROP Output_Dir ".\Profilemp"
# PROP Intermediate_Dir ".\Profilemp"
# PROP Ignore_Export_Lib 0
# PROP Target_Dir ""
# ADD BASE CPP /nologo /G5 /MT /W3 /GX /Zi /O2 /I "..\engine" /D "NDEBUG" /D "WIN32" /D "_WINDOWS" /D "QUIVER" /D "VOXEL" /D "QUAKE2" /D "VALVE_DLL" /YX /c
# SUBTRACT BASE CPP /Fr
# ADD CPP /nologo /G5 /MT /W3 /GX /Zi /O2 /I "..\engine" /D "NDEBUG" /D "WIN32" /D "_WINDOWS" /D "VALVE_DLL" /Fr /YX /FD /c
# ADD BASE MTL /nologo /D "NDEBUG" /win32
# ADD MTL /nologo /D "NDEBUG" /mktyplib203 /win32
# ADD BASE RSC /l 0x409 /d "NDEBUG"
# ADD RSC /l 0x409 /d "NDEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo /o".\Profilemp/ice.bsc"
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib /nologo /subsystem:windows /dll /debug /machine:I386 /def:".\mp.def"
# SUBTRACT BASE LINK32 /profile
# ADD LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib /nologo /subsystem:windows /dll /profile /debug /machine:I386 /def:".\mp.def" /out:".\Profilemp/ice.dll"
# Begin Custom Build - Copying to \SIERRA\Half-Life\ice\dlls
TargetDir=.\Profilemp
InputPath=.\Profilemp\ice.dll
SOURCE="$(InputPath)"

BuildCmds= \
	copy $(TargetDir)\ice.dll \SIERRA\Half-Life\ice\dlls \
	copy $(TargetDir)\ice.map \SIERRA\Half-Life\ice\dlls \
	

"C:\SIERRA\Half-Life\ice\dlls\ice.dll" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
   $(BuildCmds)

"C:\SIERRA\Half-Life\ice\dlls\ice.map" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
   $(BuildCmds)
# End Custom Build

!ENDIF 

# Begin Target

# Name "mp - Win32 Release"
# Name "mp - Win32 Debug"
# Name "mp - Win32 Profile"
# Begin Group "Source Files"

# PROP Default_Filter "cpp;c;cxx;rc;def;r;odl;idl;hpj;bat;for;f90"
# Begin Source File

SOURCE=.\animating.cpp
# End Source File
# Begin Source File

SOURCE=.\animation.cpp
# End Source File
# Begin Source File

SOURCE=.\bmodels.cpp
# End Source File
# Begin Source File

SOURCE=.\boltgun.cpp
# End Source File
# Begin Source File

SOURCE=.\bot.cpp
# End Source File
# Begin Source File

SOURCE=.\buttons.cpp
# End Source File
# Begin Source File

SOURCE=.\cannon.cpp
# End Source File
# Begin Source File

SOURCE=.\cbase.cpp
# End Source File
# Begin Source File

SOURCE=.\chaingun.cpp
# End Source File
# Begin Source File

SOURCE=.\chumtoad.cpp
# End Source File
# Begin Source File

SOURCE=.\client.cpp
# End Source File
# Begin Source File

SOURCE=.\clustergrenade.cpp
# End Source File
# Begin Source File

SOURCE=.\combat.cpp
# End Source File
# Begin Source File

SOURCE=.\crowbar.cpp
# End Source File
# Begin Source File

SOURCE=.\decoybomb.cpp
# End Source File
# Begin Source File

SOURCE=.\doors.cpp
# End Source File
# Begin Source File

SOURCE=.\double_uzi.cpp
# End Source File
# Begin Source File

SOURCE=.\effects.cpp
# End Source File
# Begin Source File

SOURCE=.\explode.cpp
# End Source File
# Begin Source File

SOURCE=.\func_break.cpp
# End Source File
# Begin Source File

SOURCE=.\func_tank.cpp
# End Source File
# Begin Source File

SOURCE=.\game.cpp
# End Source File
# Begin Source File

SOURCE=.\gamerules.cpp
# End Source File
# Begin Source File

SOURCE=.\ggrenade.cpp
# End Source File
# Begin Source File

SOURCE=.\globals.cpp
# End Source File
# Begin Source File

SOURCE=.\grenadel.cpp
# End Source File
# Begin Source File

SOURCE=.\h_ai.cpp
# End Source File
# Begin Source File

SOURCE=.\h_battery.cpp
# End Source File
# Begin Source File

SOURCE=.\h_cycler.cpp
# End Source File
# Begin Source File

SOURCE=.\h_export.cpp
# End Source File
# Begin Source File

SOURCE=.\healthkit.cpp
# End Source File
# Begin Source File

SOURCE=.\items.cpp
# End Source File
# Begin Source File

SOURCE=.\knife.cpp
# End Source File
# Begin Source File

SOURCE=.\laser_rifle.cpp
# End Source File
# Begin Source File

SOURCE=.\lights.cpp
# End Source File
# Begin Source File

SOURCE=.\m16.cpp
# End Source File
# Begin Source File

SOURCE=.\mag60.cpp
# End Source File
# Begin Source File

SOURCE=.\maprules.cpp
# End Source File
# Begin Source File

SOURCE=.\mortar.cpp
# End Source File
# Begin Source File

SOURCE=.\mpstubb.cpp
# End Source File
# Begin Source File

SOURCE=.\multiplay_gamerules.cpp
# End Source File
# Begin Source File

SOURCE=.\pathcorner.cpp
# End Source File
# Begin Source File

SOURCE=.\pepsibomb.cpp
# End Source File
# Begin Source File

SOURCE=.\plane.cpp
# End Source File
# Begin Source File

SOURCE=.\plats.cpp
# End Source File
# Begin Source File

SOURCE=.\player.cpp
# End Source File
# Begin Source File

SOURCE=.\ppk.cpp
# End Source File
# Begin Source File

SOURCE=.\raygun.cpp
# End Source File
# Begin Source File

SOURCE=.\rifle.cpp
# End Source File
# Begin Source File

SOURCE=.\rpg.cpp
# End Source File
# Begin Source File

SOURCE=.\runes.cpp
# End Source File
# Begin Source File

SOURCE=.\shotgun.cpp
# End Source File
# Begin Source File

SOURCE=.\singleplay_gamerules.cpp
# End Source File
# Begin Source File

SOURCE=.\skill.cpp
# End Source File
# Begin Source File

SOURCE=.\smokegrenade.cpp
# End Source File
# Begin Source File

SOURCE=.\sound.cpp
# End Source File
# Begin Source File

SOURCE=.\soundent.cpp
# End Source File
# Begin Source File

SOURCE=.\spectator.cpp
# End Source File
# Begin Source File

SOURCE=.\sshotgun.cpp
# End Source File
# Begin Source File

SOURCE=.\subs.cpp
# End Source File
# Begin Source File

SOURCE=.\taser.cpp
# End Source File
# Begin Source File

SOURCE=.\teamplay_gamerules.cpp
# End Source File
# Begin Source File

SOURCE=.\tnt.cpp
# End Source File
# Begin Source File

SOURCE=.\triggers.cpp
# End Source File
# Begin Source File

SOURCE=.\usas.cpp
# End Source File
# Begin Source File

SOURCE=.\util.cpp
# End Source File
# Begin Source File

SOURCE=.\uzi.cpp
# End Source File
# Begin Source File

SOURCE=.\weapons.cpp
# End Source File
# Begin Source File

SOURCE=.\world.cpp
# End Source File
# Begin Source File

SOURCE=.\wrench.cpp
# End Source File
# Begin Source File

SOURCE=.\xen.cpp
# End Source File
# End Group
# Begin Group "Header Files"

# PROP Default_Filter "h;hpp;hxx;hm;inl;fi;fd"
# Begin Source File

SOURCE=.\activity.h
# End Source File
# Begin Source File

SOURCE=.\activitymap.h
# End Source File
# Begin Source File

SOURCE=.\animation.h
# End Source File
# Begin Source File

SOURCE=.\basemonster.h
# End Source File
# Begin Source File

SOURCE=.\bot.h
# End Source File
# Begin Source File

SOURCE=.\cbase.h
# End Source File
# Begin Source File

SOURCE=.\cdll_dll.h
# End Source File
# Begin Source File

SOURCE=.\client.h
# End Source File
# Begin Source File

SOURCE=.\decals.h
# End Source File
# Begin Source File

SOURCE=.\doors.h
# End Source File
# Begin Source File

SOURCE=.\effects.h
# End Source File
# Begin Source File

SOURCE=.\enginecallback.h
# End Source File
# Begin Source File

SOURCE=.\explode.h
# End Source File
# Begin Source File

SOURCE=.\extdll.h
# End Source File
# Begin Source File

SOURCE=.\func_break.h
# End Source File
# Begin Source File

SOURCE=.\game.h
# End Source File
# Begin Source File

SOURCE=.\gamerules.h
# End Source File
# Begin Source File

SOURCE=.\items.h
# End Source File
# Begin Source File

SOURCE=.\maprules.h
# End Source File
# Begin Source File

SOURCE=.\monsterevent.h
# End Source File
# Begin Source File

SOURCE=.\monsters.h
# End Source File
# Begin Source File

SOURCE=.\nodes.h
# End Source File
# Begin Source File

SOURCE=.\plane.h
# End Source File
# Begin Source File

SOURCE=.\player.h
# End Source File
# Begin Source File

SOURCE=.\saverestore.h
# End Source File
# Begin Source File

SOURCE=.\schedule.h
# End Source File
# Begin Source File

SOURCE=.\scriptevent.h
# End Source File
# Begin Source File

SOURCE=.\skill.h
# End Source File
# Begin Source File

SOURCE=.\soundent.h
# End Source File
# Begin Source File

SOURCE=.\spectator.h
# End Source File
# Begin Source File

SOURCE=.\talkmonster.h
# End Source File
# Begin Source File

SOURCE=.\teamplay_gamerules.h
# End Source File
# Begin Source File

SOURCE=.\trains.h
# End Source File
# Begin Source File

SOURCE=.\util.h
# End Source File
# Begin Source File

SOURCE=.\vector.h
# End Source File
# Begin Source File

SOURCE=.\weapons.h
# End Source File
# End Group
# Begin Group "Resource Files"

# PROP Default_Filter "ico;cur;bmp;dlg;rc2;rct;bin;cnt;rtf;gif;jpg;jpeg;jpe"
# End Group
# End Target
# End Project

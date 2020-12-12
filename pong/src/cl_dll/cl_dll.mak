# Microsoft Developer Studio Generated NMAKE File, Format Version 4.20
# ** DO NOT EDIT **

# TARGTYPE "Win32 (x86) Dynamic-Link Library" 0x0102

!IF "$(CFG)" == ""
CFG=cl_dll - Win32 Debug
!MESSAGE No configuration specified.  Defaulting to cl_dll - Win32 Debug.
!ENDIF 

!IF "$(CFG)" != "cl_dll - Win32 Release" && "$(CFG)" != "cl_dll - Win32 Debug"
!MESSAGE Invalid configuration "$(CFG)" specified.
!MESSAGE You can specify a configuration when running NMAKE on this makefile
!MESSAGE by defining the macro CFG on the command line.  For example:
!MESSAGE 
!MESSAGE NMAKE /f "cl_dll.mak" CFG="cl_dll - Win32 Debug"
!MESSAGE 
!MESSAGE Possible choices for configuration are:
!MESSAGE 
!MESSAGE "cl_dll - Win32 Release" (based on "Win32 (x86) Dynamic-Link Library")
!MESSAGE "cl_dll - Win32 Debug" (based on "Win32 (x86) Dynamic-Link Library")
!MESSAGE 
!ERROR An invalid configuration is specified.
!ENDIF 

!IF "$(OS)" == "Windows_NT"
NULL=
!ELSE 
NULL=nul
!ENDIF 
################################################################################
# Begin Project
# PROP Target_Last_Scanned "cl_dll - Win32 Debug"
MTL=mktyplib.exe
RSC=rc.exe
CPP=cl.exe

!IF  "$(CFG)" == "cl_dll - Win32 Release"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 0
# PROP BASE Output_Dir "Release"
# PROP BASE Intermediate_Dir "Release"
# PROP BASE Target_Dir ""
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 0
# PROP Output_Dir "Release"
# PROP Intermediate_Dir "Release"
# PROP Target_Dir ""
OUTDIR=.\Release
INTDIR=.\Release

ALL : "$(OUTDIR)\client.dll" "..\..\valve\cl_dlls\client.dll"

CLEAN : 
	-@erase "$(INTDIR)\ammo.obj"
	-@erase "$(INTDIR)\ammo_secondary.obj"
	-@erase "$(INTDIR)\ammohistory.obj"
	-@erase "$(INTDIR)\battery.obj"
	-@erase "$(INTDIR)\cdll_int.obj"
	-@erase "$(INTDIR)\death.obj"
	-@erase "$(INTDIR)\flashlight.obj"
	-@erase "$(INTDIR)\geiger.obj"
	-@erase "$(INTDIR)\health.obj"
	-@erase "$(INTDIR)\hud.obj"
	-@erase "$(INTDIR)\hud_msg.obj"
	-@erase "$(INTDIR)\hud_redraw.obj"
	-@erase "$(INTDIR)\hud_update.obj"
	-@erase "$(INTDIR)\menu.obj"
	-@erase "$(INTDIR)\message.obj"
	-@erase "$(INTDIR)\MOTD.obj"
	-@erase "$(INTDIR)\parsemsg.obj"
	-@erase "$(INTDIR)\saytext.obj"
	-@erase "$(INTDIR)\scoreboard.obj"
	-@erase "$(INTDIR)\status_icons.obj"
	-@erase "$(INTDIR)\statusbar.obj"
	-@erase "$(INTDIR)\text_message.obj"
	-@erase "$(INTDIR)\train.obj"
	-@erase "$(INTDIR)\util.obj"
	-@erase "$(INTDIR)\vc40.pdb"
	-@erase "$(OUTDIR)\client.dll"
	-@erase "$(OUTDIR)\client.exp"
	-@erase "$(OUTDIR)\client.lib"
	-@erase "$(OUTDIR)\client.map"
	-@erase "..\..\valve\cl_dlls\client.dll"

"$(OUTDIR)" :
    if not exist "$(OUTDIR)/$(NULL)" mkdir "$(OUTDIR)"

# ADD BASE CPP /nologo /MT /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_WINDOWS" /YX /c
# ADD CPP /nologo /MT /W3 /GX /Zi /O2 /D "WIN32" /D "NDEBUG" /D "_WINDOWS" /YX /c
CPP_PROJ=/nologo /MT /W3 /GX /Zi /O2 /D "WIN32" /D "NDEBUG" /D "_WINDOWS"\
 /Fp"$(INTDIR)/cl_dll.pch" /YX /Fo"$(INTDIR)/" /Fd"$(INTDIR)/" /c 
CPP_OBJS=.\Release/
CPP_SBRS=.\.
# ADD BASE MTL /nologo /D "NDEBUG" /win32
# ADD MTL /nologo /D "NDEBUG" /win32
MTL_PROJ=/nologo /D "NDEBUG" /win32 
# ADD BASE RSC /l 0x409 /d "NDEBUG"
# ADD RSC /l 0x409 /d "NDEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
BSC32_FLAGS=/nologo /o"$(OUTDIR)/cl_dll.bsc" 
BSC32_SBRS= \
	
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:windows /dll /machine:I386
# ADD LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib /nologo /subsystem:windows /dll /map /machine:I386 /out:"Release/client.dll"
LINK32_FLAGS=kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib\
 advapi32.lib shell32.lib ole32.lib /nologo /subsystem:windows /dll\
 /incremental:no /pdb:"$(OUTDIR)/client.pdb" /map:"$(INTDIR)/client.map"\
 /machine:I386 /out:"$(OUTDIR)/client.dll" /implib:"$(OUTDIR)/client.lib" 
LINK32_OBJS= \
	"$(INTDIR)\ammo.obj" \
	"$(INTDIR)\ammo_secondary.obj" \
	"$(INTDIR)\ammohistory.obj" \
	"$(INTDIR)\battery.obj" \
	"$(INTDIR)\cdll_int.obj" \
	"$(INTDIR)\death.obj" \
	"$(INTDIR)\flashlight.obj" \
	"$(INTDIR)\geiger.obj" \
	"$(INTDIR)\health.obj" \
	"$(INTDIR)\hud.obj" \
	"$(INTDIR)\hud_msg.obj" \
	"$(INTDIR)\hud_redraw.obj" \
	"$(INTDIR)\hud_update.obj" \
	"$(INTDIR)\menu.obj" \
	"$(INTDIR)\message.obj" \
	"$(INTDIR)\MOTD.obj" \
	"$(INTDIR)\parsemsg.obj" \
	"$(INTDIR)\saytext.obj" \
	"$(INTDIR)\scoreboard.obj" \
	"$(INTDIR)\status_icons.obj" \
	"$(INTDIR)\statusbar.obj" \
	"$(INTDIR)\text_message.obj" \
	"$(INTDIR)\train.obj" \
	"$(INTDIR)\util.obj"

"$(OUTDIR)\client.dll" : "$(OUTDIR)" $(DEF_FILE) $(LINK32_OBJS)
    $(LINK32) @<<
  $(LINK32_FLAGS) $(LINK32_OBJS)
<<

# Begin Custom Build - Copying to \quiver\valve\cl_dlls
TargetDir=.\Release
InputPath=.\Release\client.dll
SOURCE=$(InputPath)

"\quiver\valve\cl_dlls\client.dll" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
   copy $(TargetDir)\client.dll \quiver\valve\cl_dlls

# End Custom Build

!ELSEIF  "$(CFG)" == "cl_dll - Win32 Debug"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 1
# PROP BASE Output_Dir "Debug"
# PROP BASE Intermediate_Dir "Debug"
# PROP BASE Target_Dir ""
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 1
# PROP Output_Dir "Debug"
# PROP Intermediate_Dir "Debug"
# PROP Target_Dir ""
OUTDIR=.\Debug
INTDIR=.\Debug

ALL : "$(OUTDIR)\client.dll" "$(OUTDIR)\cl_dll.bsc"\
 "..\..\valve\cl_dlls\client.dll"

CLEAN : 
	-@erase "$(INTDIR)\ammo.obj"
	-@erase "$(INTDIR)\ammo.sbr"
	-@erase "$(INTDIR)\ammo_secondary.obj"
	-@erase "$(INTDIR)\ammo_secondary.sbr"
	-@erase "$(INTDIR)\ammohistory.obj"
	-@erase "$(INTDIR)\ammohistory.sbr"
	-@erase "$(INTDIR)\battery.obj"
	-@erase "$(INTDIR)\battery.sbr"
	-@erase "$(INTDIR)\cdll_int.obj"
	-@erase "$(INTDIR)\cdll_int.sbr"
	-@erase "$(INTDIR)\death.obj"
	-@erase "$(INTDIR)\death.sbr"
	-@erase "$(INTDIR)\flashlight.obj"
	-@erase "$(INTDIR)\flashlight.sbr"
	-@erase "$(INTDIR)\geiger.obj"
	-@erase "$(INTDIR)\geiger.sbr"
	-@erase "$(INTDIR)\health.obj"
	-@erase "$(INTDIR)\health.sbr"
	-@erase "$(INTDIR)\hud.obj"
	-@erase "$(INTDIR)\hud.sbr"
	-@erase "$(INTDIR)\hud_msg.obj"
	-@erase "$(INTDIR)\hud_msg.sbr"
	-@erase "$(INTDIR)\hud_redraw.obj"
	-@erase "$(INTDIR)\hud_redraw.sbr"
	-@erase "$(INTDIR)\hud_update.obj"
	-@erase "$(INTDIR)\hud_update.sbr"
	-@erase "$(INTDIR)\menu.obj"
	-@erase "$(INTDIR)\menu.sbr"
	-@erase "$(INTDIR)\message.obj"
	-@erase "$(INTDIR)\message.sbr"
	-@erase "$(INTDIR)\MOTD.obj"
	-@erase "$(INTDIR)\MOTD.sbr"
	-@erase "$(INTDIR)\parsemsg.obj"
	-@erase "$(INTDIR)\parsemsg.sbr"
	-@erase "$(INTDIR)\saytext.obj"
	-@erase "$(INTDIR)\saytext.sbr"
	-@erase "$(INTDIR)\scoreboard.obj"
	-@erase "$(INTDIR)\scoreboard.sbr"
	-@erase "$(INTDIR)\status_icons.obj"
	-@erase "$(INTDIR)\status_icons.sbr"
	-@erase "$(INTDIR)\statusbar.obj"
	-@erase "$(INTDIR)\statusbar.sbr"
	-@erase "$(INTDIR)\text_message.obj"
	-@erase "$(INTDIR)\text_message.sbr"
	-@erase "$(INTDIR)\train.obj"
	-@erase "$(INTDIR)\train.sbr"
	-@erase "$(INTDIR)\util.obj"
	-@erase "$(INTDIR)\util.sbr"
	-@erase "$(INTDIR)\vc40.idb"
	-@erase "$(INTDIR)\vc40.pdb"
	-@erase "$(OUTDIR)\cl_dll.bsc"
	-@erase "$(OUTDIR)\client.dll"
	-@erase "$(OUTDIR)\client.exp"
	-@erase "$(OUTDIR)\client.ilk"
	-@erase "$(OUTDIR)\client.lib"
	-@erase "$(OUTDIR)\client.pdb"
	-@erase "..\..\valve\cl_dlls\client.dll"

"$(OUTDIR)" :
    if not exist "$(OUTDIR)/$(NULL)" mkdir "$(OUTDIR)"

# ADD BASE CPP /nologo /MTd /W3 /Gm /GX /Zi /Od /D "WIN32" /D "_DEBUG" /D "_WINDOWS" /YX /c
# ADD CPP /nologo /G5 /MTd /W3 /Gm /GX /Zi /Od /D "WIN32" /D "_DEBUG" /D "_WINDOWS" /D "_MBCS" /FR /YX /c
CPP_PROJ=/nologo /G5 /MTd /W3 /Gm /GX /Zi /Od /D "WIN32" /D "_DEBUG" /D\
 "_WINDOWS" /D "_MBCS" /FR"$(INTDIR)/" /Fp"$(INTDIR)/cl_dll.pch" /YX\
 /Fo"$(INTDIR)/" /Fd"$(INTDIR)/" /c 
CPP_OBJS=.\Debug/
CPP_SBRS=.\Debug/
# ADD BASE MTL /nologo /D "_DEBUG" /win32
# ADD MTL /nologo /D "_DEBUG" /win32
MTL_PROJ=/nologo /D "_DEBUG" /win32 
# ADD BASE RSC /l 0x409 /d "_DEBUG"
# ADD RSC /l 0x409 /d "_DEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
BSC32_FLAGS=/nologo /o"$(OUTDIR)/cl_dll.bsc" 
BSC32_SBRS= \
	"$(INTDIR)\ammo.sbr" \
	"$(INTDIR)\ammo_secondary.sbr" \
	"$(INTDIR)\ammohistory.sbr" \
	"$(INTDIR)\battery.sbr" \
	"$(INTDIR)\cdll_int.sbr" \
	"$(INTDIR)\death.sbr" \
	"$(INTDIR)\flashlight.sbr" \
	"$(INTDIR)\geiger.sbr" \
	"$(INTDIR)\health.sbr" \
	"$(INTDIR)\hud.sbr" \
	"$(INTDIR)\hud_msg.sbr" \
	"$(INTDIR)\hud_redraw.sbr" \
	"$(INTDIR)\hud_update.sbr" \
	"$(INTDIR)\menu.sbr" \
	"$(INTDIR)\message.sbr" \
	"$(INTDIR)\MOTD.sbr" \
	"$(INTDIR)\parsemsg.sbr" \
	"$(INTDIR)\saytext.sbr" \
	"$(INTDIR)\scoreboard.sbr" \
	"$(INTDIR)\status_icons.sbr" \
	"$(INTDIR)\statusbar.sbr" \
	"$(INTDIR)\text_message.sbr" \
	"$(INTDIR)\train.sbr" \
	"$(INTDIR)\util.sbr"

"$(OUTDIR)\cl_dll.bsc" : "$(OUTDIR)" $(BSC32_SBRS)
    $(BSC32) @<<
  $(BSC32_FLAGS) $(BSC32_SBRS)
<<

LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:windows /dll /debug /machine:I386
# ADD LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:windows /dll /debug /machine:I386 /out:"Debug/client.dll"
LINK32_FLAGS=kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib\
 advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib\
 odbccp32.lib /nologo /subsystem:windows /dll /incremental:yes\
 /pdb:"$(OUTDIR)/client.pdb" /debug /machine:I386 /out:"$(OUTDIR)/client.dll"\
 /implib:"$(OUTDIR)/client.lib" 
LINK32_OBJS= \
	"$(INTDIR)\ammo.obj" \
	"$(INTDIR)\ammo_secondary.obj" \
	"$(INTDIR)\ammohistory.obj" \
	"$(INTDIR)\battery.obj" \
	"$(INTDIR)\cdll_int.obj" \
	"$(INTDIR)\death.obj" \
	"$(INTDIR)\flashlight.obj" \
	"$(INTDIR)\geiger.obj" \
	"$(INTDIR)\health.obj" \
	"$(INTDIR)\hud.obj" \
	"$(INTDIR)\hud_msg.obj" \
	"$(INTDIR)\hud_redraw.obj" \
	"$(INTDIR)\hud_update.obj" \
	"$(INTDIR)\menu.obj" \
	"$(INTDIR)\message.obj" \
	"$(INTDIR)\MOTD.obj" \
	"$(INTDIR)\parsemsg.obj" \
	"$(INTDIR)\saytext.obj" \
	"$(INTDIR)\scoreboard.obj" \
	"$(INTDIR)\status_icons.obj" \
	"$(INTDIR)\statusbar.obj" \
	"$(INTDIR)\text_message.obj" \
	"$(INTDIR)\train.obj" \
	"$(INTDIR)\util.obj"

"$(OUTDIR)\client.dll" : "$(OUTDIR)" $(DEF_FILE) $(LINK32_OBJS)
    $(LINK32) @<<
  $(LINK32_FLAGS) $(LINK32_OBJS)
<<

# Begin Custom Build - Copying to \quiver\valve\cl_dlls
TargetDir=.\Debug
InputPath=.\Debug\client.dll
SOURCE=$(InputPath)

"\quiver\valve\cl_dlls\client.dll" : $(SOURCE) "$(INTDIR)" "$(OUTDIR)"
   copy $(TargetDir)\client.dll \quiver\valve\cl_dlls

# End Custom Build

!ENDIF 

.c{$(CPP_OBJS)}.obj:
   $(CPP) $(CPP_PROJ) $<  

.cpp{$(CPP_OBJS)}.obj:
   $(CPP) $(CPP_PROJ) $<  

.cxx{$(CPP_OBJS)}.obj:
   $(CPP) $(CPP_PROJ) $<  

.c{$(CPP_SBRS)}.sbr:
   $(CPP) $(CPP_PROJ) $<  

.cpp{$(CPP_SBRS)}.sbr:
   $(CPP) $(CPP_PROJ) $<  

.cxx{$(CPP_SBRS)}.sbr:
   $(CPP) $(CPP_PROJ) $<  

################################################################################
# Begin Target

# Name "cl_dll - Win32 Release"
# Name "cl_dll - Win32 Debug"

!IF  "$(CFG)" == "cl_dll - Win32 Release"

!ELSEIF  "$(CFG)" == "cl_dll - Win32 Debug"

!ENDIF 

################################################################################
# Begin Source File

SOURCE=.\cl_dll.h

!IF  "$(CFG)" == "cl_dll - Win32 Release"

!ELSEIF  "$(CFG)" == "cl_dll - Win32 Debug"

!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=.\cdll_int.cpp

!IF  "$(CFG)" == "cl_dll - Win32 Release"

DEP_CPP_CDLL_=\
	"..\dlls\cdll_dll.h"\
	"..\engine\cdll_int.h"\
	".\ammo.h"\
	".\cl_dll.h"\
	".\health.h"\
	".\hud.h"\
	".\util.h"\
	".\util_vector.h"\
	

"$(INTDIR)\cdll_int.obj" : $(SOURCE) $(DEP_CPP_CDLL_) "$(INTDIR)"


!ELSEIF  "$(CFG)" == "cl_dll - Win32 Debug"

DEP_CPP_CDLL_=\
	"..\dlls\cdll_dll.h"\
	"..\engine\cdll_int.h"\
	".\ammo.h"\
	".\cl_dll.h"\
	".\health.h"\
	".\hud.h"\
	".\util.h"\
	".\util_vector.h"\
	

"$(INTDIR)\cdll_int.obj" : $(SOURCE) $(DEP_CPP_CDLL_) "$(INTDIR)"

"$(INTDIR)\cdll_int.sbr" : $(SOURCE) $(DEP_CPP_CDLL_) "$(INTDIR)"


!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=.\hud_redraw.cpp

!IF  "$(CFG)" == "cl_dll - Win32 Release"

DEP_CPP_HUD_R=\
	"..\dlls\cdll_dll.h"\
	"..\engine\cdll_int.h"\
	".\ammo.h"\
	".\cl_dll.h"\
	".\health.h"\
	".\hud.h"\
	".\util.h"\
	".\util_vector.h"\
	

"$(INTDIR)\hud_redraw.obj" : $(SOURCE) $(DEP_CPP_HUD_R) "$(INTDIR)"


!ELSEIF  "$(CFG)" == "cl_dll - Win32 Debug"

DEP_CPP_HUD_R=\
	"..\dlls\cdll_dll.h"\
	"..\engine\cdll_int.h"\
	".\ammo.h"\
	".\cl_dll.h"\
	".\health.h"\
	".\hud.h"\
	".\util.h"\
	".\util_vector.h"\
	

"$(INTDIR)\hud_redraw.obj" : $(SOURCE) $(DEP_CPP_HUD_R) "$(INTDIR)"

"$(INTDIR)\hud_redraw.sbr" : $(SOURCE) $(DEP_CPP_HUD_R) "$(INTDIR)"


!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=.\hud.cpp
DEP_CPP_HUD_C=\
	"..\dlls\cdll_dll.h"\
	"..\engine\cdll_int.h"\
	".\ammo.h"\
	".\cl_dll.h"\
	".\health.h"\
	".\hud.h"\
	".\parsemsg.h"\
	".\util.h"\
	".\util_vector.h"\
	

!IF  "$(CFG)" == "cl_dll - Win32 Release"


"$(INTDIR)\hud.obj" : $(SOURCE) $(DEP_CPP_HUD_C) "$(INTDIR)"


!ELSEIF  "$(CFG)" == "cl_dll - Win32 Debug"


"$(INTDIR)\hud.obj" : $(SOURCE) $(DEP_CPP_HUD_C) "$(INTDIR)"

"$(INTDIR)\hud.sbr" : $(SOURCE) $(DEP_CPP_HUD_C) "$(INTDIR)"


!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=.\parsemsg.cpp

!IF  "$(CFG)" == "cl_dll - Win32 Release"


"$(INTDIR)\parsemsg.obj" : $(SOURCE) "$(INTDIR)"


!ELSEIF  "$(CFG)" == "cl_dll - Win32 Debug"


"$(INTDIR)\parsemsg.obj" : $(SOURCE) "$(INTDIR)"

"$(INTDIR)\parsemsg.sbr" : $(SOURCE) "$(INTDIR)"


!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=.\hud_msg.cpp

!IF  "$(CFG)" == "cl_dll - Win32 Release"

DEP_CPP_HUD_M=\
	"..\dlls\cdll_dll.h"\
	"..\engine\cdll_int.h"\
	".\ammo.h"\
	".\cl_dll.h"\
	".\health.h"\
	".\hud.h"\
	".\parsemsg.h"\
	".\util.h"\
	".\util_vector.h"\
	

"$(INTDIR)\hud_msg.obj" : $(SOURCE) $(DEP_CPP_HUD_M) "$(INTDIR)"


!ELSEIF  "$(CFG)" == "cl_dll - Win32 Debug"

DEP_CPP_HUD_M=\
	"..\dlls\cdll_dll.h"\
	"..\engine\cdll_int.h"\
	".\ammo.h"\
	".\cl_dll.h"\
	".\health.h"\
	".\hud.h"\
	".\parsemsg.h"\
	".\util.h"\
	".\util_vector.h"\
	

"$(INTDIR)\hud_msg.obj" : $(SOURCE) $(DEP_CPP_HUD_M) "$(INTDIR)"

"$(INTDIR)\hud_msg.sbr" : $(SOURCE) $(DEP_CPP_HUD_M) "$(INTDIR)"


!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=.\hud_update.cpp

!IF  "$(CFG)" == "cl_dll - Win32 Release"

DEP_CPP_HUD_U=\
	"..\dlls\cdll_dll.h"\
	"..\engine\cdll_int.h"\
	".\ammo.h"\
	".\cl_dll.h"\
	".\health.h"\
	".\hud.h"\
	".\util.h"\
	".\util_vector.h"\
	

"$(INTDIR)\hud_update.obj" : $(SOURCE) $(DEP_CPP_HUD_U) "$(INTDIR)"


!ELSEIF  "$(CFG)" == "cl_dll - Win32 Debug"

DEP_CPP_HUD_U=\
	"..\dlls\cdll_dll.h"\
	"..\engine\cdll_int.h"\
	".\ammo.h"\
	".\cl_dll.h"\
	".\health.h"\
	".\hud.h"\
	".\util.h"\
	".\util_vector.h"\
	

"$(INTDIR)\hud_update.obj" : $(SOURCE) $(DEP_CPP_HUD_U) "$(INTDIR)"

"$(INTDIR)\hud_update.sbr" : $(SOURCE) $(DEP_CPP_HUD_U) "$(INTDIR)"


!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=.\util.h

!IF  "$(CFG)" == "cl_dll - Win32 Release"

!ELSEIF  "$(CFG)" == "cl_dll - Win32 Debug"

!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=.\parsemsg.h

!IF  "$(CFG)" == "cl_dll - Win32 Release"

!ELSEIF  "$(CFG)" == "cl_dll - Win32 Debug"

!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=.\hud.h

!IF  "$(CFG)" == "cl_dll - Win32 Release"

!ELSEIF  "$(CFG)" == "cl_dll - Win32 Debug"

!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=.\ammo.cpp
DEP_CPP_AMMO_=\
	"..\dlls\cdll_dll.h"\
	"..\engine\cdll_int.h"\
	".\ammo.h"\
	".\ammohistory.h"\
	".\cl_dll.h"\
	".\health.h"\
	".\hud.h"\
	".\parsemsg.h"\
	".\util.h"\
	".\util_vector.h"\
	

!IF  "$(CFG)" == "cl_dll - Win32 Release"


"$(INTDIR)\ammo.obj" : $(SOURCE) $(DEP_CPP_AMMO_) "$(INTDIR)"


!ELSEIF  "$(CFG)" == "cl_dll - Win32 Debug"


"$(INTDIR)\ammo.obj" : $(SOURCE) $(DEP_CPP_AMMO_) "$(INTDIR)"

"$(INTDIR)\ammo.sbr" : $(SOURCE) $(DEP_CPP_AMMO_) "$(INTDIR)"


!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=.\geiger.cpp
DEP_CPP_GEIGE=\
	"..\dlls\cdll_dll.h"\
	"..\engine\cdll_int.h"\
	".\ammo.h"\
	".\cl_dll.h"\
	".\health.h"\
	".\hud.h"\
	".\parsemsg.h"\
	".\util.h"\
	".\util_vector.h"\
	

!IF  "$(CFG)" == "cl_dll - Win32 Release"


"$(INTDIR)\geiger.obj" : $(SOURCE) $(DEP_CPP_GEIGE) "$(INTDIR)"


!ELSEIF  "$(CFG)" == "cl_dll - Win32 Debug"


"$(INTDIR)\geiger.obj" : $(SOURCE) $(DEP_CPP_GEIGE) "$(INTDIR)"

"$(INTDIR)\geiger.sbr" : $(SOURCE) $(DEP_CPP_GEIGE) "$(INTDIR)"


!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=.\health.cpp
DEP_CPP_HEALT=\
	"..\dlls\cdll_dll.h"\
	"..\engine\cdll_int.h"\
	".\ammo.h"\
	".\cl_dll.h"\
	".\health.h"\
	".\hud.h"\
	".\parsemsg.h"\
	".\util.h"\
	".\util_vector.h"\
	

!IF  "$(CFG)" == "cl_dll - Win32 Release"


"$(INTDIR)\health.obj" : $(SOURCE) $(DEP_CPP_HEALT) "$(INTDIR)"


!ELSEIF  "$(CFG)" == "cl_dll - Win32 Debug"


"$(INTDIR)\health.obj" : $(SOURCE) $(DEP_CPP_HEALT) "$(INTDIR)"

"$(INTDIR)\health.sbr" : $(SOURCE) $(DEP_CPP_HEALT) "$(INTDIR)"


!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=.\battery.cpp
DEP_CPP_BATTE=\
	"..\dlls\cdll_dll.h"\
	"..\engine\cdll_int.h"\
	".\ammo.h"\
	".\cl_dll.h"\
	".\health.h"\
	".\hud.h"\
	".\parsemsg.h"\
	".\util.h"\
	".\util_vector.h"\
	

!IF  "$(CFG)" == "cl_dll - Win32 Release"


"$(INTDIR)\battery.obj" : $(SOURCE) $(DEP_CPP_BATTE) "$(INTDIR)"


!ELSEIF  "$(CFG)" == "cl_dll - Win32 Debug"


"$(INTDIR)\battery.obj" : $(SOURCE) $(DEP_CPP_BATTE) "$(INTDIR)"

"$(INTDIR)\battery.sbr" : $(SOURCE) $(DEP_CPP_BATTE) "$(INTDIR)"


!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=.\util.cpp
DEP_CPP_UTIL_=\
	"..\dlls\cdll_dll.h"\
	"..\engine\cdll_int.h"\
	".\ammo.h"\
	".\cl_dll.h"\
	".\health.h"\
	".\hud.h"\
	".\util.h"\
	".\util_vector.h"\
	

!IF  "$(CFG)" == "cl_dll - Win32 Release"


"$(INTDIR)\util.obj" : $(SOURCE) $(DEP_CPP_UTIL_) "$(INTDIR)"


!ELSEIF  "$(CFG)" == "cl_dll - Win32 Debug"


"$(INTDIR)\util.obj" : $(SOURCE) $(DEP_CPP_UTIL_) "$(INTDIR)"

"$(INTDIR)\util.sbr" : $(SOURCE) $(DEP_CPP_UTIL_) "$(INTDIR)"


!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=.\util_vector.h

!IF  "$(CFG)" == "cl_dll - Win32 Release"

!ELSEIF  "$(CFG)" == "cl_dll - Win32 Debug"

!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=.\train.cpp
DEP_CPP_TRAIN=\
	"..\dlls\cdll_dll.h"\
	"..\engine\cdll_int.h"\
	".\ammo.h"\
	".\cl_dll.h"\
	".\health.h"\
	".\hud.h"\
	".\parsemsg.h"\
	".\util.h"\
	".\util_vector.h"\
	

!IF  "$(CFG)" == "cl_dll - Win32 Release"


"$(INTDIR)\train.obj" : $(SOURCE) $(DEP_CPP_TRAIN) "$(INTDIR)"


!ELSEIF  "$(CFG)" == "cl_dll - Win32 Debug"


"$(INTDIR)\train.obj" : $(SOURCE) $(DEP_CPP_TRAIN) "$(INTDIR)"

"$(INTDIR)\train.sbr" : $(SOURCE) $(DEP_CPP_TRAIN) "$(INTDIR)"


!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=.\flashlight.cpp
DEP_CPP_FLASH=\
	"..\dlls\cdll_dll.h"\
	"..\engine\cdll_int.h"\
	".\ammo.h"\
	".\cl_dll.h"\
	".\health.h"\
	".\hud.h"\
	".\parsemsg.h"\
	".\util.h"\
	".\util_vector.h"\
	

!IF  "$(CFG)" == "cl_dll - Win32 Release"


"$(INTDIR)\flashlight.obj" : $(SOURCE) $(DEP_CPP_FLASH) "$(INTDIR)"


!ELSEIF  "$(CFG)" == "cl_dll - Win32 Debug"


"$(INTDIR)\flashlight.obj" : $(SOURCE) $(DEP_CPP_FLASH) "$(INTDIR)"

"$(INTDIR)\flashlight.sbr" : $(SOURCE) $(DEP_CPP_FLASH) "$(INTDIR)"


!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=.\message.cpp
DEP_CPP_MESSA=\
	"..\dlls\cdll_dll.h"\
	"..\engine\cdll_int.h"\
	".\ammo.h"\
	".\cl_dll.h"\
	".\health.h"\
	".\hud.h"\
	".\parsemsg.h"\
	".\util.h"\
	".\util_vector.h"\
	

!IF  "$(CFG)" == "cl_dll - Win32 Release"


"$(INTDIR)\message.obj" : $(SOURCE) $(DEP_CPP_MESSA) "$(INTDIR)"


!ELSEIF  "$(CFG)" == "cl_dll - Win32 Debug"


"$(INTDIR)\message.obj" : $(SOURCE) $(DEP_CPP_MESSA) "$(INTDIR)"

"$(INTDIR)\message.sbr" : $(SOURCE) $(DEP_CPP_MESSA) "$(INTDIR)"


!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=.\scoreboard.cpp
DEP_CPP_SCORE=\
	"..\dlls\cdll_dll.h"\
	"..\engine\cdll_int.h"\
	".\ammo.h"\
	".\cl_dll.h"\
	".\health.h"\
	".\hud.h"\
	".\parsemsg.h"\
	".\util.h"\
	".\util_vector.h"\
	

!IF  "$(CFG)" == "cl_dll - Win32 Release"


"$(INTDIR)\scoreboard.obj" : $(SOURCE) $(DEP_CPP_SCORE) "$(INTDIR)"


!ELSEIF  "$(CFG)" == "cl_dll - Win32 Debug"


"$(INTDIR)\scoreboard.obj" : $(SOURCE) $(DEP_CPP_SCORE) "$(INTDIR)"

"$(INTDIR)\scoreboard.sbr" : $(SOURCE) $(DEP_CPP_SCORE) "$(INTDIR)"


!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=.\MOTD.cpp
DEP_CPP_MOTD_=\
	"..\dlls\cdll_dll.h"\
	"..\engine\cdll_int.h"\
	".\ammo.h"\
	".\cl_dll.h"\
	".\health.h"\
	".\hud.h"\
	".\parsemsg.h"\
	".\util.h"\
	".\util_vector.h"\
	

!IF  "$(CFG)" == "cl_dll - Win32 Release"


"$(INTDIR)\MOTD.obj" : $(SOURCE) $(DEP_CPP_MOTD_) "$(INTDIR)"


!ELSEIF  "$(CFG)" == "cl_dll - Win32 Debug"


"$(INTDIR)\MOTD.obj" : $(SOURCE) $(DEP_CPP_MOTD_) "$(INTDIR)"

"$(INTDIR)\MOTD.sbr" : $(SOURCE) $(DEP_CPP_MOTD_) "$(INTDIR)"


!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=.\ammohistory.cpp
DEP_CPP_AMMOH=\
	"..\dlls\cdll_dll.h"\
	"..\engine\cdll_int.h"\
	".\ammo.h"\
	".\ammohistory.h"\
	".\cl_dll.h"\
	".\health.h"\
	".\hud.h"\
	".\parsemsg.h"\
	".\util.h"\
	".\util_vector.h"\
	

!IF  "$(CFG)" == "cl_dll - Win32 Release"


"$(INTDIR)\ammohistory.obj" : $(SOURCE) $(DEP_CPP_AMMOH) "$(INTDIR)"


!ELSEIF  "$(CFG)" == "cl_dll - Win32 Debug"


"$(INTDIR)\ammohistory.obj" : $(SOURCE) $(DEP_CPP_AMMOH) "$(INTDIR)"

"$(INTDIR)\ammohistory.sbr" : $(SOURCE) $(DEP_CPP_AMMOH) "$(INTDIR)"


!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=.\saytext.cpp
DEP_CPP_SAYTE=\
	"..\dlls\cdll_dll.h"\
	"..\engine\cdll_int.h"\
	".\ammo.h"\
	".\cl_dll.h"\
	".\health.h"\
	".\hud.h"\
	".\parsemsg.h"\
	".\util.h"\
	".\util_vector.h"\
	

!IF  "$(CFG)" == "cl_dll - Win32 Release"


"$(INTDIR)\saytext.obj" : $(SOURCE) $(DEP_CPP_SAYTE) "$(INTDIR)"


!ELSEIF  "$(CFG)" == "cl_dll - Win32 Debug"


"$(INTDIR)\saytext.obj" : $(SOURCE) $(DEP_CPP_SAYTE) "$(INTDIR)"

"$(INTDIR)\saytext.sbr" : $(SOURCE) $(DEP_CPP_SAYTE) "$(INTDIR)"


!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=.\death.cpp
DEP_CPP_DEATH=\
	"..\dlls\cdll_dll.h"\
	"..\engine\cdll_int.h"\
	".\ammo.h"\
	".\cl_dll.h"\
	".\health.h"\
	".\hud.h"\
	".\parsemsg.h"\
	".\util.h"\
	".\util_vector.h"\
	

!IF  "$(CFG)" == "cl_dll - Win32 Release"


"$(INTDIR)\death.obj" : $(SOURCE) $(DEP_CPP_DEATH) "$(INTDIR)"


!ELSEIF  "$(CFG)" == "cl_dll - Win32 Debug"


"$(INTDIR)\death.obj" : $(SOURCE) $(DEP_CPP_DEATH) "$(INTDIR)"

"$(INTDIR)\death.sbr" : $(SOURCE) $(DEP_CPP_DEATH) "$(INTDIR)"


!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=.\menu.cpp
DEP_CPP_MENU_=\
	"..\dlls\cdll_dll.h"\
	"..\engine\cdll_int.h"\
	".\ammo.h"\
	".\cl_dll.h"\
	".\health.h"\
	".\hud.h"\
	".\parsemsg.h"\
	".\util.h"\
	".\util_vector.h"\
	

!IF  "$(CFG)" == "cl_dll - Win32 Release"


"$(INTDIR)\menu.obj" : $(SOURCE) $(DEP_CPP_MENU_) "$(INTDIR)"


!ELSEIF  "$(CFG)" == "cl_dll - Win32 Debug"


"$(INTDIR)\menu.obj" : $(SOURCE) $(DEP_CPP_MENU_) "$(INTDIR)"

"$(INTDIR)\menu.sbr" : $(SOURCE) $(DEP_CPP_MENU_) "$(INTDIR)"


!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=.\ammo_secondary.cpp
DEP_CPP_AMMO_S=\
	"..\dlls\cdll_dll.h"\
	"..\engine\cdll_int.h"\
	".\ammo.h"\
	".\cl_dll.h"\
	".\health.h"\
	".\hud.h"\
	".\parsemsg.h"\
	".\util.h"\
	".\util_vector.h"\
	

!IF  "$(CFG)" == "cl_dll - Win32 Release"


"$(INTDIR)\ammo_secondary.obj" : $(SOURCE) $(DEP_CPP_AMMO_S) "$(INTDIR)"


!ELSEIF  "$(CFG)" == "cl_dll - Win32 Debug"


"$(INTDIR)\ammo_secondary.obj" : $(SOURCE) $(DEP_CPP_AMMO_S) "$(INTDIR)"

"$(INTDIR)\ammo_secondary.sbr" : $(SOURCE) $(DEP_CPP_AMMO_S) "$(INTDIR)"


!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=.\statusbar.cpp
DEP_CPP_STATU=\
	"..\dlls\cdll_dll.h"\
	"..\engine\cdll_int.h"\
	".\ammo.h"\
	".\cl_dll.h"\
	".\health.h"\
	".\hud.h"\
	".\parsemsg.h"\
	".\util.h"\
	".\util_vector.h"\
	

!IF  "$(CFG)" == "cl_dll - Win32 Release"


"$(INTDIR)\statusbar.obj" : $(SOURCE) $(DEP_CPP_STATU) "$(INTDIR)"


!ELSEIF  "$(CFG)" == "cl_dll - Win32 Debug"


"$(INTDIR)\statusbar.obj" : $(SOURCE) $(DEP_CPP_STATU) "$(INTDIR)"

"$(INTDIR)\statusbar.sbr" : $(SOURCE) $(DEP_CPP_STATU) "$(INTDIR)"


!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=.\text_message.cpp
DEP_CPP_TEXT_=\
	"..\dlls\cdll_dll.h"\
	"..\engine\cdll_int.h"\
	".\ammo.h"\
	".\cl_dll.h"\
	".\health.h"\
	".\hud.h"\
	".\parsemsg.h"\
	".\util.h"\
	".\util_vector.h"\
	

!IF  "$(CFG)" == "cl_dll - Win32 Release"


"$(INTDIR)\text_message.obj" : $(SOURCE) $(DEP_CPP_TEXT_) "$(INTDIR)"


!ELSEIF  "$(CFG)" == "cl_dll - Win32 Debug"


"$(INTDIR)\text_message.obj" : $(SOURCE) $(DEP_CPP_TEXT_) "$(INTDIR)"

"$(INTDIR)\text_message.sbr" : $(SOURCE) $(DEP_CPP_TEXT_) "$(INTDIR)"


!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=.\status_icons.cpp
DEP_CPP_STATUS=\
	"..\dlls\cdll_dll.h"\
	"..\engine\cdll_int.h"\
	".\ammo.h"\
	".\cl_dll.h"\
	".\health.h"\
	".\hud.h"\
	".\parsemsg.h"\
	".\util.h"\
	".\util_vector.h"\
	

!IF  "$(CFG)" == "cl_dll - Win32 Release"


"$(INTDIR)\status_icons.obj" : $(SOURCE) $(DEP_CPP_STATUS) "$(INTDIR)"


!ELSEIF  "$(CFG)" == "cl_dll - Win32 Debug"


"$(INTDIR)\status_icons.obj" : $(SOURCE) $(DEP_CPP_STATUS) "$(INTDIR)"

"$(INTDIR)\status_icons.sbr" : $(SOURCE) $(DEP_CPP_STATUS) "$(INTDIR)"


!ENDIF 

# End Source File
# End Target
# End Project
################################################################################

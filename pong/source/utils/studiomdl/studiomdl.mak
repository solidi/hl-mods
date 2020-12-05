# Microsoft Developer Studio Generated NMAKE File, Format Version 4.20
# ** DO NOT EDIT **

# TARGTYPE "Win32 (x86) Console Application" 0x0103

!IF "$(CFG)" == ""
CFG=studiomdl - Win32 Debug
!MESSAGE No configuration specified.  Defaulting to studiomdl - Win32 Debug.
!ENDIF 

!IF "$(CFG)" != "studiomdl - Win32 Release" && "$(CFG)" !=\
 "studiomdl - Win32 Debug"
!MESSAGE Invalid configuration "$(CFG)" specified.
!MESSAGE You can specify a configuration when running NMAKE on this makefile
!MESSAGE by defining the macro CFG on the command line.  For example:
!MESSAGE 
!MESSAGE NMAKE /f "studiomdl.mak" CFG="studiomdl - Win32 Debug"
!MESSAGE 
!MESSAGE Possible choices for configuration are:
!MESSAGE 
!MESSAGE "studiomdl - Win32 Release" (based on\
 "Win32 (x86) Console Application")
!MESSAGE "studiomdl - Win32 Debug" (based on "Win32 (x86) Console Application")
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
# PROP Target_Last_Scanned "studiomdl - Win32 Debug"
CPP=cl.exe
RSC=rc.exe

!IF  "$(CFG)" == "studiomdl - Win32 Release"

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

ALL : "$(OUTDIR)\studiomdl.exe" "$(OUTDIR)\studiomdl.bsc"

CLEAN : 
	-@erase "$(INTDIR)\bmpread.obj"
	-@erase "$(INTDIR)\bmpread.sbr"
	-@erase "$(INTDIR)\cmdlib.obj"
	-@erase "$(INTDIR)\cmdlib.sbr"
	-@erase "$(INTDIR)\lbmlib.obj"
	-@erase "$(INTDIR)\lbmlib.sbr"
	-@erase "$(INTDIR)\mathlib.obj"
	-@erase "$(INTDIR)\mathlib.sbr"
	-@erase "$(INTDIR)\scriplib.obj"
	-@erase "$(INTDIR)\scriplib.sbr"
	-@erase "$(INTDIR)\studiomdl.obj"
	-@erase "$(INTDIR)\studiomdl.sbr"
	-@erase "$(INTDIR)\trilib.obj"
	-@erase "$(INTDIR)\trilib.sbr"
	-@erase "$(INTDIR)\tristrip.obj"
	-@erase "$(INTDIR)\tristrip.sbr"
	-@erase "$(INTDIR)\write.obj"
	-@erase "$(INTDIR)\write.sbr"
	-@erase "$(OUTDIR)\studiomdl.bsc"
	-@erase "$(OUTDIR)\studiomdl.exe"

"$(OUTDIR)" :
    if not exist "$(OUTDIR)/$(NULL)" mkdir "$(OUTDIR)"

# ADD BASE CPP /nologo /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_CONSOLE" /YX /c
# ADD CPP /nologo /MT /W3 /GX /O2 /I "..\common" /D "WIN32" /D "NDEBUG" /D "_CONSOLE" /FR /YX /c
CPP_PROJ=/nologo /MT /W3 /GX /O2 /I "..\common" /D "WIN32" /D "NDEBUG" /D\
 "_CONSOLE" /FR"$(INTDIR)/" /Fp"$(INTDIR)/studiomdl.pch" /YX /Fo"$(INTDIR)/" /c 
CPP_OBJS=.\Release/
CPP_SBRS=.\Release/
# ADD BASE RSC /l 0x409 /d "NDEBUG"
# ADD RSC /l 0x409 /d "NDEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
BSC32_FLAGS=/nologo /o"$(OUTDIR)/studiomdl.bsc" 
BSC32_SBRS= \
	"$(INTDIR)\bmpread.sbr" \
	"$(INTDIR)\cmdlib.sbr" \
	"$(INTDIR)\lbmlib.sbr" \
	"$(INTDIR)\mathlib.sbr" \
	"$(INTDIR)\scriplib.sbr" \
	"$(INTDIR)\studiomdl.sbr" \
	"$(INTDIR)\trilib.sbr" \
	"$(INTDIR)\tristrip.sbr" \
	"$(INTDIR)\write.sbr"

"$(OUTDIR)\studiomdl.bsc" : "$(OUTDIR)" $(BSC32_SBRS)
    $(BSC32) @<<
  $(BSC32_FLAGS) $(BSC32_SBRS)
<<

LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib /nologo /subsystem:console /machine:I386
# ADD LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib /nologo /subsystem:console /machine:I386
LINK32_FLAGS=kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib\
 advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib /nologo\
 /subsystem:console /incremental:no /pdb:"$(OUTDIR)/studiomdl.pdb" /machine:I386\
 /out:"$(OUTDIR)/studiomdl.exe" 
LINK32_OBJS= \
	"$(INTDIR)\bmpread.obj" \
	"$(INTDIR)\cmdlib.obj" \
	"$(INTDIR)\lbmlib.obj" \
	"$(INTDIR)\mathlib.obj" \
	"$(INTDIR)\scriplib.obj" \
	"$(INTDIR)\studiomdl.obj" \
	"$(INTDIR)\trilib.obj" \
	"$(INTDIR)\tristrip.obj" \
	"$(INTDIR)\write.obj"

"$(OUTDIR)\studiomdl.exe" : "$(OUTDIR)" $(DEF_FILE) $(LINK32_OBJS)
    $(LINK32) @<<
  $(LINK32_FLAGS) $(LINK32_OBJS)
<<

!ELSEIF  "$(CFG)" == "studiomdl - Win32 Debug"

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

ALL : "$(OUTDIR)\studiomdl.exe" "$(OUTDIR)\studiomdl.bsc"

CLEAN : 
	-@erase "$(INTDIR)\bmpread.obj"
	-@erase "$(INTDIR)\bmpread.sbr"
	-@erase "$(INTDIR)\cmdlib.obj"
	-@erase "$(INTDIR)\cmdlib.sbr"
	-@erase "$(INTDIR)\lbmlib.obj"
	-@erase "$(INTDIR)\lbmlib.sbr"
	-@erase "$(INTDIR)\mathlib.obj"
	-@erase "$(INTDIR)\mathlib.sbr"
	-@erase "$(INTDIR)\scriplib.obj"
	-@erase "$(INTDIR)\scriplib.sbr"
	-@erase "$(INTDIR)\studiomdl.obj"
	-@erase "$(INTDIR)\studiomdl.sbr"
	-@erase "$(INTDIR)\trilib.obj"
	-@erase "$(INTDIR)\trilib.sbr"
	-@erase "$(INTDIR)\tristrip.obj"
	-@erase "$(INTDIR)\tristrip.sbr"
	-@erase "$(INTDIR)\vc40.idb"
	-@erase "$(INTDIR)\vc40.pdb"
	-@erase "$(INTDIR)\write.obj"
	-@erase "$(INTDIR)\write.sbr"
	-@erase "$(OUTDIR)\studiomdl.bsc"
	-@erase "$(OUTDIR)\studiomdl.exe"
	-@erase "$(OUTDIR)\studiomdl.ilk"
	-@erase "$(OUTDIR)\studiomdl.pdb"

"$(OUTDIR)" :
    if not exist "$(OUTDIR)/$(NULL)" mkdir "$(OUTDIR)"

# ADD BASE CPP /nologo /W3 /Gm /GX /Zi /Od /D "WIN32" /D "_DEBUG" /D "_CONSOLE" /YX /c
# ADD CPP /nologo /MTd /W3 /Gm /GX /Zi /Od /I "..\common" /D "WIN32" /D "_DEBUG" /D "_CONSOLE" /FR /YX /c
CPP_PROJ=/nologo /MTd /W3 /Gm /GX /Zi /Od /I "..\common" /D "WIN32" /D "_DEBUG"\
 /D "_CONSOLE" /FR"$(INTDIR)/" /Fp"$(INTDIR)/studiomdl.pch" /YX /Fo"$(INTDIR)/"\
 /Fd"$(INTDIR)/" /c 
CPP_OBJS=.\Debug/
CPP_SBRS=.\Debug/
# ADD BASE RSC /l 0x409 /d "_DEBUG"
# ADD RSC /l 0x409 /d "_DEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
BSC32_FLAGS=/nologo /o"$(OUTDIR)/studiomdl.bsc" 
BSC32_SBRS= \
	"$(INTDIR)\bmpread.sbr" \
	"$(INTDIR)\cmdlib.sbr" \
	"$(INTDIR)\lbmlib.sbr" \
	"$(INTDIR)\mathlib.sbr" \
	"$(INTDIR)\scriplib.sbr" \
	"$(INTDIR)\studiomdl.sbr" \
	"$(INTDIR)\trilib.sbr" \
	"$(INTDIR)\tristrip.sbr" \
	"$(INTDIR)\write.sbr"

"$(OUTDIR)\studiomdl.bsc" : "$(OUTDIR)" $(BSC32_SBRS)
    $(BSC32) @<<
  $(BSC32_FLAGS) $(BSC32_SBRS)
<<

LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib /nologo /subsystem:console /debug /machine:I386
# ADD LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib /nologo /subsystem:console /debug /machine:I386
LINK32_FLAGS=kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib\
 advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib /nologo\
 /subsystem:console /incremental:yes /pdb:"$(OUTDIR)/studiomdl.pdb" /debug\
 /machine:I386 /out:"$(OUTDIR)/studiomdl.exe" 
LINK32_OBJS= \
	"$(INTDIR)\bmpread.obj" \
	"$(INTDIR)\cmdlib.obj" \
	"$(INTDIR)\lbmlib.obj" \
	"$(INTDIR)\mathlib.obj" \
	"$(INTDIR)\scriplib.obj" \
	"$(INTDIR)\studiomdl.obj" \
	"$(INTDIR)\trilib.obj" \
	"$(INTDIR)\tristrip.obj" \
	"$(INTDIR)\write.obj"

"$(OUTDIR)\studiomdl.exe" : "$(OUTDIR)" $(DEF_FILE) $(LINK32_OBJS)
    $(LINK32) @<<
  $(LINK32_FLAGS) $(LINK32_OBJS)
<<

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

# Name "studiomdl - Win32 Release"
# Name "studiomdl - Win32 Debug"

!IF  "$(CFG)" == "studiomdl - Win32 Release"

!ELSEIF  "$(CFG)" == "studiomdl - Win32 Debug"

!ENDIF 

################################################################################
# Begin Source File

SOURCE=.\studiomdl.c
DEP_CPP_STUDI=\
	"..\..\dlls\activity.h"\
	"..\..\dlls\activitymap.h"\
	"..\..\engine\studio.h"\
	"..\common\cmdlib.h"\
	"..\common\lbmlib.h"\
	"..\common\mathlib.h"\
	"..\common\scriplib.h"\
	".\studiomdl.h"\
	{$(INCLUDE)}"\sys\STAT.H"\
	{$(INCLUDE)}"\sys\TYPES.H"\
	

"$(INTDIR)\studiomdl.obj" : $(SOURCE) $(DEP_CPP_STUDI) "$(INTDIR)"

"$(INTDIR)\studiomdl.sbr" : $(SOURCE) $(DEP_CPP_STUDI) "$(INTDIR)"


# End Source File
################################################################################
# Begin Source File

SOURCE=.\bmpread.c

"$(INTDIR)\bmpread.obj" : $(SOURCE) "$(INTDIR)"

"$(INTDIR)\bmpread.sbr" : $(SOURCE) "$(INTDIR)"


# End Source File
################################################################################
# Begin Source File

SOURCE=.\write.c
DEP_CPP_WRITE=\
	"..\..\engine\studio.h"\
	"..\common\cmdlib.h"\
	"..\common\lbmlib.h"\
	"..\common\mathlib.h"\
	"..\common\scriplib.h"\
	".\studiomdl.h"\
	{$(INCLUDE)}"\sys\STAT.H"\
	{$(INCLUDE)}"\sys\TYPES.H"\
	

"$(INTDIR)\write.obj" : $(SOURCE) $(DEP_CPP_WRITE) "$(INTDIR)"

"$(INTDIR)\write.sbr" : $(SOURCE) $(DEP_CPP_WRITE) "$(INTDIR)"


# End Source File
################################################################################
# Begin Source File

SOURCE=.\tristrip.c
DEP_CPP_TRIST=\
	"..\..\engine\studio.h"\
	"..\common\cmdlib.h"\
	"..\common\lbmlib.h"\
	"..\common\mathlib.h"\
	"..\common\scriplib.h"\
	".\studiomdl.h"\
	{$(INCLUDE)}"\sys\STAT.H"\
	{$(INCLUDE)}"\sys\TYPES.H"\
	

"$(INTDIR)\tristrip.obj" : $(SOURCE) $(DEP_CPP_TRIST) "$(INTDIR)"

"$(INTDIR)\tristrip.sbr" : $(SOURCE) $(DEP_CPP_TRIST) "$(INTDIR)"


# End Source File
################################################################################
# Begin Source File

SOURCE=..\common\mathlib.c
DEP_CPP_MATHL=\
	"..\common\cmdlib.h"\
	"..\common\mathlib.h"\
	

BuildCmds= \
	$(CPP) $(CPP_PROJ) $(SOURCE) \
	

"$(INTDIR)\mathlib.obj" : $(SOURCE) $(DEP_CPP_MATHL) "$(INTDIR)"
   $(BuildCmds)

"$(INTDIR)\mathlib.sbr" : $(SOURCE) $(DEP_CPP_MATHL) "$(INTDIR)"
   $(BuildCmds)

# End Source File
################################################################################
# Begin Source File

SOURCE=..\common\cmdlib.c
DEP_CPP_CMDLI=\
	"..\common\cmdlib.h"\
	{$(INCLUDE)}"\sys\STAT.H"\
	{$(INCLUDE)}"\sys\TYPES.H"\
	

BuildCmds= \
	$(CPP) $(CPP_PROJ) $(SOURCE) \
	

"$(INTDIR)\cmdlib.obj" : $(SOURCE) $(DEP_CPP_CMDLI) "$(INTDIR)"
   $(BuildCmds)

"$(INTDIR)\cmdlib.sbr" : $(SOURCE) $(DEP_CPP_CMDLI) "$(INTDIR)"
   $(BuildCmds)

# End Source File
################################################################################
# Begin Source File

SOURCE=..\common\lbmlib.c
DEP_CPP_LBMLI=\
	"..\common\cmdlib.h"\
	"..\common\lbmlib.h"\
	

BuildCmds= \
	$(CPP) $(CPP_PROJ) $(SOURCE) \
	

"$(INTDIR)\lbmlib.obj" : $(SOURCE) $(DEP_CPP_LBMLI) "$(INTDIR)"
   $(BuildCmds)

"$(INTDIR)\lbmlib.sbr" : $(SOURCE) $(DEP_CPP_LBMLI) "$(INTDIR)"
   $(BuildCmds)

# End Source File
################################################################################
# Begin Source File

SOURCE=..\common\scriplib.c
DEP_CPP_SCRIP=\
	"..\common\cmdlib.h"\
	"..\common\scriplib.h"\
	

BuildCmds= \
	$(CPP) $(CPP_PROJ) $(SOURCE) \
	

"$(INTDIR)\scriplib.obj" : $(SOURCE) $(DEP_CPP_SCRIP) "$(INTDIR)"
   $(BuildCmds)

"$(INTDIR)\scriplib.sbr" : $(SOURCE) $(DEP_CPP_SCRIP) "$(INTDIR)"
   $(BuildCmds)

# End Source File
################################################################################
# Begin Source File

SOURCE=..\common\trilib.c
DEP_CPP_TRILI=\
	"..\common\cmdlib.h"\
	"..\common\mathlib.h"\
	"..\common\trilib.h"\
	

BuildCmds= \
	$(CPP) $(CPP_PROJ) $(SOURCE) \
	

"$(INTDIR)\trilib.obj" : $(SOURCE) $(DEP_CPP_TRILI) "$(INTDIR)"
   $(BuildCmds)

"$(INTDIR)\trilib.sbr" : $(SOURCE) $(DEP_CPP_TRILI) "$(INTDIR)"
   $(BuildCmds)

# End Source File
# End Target
# End Project
################################################################################

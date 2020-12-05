# Microsoft Developer Studio Generated NMAKE File, Format Version 4.20
# ** DO NOT EDIT **

# TARGTYPE "Win32 (x86) Console Application" 0x0103

!IF "$(CFG)" == ""
CFG=sprgen - Win32 Debug
!MESSAGE No configuration specified.  Defaulting to sprgen - Win32 Debug.
!ENDIF 

!IF "$(CFG)" != "sprgen - Win32 Release" && "$(CFG)" != "sprgen - Win32 Debug"
!MESSAGE Invalid configuration "$(CFG)" specified.
!MESSAGE You can specify a configuration when running NMAKE on this makefile
!MESSAGE by defining the macro CFG on the command line.  For example:
!MESSAGE 
!MESSAGE NMAKE /f "sprgen.mak" CFG="sprgen - Win32 Debug"
!MESSAGE 
!MESSAGE Possible choices for configuration are:
!MESSAGE 
!MESSAGE "sprgen - Win32 Release" (based on "Win32 (x86) Console Application")
!MESSAGE "sprgen - Win32 Debug" (based on "Win32 (x86) Console Application")
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
# PROP Target_Last_Scanned "sprgen - Win32 Debug"
CPP=cl.exe
RSC=rc.exe

!IF  "$(CFG)" == "sprgen - Win32 Release"

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

ALL : "$(OUTDIR)\sprgen.exe"

CLEAN : 
	-@erase "$(INTDIR)\cmdlib.obj"
	-@erase "$(INTDIR)\lbmlib.obj"
	-@erase "$(INTDIR)\scriplib.obj"
	-@erase "$(INTDIR)\sprgen.obj"
	-@erase "$(INTDIR)\vc40.pdb"
	-@erase "$(OUTDIR)\sprgen.exe"
	-@erase "$(OUTDIR)\sprgen.pdb"

"$(OUTDIR)" :
    if not exist "$(OUTDIR)/$(NULL)" mkdir "$(OUTDIR)"

# ADD BASE CPP /nologo /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_CONSOLE" /YX /c
# ADD CPP /nologo /W3 /GX /Zi /O1 /I "..\common" /D "WIN32" /D "NDEBUG" /D "_CONSOLE" /YX /c
CPP_PROJ=/nologo /ML /W3 /GX /Zi /O1 /I "..\common" /D "WIN32" /D "NDEBUG" /D\
 "_CONSOLE" /Fp"$(INTDIR)/sprgen.pch" /YX /Fo"$(INTDIR)/" /Fd"$(INTDIR)/" /c 
CPP_OBJS=.\Release/
CPP_SBRS=.\.
# ADD BASE RSC /l 0x409 /d "NDEBUG"
# ADD RSC /l 0x409 /d "NDEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
BSC32_FLAGS=/nologo /o"$(OUTDIR)/sprgen.bsc" 
BSC32_SBRS= \
	
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:console /machine:I386
# ADD LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib /nologo /subsystem:console /debug /machine:I386
LINK32_FLAGS=kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib\
 advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib /nologo\
 /subsystem:console /incremental:no /pdb:"$(OUTDIR)/sprgen.pdb" /debug\
 /machine:I386 /out:"$(OUTDIR)/sprgen.exe" 
LINK32_OBJS= \
	"$(INTDIR)\cmdlib.obj" \
	"$(INTDIR)\lbmlib.obj" \
	"$(INTDIR)\scriplib.obj" \
	"$(INTDIR)\sprgen.obj"

"$(OUTDIR)\sprgen.exe" : "$(OUTDIR)" $(DEF_FILE) $(LINK32_OBJS)
    $(LINK32) @<<
  $(LINK32_FLAGS) $(LINK32_OBJS)
<<

!ELSEIF  "$(CFG)" == "sprgen - Win32 Debug"

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

ALL : "$(OUTDIR)\sprgen.exe" "$(OUTDIR)\sprgen.bsc"

CLEAN : 
	-@erase "$(INTDIR)\cmdlib.obj"
	-@erase "$(INTDIR)\cmdlib.sbr"
	-@erase "$(INTDIR)\lbmlib.obj"
	-@erase "$(INTDIR)\lbmlib.sbr"
	-@erase "$(INTDIR)\scriplib.obj"
	-@erase "$(INTDIR)\scriplib.sbr"
	-@erase "$(INTDIR)\sprgen.obj"
	-@erase "$(INTDIR)\sprgen.sbr"
	-@erase "$(INTDIR)\vc40.idb"
	-@erase "$(INTDIR)\vc40.pdb"
	-@erase "$(OUTDIR)\sprgen.bsc"
	-@erase "$(OUTDIR)\sprgen.exe"
	-@erase "$(OUTDIR)\sprgen.ilk"
	-@erase "$(OUTDIR)\sprgen.pdb"

"$(OUTDIR)" :
    if not exist "$(OUTDIR)/$(NULL)" mkdir "$(OUTDIR)"

# ADD BASE CPP /nologo /W3 /Gm /GX /Zi /Od /D "WIN32" /D "_DEBUG" /D "_CONSOLE" /YX /c
# ADD CPP /nologo /Gm /GX /Zi /Od /I "..\common" /D "WIN32" /D "_DEBUG" /D "_CONSOLE" /FR /YX /c
CPP_PROJ=/nologo /MLd /Gm /GX /Zi /Od /I "..\common" /D "WIN32" /D "_DEBUG" /D\
 "_CONSOLE" /FR"$(INTDIR)/" /Fp"$(INTDIR)/sprgen.pch" /YX /Fo"$(INTDIR)/"\
 /Fd"$(INTDIR)/" /c 
CPP_OBJS=.\Debug/
CPP_SBRS=.\Debug/
# ADD BASE RSC /l 0x409 /d "_DEBUG"
# ADD RSC /l 0x409 /d "_DEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
BSC32_FLAGS=/nologo /o"$(OUTDIR)/sprgen.bsc" 
BSC32_SBRS= \
	"$(INTDIR)\cmdlib.sbr" \
	"$(INTDIR)\lbmlib.sbr" \
	"$(INTDIR)\scriplib.sbr" \
	"$(INTDIR)\sprgen.sbr"

"$(OUTDIR)\sprgen.bsc" : "$(OUTDIR)" $(BSC32_SBRS)
    $(BSC32) @<<
  $(BSC32_FLAGS) $(BSC32_SBRS)
<<

LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:console /debug /machine:I386
# ADD LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib /nologo /subsystem:console /debug /machine:I386
LINK32_FLAGS=kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib\
 advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib /nologo\
 /subsystem:console /incremental:yes /pdb:"$(OUTDIR)/sprgen.pdb" /debug\
 /machine:I386 /out:"$(OUTDIR)/sprgen.exe" 
LINK32_OBJS= \
	"$(INTDIR)\cmdlib.obj" \
	"$(INTDIR)\lbmlib.obj" \
	"$(INTDIR)\scriplib.obj" \
	"$(INTDIR)\sprgen.obj"

"$(OUTDIR)\sprgen.exe" : "$(OUTDIR)" $(DEF_FILE) $(LINK32_OBJS)
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

# Name "sprgen - Win32 Release"
# Name "sprgen - Win32 Debug"

!IF  "$(CFG)" == "sprgen - Win32 Release"

!ELSEIF  "$(CFG)" == "sprgen - Win32 Debug"

!ENDIF 

################################################################################
# Begin Source File

SOURCE=.\sprgen.c
DEP_CPP_SPRGE=\
	"..\common\cmdlib.h"\
	"..\common\lbmlib.h"\
	"..\common\scriplib.h"\
	".\spritegn.h"\
	

!IF  "$(CFG)" == "sprgen - Win32 Release"


"$(INTDIR)\sprgen.obj" : $(SOURCE) $(DEP_CPP_SPRGE) "$(INTDIR)"


!ELSEIF  "$(CFG)" == "sprgen - Win32 Debug"


"$(INTDIR)\sprgen.obj" : $(SOURCE) $(DEP_CPP_SPRGE) "$(INTDIR)"

"$(INTDIR)\sprgen.sbr" : $(SOURCE) $(DEP_CPP_SPRGE) "$(INTDIR)"


!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=..\common\scriplib.c
DEP_CPP_SCRIP=\
	"..\common\cmdlib.h"\
	"..\common\scriplib.h"\
	

!IF  "$(CFG)" == "sprgen - Win32 Release"


"$(INTDIR)\scriplib.obj" : $(SOURCE) $(DEP_CPP_SCRIP) "$(INTDIR)"
   $(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "sprgen - Win32 Debug"


BuildCmds= \
	$(CPP) $(CPP_PROJ) $(SOURCE) \
	

"$(INTDIR)\scriplib.obj" : $(SOURCE) $(DEP_CPP_SCRIP) "$(INTDIR)"
   $(BuildCmds)

"$(INTDIR)\scriplib.sbr" : $(SOURCE) $(DEP_CPP_SCRIP) "$(INTDIR)"
   $(BuildCmds)

!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=..\common\lbmlib.c
DEP_CPP_LBMLI=\
	"..\common\cmdlib.h"\
	"..\common\lbmlib.h"\
	

!IF  "$(CFG)" == "sprgen - Win32 Release"


"$(INTDIR)\lbmlib.obj" : $(SOURCE) $(DEP_CPP_LBMLI) "$(INTDIR)"
   $(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "sprgen - Win32 Debug"


BuildCmds= \
	$(CPP) $(CPP_PROJ) $(SOURCE) \
	

"$(INTDIR)\lbmlib.obj" : $(SOURCE) $(DEP_CPP_LBMLI) "$(INTDIR)"
   $(BuildCmds)

"$(INTDIR)\lbmlib.sbr" : $(SOURCE) $(DEP_CPP_LBMLI) "$(INTDIR)"
   $(BuildCmds)

!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=..\common\cmdlib.c
DEP_CPP_CMDLI=\
	"..\common\cmdlib.h"\
	{$(INCLUDE)}"\sys\STAT.H"\
	{$(INCLUDE)}"\sys\TYPES.H"\
	

!IF  "$(CFG)" == "sprgen - Win32 Release"


"$(INTDIR)\cmdlib.obj" : $(SOURCE) $(DEP_CPP_CMDLI) "$(INTDIR)"
   $(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "sprgen - Win32 Debug"


BuildCmds= \
	$(CPP) $(CPP_PROJ) $(SOURCE) \
	

"$(INTDIR)\cmdlib.obj" : $(SOURCE) $(DEP_CPP_CMDLI) "$(INTDIR)"
   $(BuildCmds)

"$(INTDIR)\cmdlib.sbr" : $(SOURCE) $(DEP_CPP_CMDLI) "$(INTDIR)"
   $(BuildCmds)

!ENDIF 

# End Source File
# End Target
# End Project
################################################################################

# Microsoft Developer Studio Generated NMAKE File, Format Version 4.20
# ** DO NOT EDIT **

# TARGTYPE "Win32 (x86) Console Application" 0x0103

!IF "$(CFG)" == ""
CFG=vis - Win32 Debug
!MESSAGE No configuration specified.  Defaulting to vis - Win32 Debug.
!ENDIF 

!IF "$(CFG)" != "vis - Win32 Release" && "$(CFG)" != "vis - Win32 Debug"
!MESSAGE Invalid configuration "$(CFG)" specified.
!MESSAGE You can specify a configuration when running NMAKE on this makefile
!MESSAGE by defining the macro CFG on the command line.  For example:
!MESSAGE 
!MESSAGE NMAKE /f "vis.mak" CFG="vis - Win32 Debug"
!MESSAGE 
!MESSAGE Possible choices for configuration are:
!MESSAGE 
!MESSAGE "vis - Win32 Release" (based on "Win32 (x86) Console Application")
!MESSAGE "vis - Win32 Debug" (based on "Win32 (x86) Console Application")
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
# PROP Target_Last_Scanned "vis - Win32 Debug"
CPP=cl.exe
RSC=rc.exe

!IF  "$(CFG)" == "vis - Win32 Release"

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

ALL : "$(OUTDIR)\vis.exe"

CLEAN : 
	-@erase "$(INTDIR)\bspfile.obj"
	-@erase "$(INTDIR)\cmdlib.obj"
	-@erase "$(INTDIR)\flow.obj"
	-@erase "$(INTDIR)\mathlib.obj"
	-@erase "$(INTDIR)\scriplib.obj"
	-@erase "$(INTDIR)\soundpvs.obj"
	-@erase "$(INTDIR)\threads.obj"
	-@erase "$(INTDIR)\vis.obj"
	-@erase "$(OUTDIR)\vis.exe"

"$(OUTDIR)" :
    if not exist "$(OUTDIR)/$(NULL)" mkdir "$(OUTDIR)"

# ADD BASE CPP /nologo /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_CONSOLE" /YX /c
# ADD CPP /nologo /MT /GX /O2 /I "..\common" /D "WIN32" /D "NDEBUG" /D "_CONSOLE" /YX /c
# SUBTRACT CPP /Fr
CPP_PROJ=/nologo /MT /GX /O2 /I "..\common" /D "WIN32" /D "NDEBUG" /D\
 "_CONSOLE" /Fp"$(INTDIR)/vis.pch" /YX /Fo"$(INTDIR)/" /c 
CPP_OBJS=.\Release/
CPP_SBRS=.\.
# ADD BASE RSC /l 0x409 /d "NDEBUG"
# ADD RSC /l 0x409 /d "NDEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
BSC32_FLAGS=/nologo /o"$(OUTDIR)/vis.bsc" 
BSC32_SBRS= \
	
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:console /machine:I386
# ADD LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:console /machine:I386
LINK32_FLAGS=kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib\
 advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib\
 odbccp32.lib /nologo /subsystem:console /incremental:no\
 /pdb:"$(OUTDIR)/vis.pdb" /machine:I386 /out:"$(OUTDIR)/vis.exe" 
LINK32_OBJS= \
	"$(INTDIR)\bspfile.obj" \
	"$(INTDIR)\cmdlib.obj" \
	"$(INTDIR)\flow.obj" \
	"$(INTDIR)\mathlib.obj" \
	"$(INTDIR)\scriplib.obj" \
	"$(INTDIR)\soundpvs.obj" \
	"$(INTDIR)\threads.obj" \
	"$(INTDIR)\vis.obj"

"$(OUTDIR)\vis.exe" : "$(OUTDIR)" $(DEF_FILE) $(LINK32_OBJS)
    $(LINK32) @<<
  $(LINK32_FLAGS) $(LINK32_OBJS)
<<

!ELSEIF  "$(CFG)" == "vis - Win32 Debug"

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

ALL : "$(OUTDIR)\vis.exe" "$(OUTDIR)\vis.bsc"

CLEAN : 
	-@erase "$(INTDIR)\bspfile.obj"
	-@erase "$(INTDIR)\bspfile.sbr"
	-@erase "$(INTDIR)\cmdlib.obj"
	-@erase "$(INTDIR)\cmdlib.sbr"
	-@erase "$(INTDIR)\flow.obj"
	-@erase "$(INTDIR)\flow.sbr"
	-@erase "$(INTDIR)\mathlib.obj"
	-@erase "$(INTDIR)\mathlib.sbr"
	-@erase "$(INTDIR)\scriplib.obj"
	-@erase "$(INTDIR)\scriplib.sbr"
	-@erase "$(INTDIR)\soundpvs.obj"
	-@erase "$(INTDIR)\soundpvs.sbr"
	-@erase "$(INTDIR)\threads.obj"
	-@erase "$(INTDIR)\threads.sbr"
	-@erase "$(INTDIR)\vc40.idb"
	-@erase "$(INTDIR)\vc40.pdb"
	-@erase "$(INTDIR)\vis.obj"
	-@erase "$(INTDIR)\vis.sbr"
	-@erase "$(OUTDIR)\vis.bsc"
	-@erase "$(OUTDIR)\vis.exe"
	-@erase "$(OUTDIR)\vis.ilk"
	-@erase "$(OUTDIR)\vis.pdb"

"$(OUTDIR)" :
    if not exist "$(OUTDIR)/$(NULL)" mkdir "$(OUTDIR)"

# ADD BASE CPP /nologo /W3 /Gm /GX /Zi /Od /D "WIN32" /D "_DEBUG" /D "_CONSOLE" /YX /c
# ADD CPP /nologo /MT /Gm /GX /Zi /Od /I "..\common" /D "WIN32" /D "_DEBUG" /D "_CONSOLE" /Fr /YX /c
CPP_PROJ=/nologo /MT /Gm /GX /Zi /Od /I "..\common" /D "WIN32" /D "_DEBUG" /D\
 "_CONSOLE" /Fr"$(INTDIR)/" /Fp"$(INTDIR)/vis.pch" /YX /Fo"$(INTDIR)/"\
 /Fd"$(INTDIR)/" /c 
CPP_OBJS=.\Debug/
CPP_SBRS=.\Debug/
# ADD BASE RSC /l 0x409 /d "_DEBUG"
# ADD RSC /l 0x409 /d "_DEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
BSC32_FLAGS=/nologo /o"$(OUTDIR)/vis.bsc" 
BSC32_SBRS= \
	"$(INTDIR)\bspfile.sbr" \
	"$(INTDIR)\cmdlib.sbr" \
	"$(INTDIR)\flow.sbr" \
	"$(INTDIR)\mathlib.sbr" \
	"$(INTDIR)\scriplib.sbr" \
	"$(INTDIR)\soundpvs.sbr" \
	"$(INTDIR)\threads.sbr" \
	"$(INTDIR)\vis.sbr"

"$(OUTDIR)\vis.bsc" : "$(OUTDIR)" $(BSC32_SBRS)
    $(BSC32) @<<
  $(BSC32_FLAGS) $(BSC32_SBRS)
<<

LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:console /debug /machine:I386
# ADD LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:console /debug /machine:I386
LINK32_FLAGS=kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib\
 advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib\
 odbccp32.lib /nologo /subsystem:console /incremental:yes\
 /pdb:"$(OUTDIR)/vis.pdb" /debug /machine:I386 /out:"$(OUTDIR)/vis.exe" 
LINK32_OBJS= \
	"$(INTDIR)\bspfile.obj" \
	"$(INTDIR)\cmdlib.obj" \
	"$(INTDIR)\flow.obj" \
	"$(INTDIR)\mathlib.obj" \
	"$(INTDIR)\scriplib.obj" \
	"$(INTDIR)\soundpvs.obj" \
	"$(INTDIR)\threads.obj" \
	"$(INTDIR)\vis.obj"

"$(OUTDIR)\vis.exe" : "$(OUTDIR)" $(DEF_FILE) $(LINK32_OBJS)
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

# Name "vis - Win32 Release"
# Name "vis - Win32 Debug"

!IF  "$(CFG)" == "vis - Win32 Release"

!ELSEIF  "$(CFG)" == "vis - Win32 Debug"

!ENDIF 

################################################################################
# Begin Source File

SOURCE=.\vis.c
DEP_CPP_VIS_C=\
	"..\common\bspfile.h"\
	"..\common\cmdlib.h"\
	"..\common\mathlib.h"\
	"..\common\threads.h"\
	".\vis.h"\
	

!IF  "$(CFG)" == "vis - Win32 Release"


"$(INTDIR)\vis.obj" : $(SOURCE) $(DEP_CPP_VIS_C) "$(INTDIR)"


!ELSEIF  "$(CFG)" == "vis - Win32 Debug"


"$(INTDIR)\vis.obj" : $(SOURCE) $(DEP_CPP_VIS_C) "$(INTDIR)"

"$(INTDIR)\vis.sbr" : $(SOURCE) $(DEP_CPP_VIS_C) "$(INTDIR)"


!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=.\soundpvs.c
DEP_CPP_SOUND=\
	"..\common\bspfile.h"\
	"..\common\cmdlib.h"\
	"..\common\mathlib.h"\
	".\vis.h"\
	

!IF  "$(CFG)" == "vis - Win32 Release"


"$(INTDIR)\soundpvs.obj" : $(SOURCE) $(DEP_CPP_SOUND) "$(INTDIR)"


!ELSEIF  "$(CFG)" == "vis - Win32 Debug"


"$(INTDIR)\soundpvs.obj" : $(SOURCE) $(DEP_CPP_SOUND) "$(INTDIR)"

"$(INTDIR)\soundpvs.sbr" : $(SOURCE) $(DEP_CPP_SOUND) "$(INTDIR)"


!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=.\flow.c
DEP_CPP_FLOW_=\
	"..\common\bspfile.h"\
	"..\common\cmdlib.h"\
	"..\common\mathlib.h"\
	".\vis.h"\
	

!IF  "$(CFG)" == "vis - Win32 Release"


"$(INTDIR)\flow.obj" : $(SOURCE) $(DEP_CPP_FLOW_) "$(INTDIR)"


!ELSEIF  "$(CFG)" == "vis - Win32 Debug"


"$(INTDIR)\flow.obj" : $(SOURCE) $(DEP_CPP_FLOW_) "$(INTDIR)"

"$(INTDIR)\flow.sbr" : $(SOURCE) $(DEP_CPP_FLOW_) "$(INTDIR)"


!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=.\vis.h

!IF  "$(CFG)" == "vis - Win32 Release"

!ELSEIF  "$(CFG)" == "vis - Win32 Debug"

!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=..\common\threads.c
DEP_CPP_THREA=\
	"..\common\cmdlib.h"\
	"..\common\threads.h"\
	

!IF  "$(CFG)" == "vis - Win32 Release"


"$(INTDIR)\threads.obj" : $(SOURCE) $(DEP_CPP_THREA) "$(INTDIR)"
   $(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "vis - Win32 Debug"


BuildCmds= \
	$(CPP) $(CPP_PROJ) $(SOURCE) \
	

"$(INTDIR)\threads.obj" : $(SOURCE) $(DEP_CPP_THREA) "$(INTDIR)"
   $(BuildCmds)

"$(INTDIR)\threads.sbr" : $(SOURCE) $(DEP_CPP_THREA) "$(INTDIR)"
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
	

!IF  "$(CFG)" == "vis - Win32 Release"


"$(INTDIR)\cmdlib.obj" : $(SOURCE) $(DEP_CPP_CMDLI) "$(INTDIR)"
   $(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "vis - Win32 Debug"


BuildCmds= \
	$(CPP) $(CPP_PROJ) $(SOURCE) \
	

"$(INTDIR)\cmdlib.obj" : $(SOURCE) $(DEP_CPP_CMDLI) "$(INTDIR)"
   $(BuildCmds)

"$(INTDIR)\cmdlib.sbr" : $(SOURCE) $(DEP_CPP_CMDLI) "$(INTDIR)"
   $(BuildCmds)

!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=..\common\mathlib.c
DEP_CPP_MATHL=\
	"..\common\cmdlib.h"\
	"..\common\mathlib.h"\
	

!IF  "$(CFG)" == "vis - Win32 Release"


"$(INTDIR)\mathlib.obj" : $(SOURCE) $(DEP_CPP_MATHL) "$(INTDIR)"
   $(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "vis - Win32 Debug"


BuildCmds= \
	$(CPP) $(CPP_PROJ) $(SOURCE) \
	

"$(INTDIR)\mathlib.obj" : $(SOURCE) $(DEP_CPP_MATHL) "$(INTDIR)"
   $(BuildCmds)

"$(INTDIR)\mathlib.sbr" : $(SOURCE) $(DEP_CPP_MATHL) "$(INTDIR)"
   $(BuildCmds)

!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=..\common\scriplib.c
DEP_CPP_SCRIP=\
	"..\common\cmdlib.h"\
	"..\common\scriplib.h"\
	

!IF  "$(CFG)" == "vis - Win32 Release"


"$(INTDIR)\scriplib.obj" : $(SOURCE) $(DEP_CPP_SCRIP) "$(INTDIR)"
   $(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "vis - Win32 Debug"


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

SOURCE=..\common\bspfile.c
DEP_CPP_BSPFI=\
	"..\common\bspfile.h"\
	"..\common\cmdlib.h"\
	"..\common\mathlib.h"\
	"..\common\scriplib.h"\
	

!IF  "$(CFG)" == "vis - Win32 Release"


"$(INTDIR)\bspfile.obj" : $(SOURCE) $(DEP_CPP_BSPFI) "$(INTDIR)"
   $(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "vis - Win32 Debug"


BuildCmds= \
	$(CPP) $(CPP_PROJ) $(SOURCE) \
	

"$(INTDIR)\bspfile.obj" : $(SOURCE) $(DEP_CPP_BSPFI) "$(INTDIR)"
   $(BuildCmds)

"$(INTDIR)\bspfile.sbr" : $(SOURCE) $(DEP_CPP_BSPFI) "$(INTDIR)"
   $(BuildCmds)

!ENDIF 

# End Source File
# End Target
# End Project
################################################################################

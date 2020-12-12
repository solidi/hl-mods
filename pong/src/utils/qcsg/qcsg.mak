# Microsoft Developer Studio Generated NMAKE File, Format Version 4.20
# ** DO NOT EDIT **

# TARGTYPE "Win32 (x86) Console Application" 0x0103

!IF "$(CFG)" == ""
CFG=qcsg - Win32 Debug
!MESSAGE No configuration specified.  Defaulting to qcsg - Win32 Debug.
!ENDIF 

!IF "$(CFG)" != "qcsg - Win32 Release" && "$(CFG)" != "qcsg - Win32 Debug"
!MESSAGE Invalid configuration "$(CFG)" specified.
!MESSAGE You can specify a configuration when running NMAKE on this makefile
!MESSAGE by defining the macro CFG on the command line.  For example:
!MESSAGE 
!MESSAGE NMAKE /f "qcsg.mak" CFG="qcsg - Win32 Debug"
!MESSAGE 
!MESSAGE Possible choices for configuration are:
!MESSAGE 
!MESSAGE "qcsg - Win32 Release" (based on "Win32 (x86) Console Application")
!MESSAGE "qcsg - Win32 Debug" (based on "Win32 (x86) Console Application")
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
# PROP Target_Last_Scanned "qcsg - Win32 Debug"
CPP=cl.exe
RSC=rc.exe

!IF  "$(CFG)" == "qcsg - Win32 Release"

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

ALL : "$(OUTDIR)\qcsg.exe"

CLEAN : 
	-@erase "$(INTDIR)\brush.obj"
	-@erase "$(INTDIR)\bspfile.obj"
	-@erase "$(INTDIR)\cmdlib.obj"
	-@erase "$(INTDIR)\gldraw.obj"
	-@erase "$(INTDIR)\map.obj"
	-@erase "$(INTDIR)\mathlib.obj"
	-@erase "$(INTDIR)\polylib.obj"
	-@erase "$(INTDIR)\qcsg.obj"
	-@erase "$(INTDIR)\scriplib.obj"
	-@erase "$(INTDIR)\textures.obj"
	-@erase "$(INTDIR)\threads.obj"
	-@erase "$(OUTDIR)\qcsg.exe"

"$(OUTDIR)" :
    if not exist "$(OUTDIR)/$(NULL)" mkdir "$(OUTDIR)"

# ADD BASE CPP /nologo /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_CONSOLE" /YX /c
# ADD CPP /nologo /MT /GX /O2 /I "..\common" /D "NDEBUG" /D "WIN32" /D "_CONSOLE" /D "_MBCS" /D "DOUBLEVEC_T" /YX /c
CPP_PROJ=/nologo /MT /GX /O2 /I "..\common" /D "NDEBUG" /D "WIN32" /D\
 "_CONSOLE" /D "_MBCS" /D "DOUBLEVEC_T" /Fp"$(INTDIR)/qcsg.pch" /YX\
 /Fo"$(INTDIR)/" /c 
CPP_OBJS=.\Release/
CPP_SBRS=.\.
# ADD BASE RSC /l 0x409 /d "NDEBUG"
# ADD RSC /l 0x409 /d "NDEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
BSC32_FLAGS=/nologo /o"$(OUTDIR)/qcsg.bsc" 
BSC32_SBRS= \
	
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:console /machine:I386
# ADD LINK32 opengl32.lib glu32.lib glaux.lib kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib uuid.lib /nologo /subsystem:console /machine:I386
LINK32_FLAGS=opengl32.lib glu32.lib glaux.lib kernel32.lib user32.lib gdi32.lib\
 winspool.lib comdlg32.lib advapi32.lib shell32.lib uuid.lib /nologo\
 /subsystem:console /incremental:no /pdb:"$(OUTDIR)/qcsg.pdb" /machine:I386\
 /out:"$(OUTDIR)/qcsg.exe" 
LINK32_OBJS= \
	"$(INTDIR)\brush.obj" \
	"$(INTDIR)\bspfile.obj" \
	"$(INTDIR)\cmdlib.obj" \
	"$(INTDIR)\gldraw.obj" \
	"$(INTDIR)\map.obj" \
	"$(INTDIR)\mathlib.obj" \
	"$(INTDIR)\polylib.obj" \
	"$(INTDIR)\qcsg.obj" \
	"$(INTDIR)\scriplib.obj" \
	"$(INTDIR)\textures.obj" \
	"$(INTDIR)\threads.obj"

"$(OUTDIR)\qcsg.exe" : "$(OUTDIR)" $(DEF_FILE) $(LINK32_OBJS)
    $(LINK32) @<<
  $(LINK32_FLAGS) $(LINK32_OBJS)
<<

!ELSEIF  "$(CFG)" == "qcsg - Win32 Debug"

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

ALL : "$(OUTDIR)\qcsg.exe" "$(OUTDIR)\qcsg.bsc"

CLEAN : 
	-@erase "$(INTDIR)\brush.obj"
	-@erase "$(INTDIR)\brush.sbr"
	-@erase "$(INTDIR)\bspfile.obj"
	-@erase "$(INTDIR)\bspfile.sbr"
	-@erase "$(INTDIR)\cmdlib.obj"
	-@erase "$(INTDIR)\cmdlib.sbr"
	-@erase "$(INTDIR)\gldraw.obj"
	-@erase "$(INTDIR)\gldraw.sbr"
	-@erase "$(INTDIR)\map.obj"
	-@erase "$(INTDIR)\map.sbr"
	-@erase "$(INTDIR)\mathlib.obj"
	-@erase "$(INTDIR)\mathlib.sbr"
	-@erase "$(INTDIR)\polylib.obj"
	-@erase "$(INTDIR)\polylib.sbr"
	-@erase "$(INTDIR)\qcsg.obj"
	-@erase "$(INTDIR)\qcsg.sbr"
	-@erase "$(INTDIR)\scriplib.obj"
	-@erase "$(INTDIR)\scriplib.sbr"
	-@erase "$(INTDIR)\textures.obj"
	-@erase "$(INTDIR)\textures.sbr"
	-@erase "$(INTDIR)\threads.obj"
	-@erase "$(INTDIR)\threads.sbr"
	-@erase "$(INTDIR)\vc40.idb"
	-@erase "$(INTDIR)\vc40.pdb"
	-@erase "$(OUTDIR)\qcsg.bsc"
	-@erase "$(OUTDIR)\qcsg.exe"
	-@erase "$(OUTDIR)\qcsg.ilk"
	-@erase "$(OUTDIR)\qcsg.pdb"

"$(OUTDIR)" :
    if not exist "$(OUTDIR)/$(NULL)" mkdir "$(OUTDIR)"

# ADD BASE CPP /nologo /W3 /Gm /GX /Zi /Od /D "WIN32" /D "_DEBUG" /D "_CONSOLE" /YX /c
# ADD CPP /nologo /MTd /Gm /GX /Zi /Od /I "..\common" /D "_DEBUG" /D "WIN32" /D "_CONSOLE" /D "_MBCS" /D "DOUBLEVEC_T" /FR /YX /c
CPP_PROJ=/nologo /MTd /Gm /GX /Zi /Od /I "..\common" /D "_DEBUG" /D "WIN32" /D\
 "_CONSOLE" /D "_MBCS" /D "DOUBLEVEC_T" /FR"$(INTDIR)/" /Fp"$(INTDIR)/qcsg.pch"\
 /YX /Fo"$(INTDIR)/" /Fd"$(INTDIR)/" /c 
CPP_OBJS=.\Debug/
CPP_SBRS=.\Debug/
# ADD BASE RSC /l 0x409 /d "_DEBUG"
# ADD RSC /l 0x409 /d "_DEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
BSC32_FLAGS=/nologo /o"$(OUTDIR)/qcsg.bsc" 
BSC32_SBRS= \
	"$(INTDIR)\brush.sbr" \
	"$(INTDIR)\bspfile.sbr" \
	"$(INTDIR)\cmdlib.sbr" \
	"$(INTDIR)\gldraw.sbr" \
	"$(INTDIR)\map.sbr" \
	"$(INTDIR)\mathlib.sbr" \
	"$(INTDIR)\polylib.sbr" \
	"$(INTDIR)\qcsg.sbr" \
	"$(INTDIR)\scriplib.sbr" \
	"$(INTDIR)\textures.sbr" \
	"$(INTDIR)\threads.sbr"

"$(OUTDIR)\qcsg.bsc" : "$(OUTDIR)" $(BSC32_SBRS)
    $(BSC32) @<<
  $(BSC32_FLAGS) $(BSC32_SBRS)
<<

LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:console /debug /machine:I386
# ADD LINK32 opengl32.lib glu32.lib glaux.lib kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib uuid.lib /nologo /subsystem:console /debug /machine:I386
LINK32_FLAGS=opengl32.lib glu32.lib glaux.lib kernel32.lib user32.lib gdi32.lib\
 winspool.lib comdlg32.lib advapi32.lib shell32.lib uuid.lib /nologo\
 /subsystem:console /incremental:yes /pdb:"$(OUTDIR)/qcsg.pdb" /debug\
 /machine:I386 /out:"$(OUTDIR)/qcsg.exe" 
LINK32_OBJS= \
	"$(INTDIR)\brush.obj" \
	"$(INTDIR)\bspfile.obj" \
	"$(INTDIR)\cmdlib.obj" \
	"$(INTDIR)\gldraw.obj" \
	"$(INTDIR)\map.obj" \
	"$(INTDIR)\mathlib.obj" \
	"$(INTDIR)\polylib.obj" \
	"$(INTDIR)\qcsg.obj" \
	"$(INTDIR)\scriplib.obj" \
	"$(INTDIR)\textures.obj" \
	"$(INTDIR)\threads.obj"

"$(OUTDIR)\qcsg.exe" : "$(OUTDIR)" $(DEF_FILE) $(LINK32_OBJS)
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

# Name "qcsg - Win32 Release"
# Name "qcsg - Win32 Debug"

!IF  "$(CFG)" == "qcsg - Win32 Release"

!ELSEIF  "$(CFG)" == "qcsg - Win32 Debug"

!ENDIF 

################################################################################
# Begin Source File

SOURCE=.\map.c
DEP_CPP_MAP_C=\
	"..\common\bspfile.h"\
	"..\common\cmdlib.h"\
	"..\common\mathlib.h"\
	"..\common\polylib.h"\
	"..\common\scriplib.h"\
	"..\common\threads.h"\
	".\csg.h"\
	

!IF  "$(CFG)" == "qcsg - Win32 Release"


"$(INTDIR)\map.obj" : $(SOURCE) $(DEP_CPP_MAP_C) "$(INTDIR)"


!ELSEIF  "$(CFG)" == "qcsg - Win32 Debug"


"$(INTDIR)\map.obj" : $(SOURCE) $(DEP_CPP_MAP_C) "$(INTDIR)"

"$(INTDIR)\map.sbr" : $(SOURCE) $(DEP_CPP_MAP_C) "$(INTDIR)"


!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=.\brush.c
DEP_CPP_BRUSH=\
	"..\common\bspfile.h"\
	"..\common\cmdlib.h"\
	"..\common\mathlib.h"\
	"..\common\polylib.h"\
	"..\common\scriplib.h"\
	"..\common\threads.h"\
	".\csg.h"\
	

!IF  "$(CFG)" == "qcsg - Win32 Release"


"$(INTDIR)\brush.obj" : $(SOURCE) $(DEP_CPP_BRUSH) "$(INTDIR)"


!ELSEIF  "$(CFG)" == "qcsg - Win32 Debug"


"$(INTDIR)\brush.obj" : $(SOURCE) $(DEP_CPP_BRUSH) "$(INTDIR)"

"$(INTDIR)\brush.sbr" : $(SOURCE) $(DEP_CPP_BRUSH) "$(INTDIR)"


!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=.\qcsg.c
DEP_CPP_QCSG_=\
	"..\common\bspfile.h"\
	"..\common\cmdlib.h"\
	"..\common\mathlib.h"\
	"..\common\polylib.h"\
	"..\common\scriplib.h"\
	"..\common\threads.h"\
	".\csg.h"\
	

!IF  "$(CFG)" == "qcsg - Win32 Release"


"$(INTDIR)\qcsg.obj" : $(SOURCE) $(DEP_CPP_QCSG_) "$(INTDIR)"


!ELSEIF  "$(CFG)" == "qcsg - Win32 Debug"


"$(INTDIR)\qcsg.obj" : $(SOURCE) $(DEP_CPP_QCSG_) "$(INTDIR)"

"$(INTDIR)\qcsg.sbr" : $(SOURCE) $(DEP_CPP_QCSG_) "$(INTDIR)"


!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=.\textures.c
DEP_CPP_TEXTU=\
	"..\common\bspfile.h"\
	"..\common\cmdlib.h"\
	"..\common\mathlib.h"\
	"..\common\polylib.h"\
	"..\common\scriplib.h"\
	"..\common\threads.h"\
	".\csg.h"\
	

!IF  "$(CFG)" == "qcsg - Win32 Release"


"$(INTDIR)\textures.obj" : $(SOURCE) $(DEP_CPP_TEXTU) "$(INTDIR)"


!ELSEIF  "$(CFG)" == "qcsg - Win32 Debug"


"$(INTDIR)\textures.obj" : $(SOURCE) $(DEP_CPP_TEXTU) "$(INTDIR)"

"$(INTDIR)\textures.sbr" : $(SOURCE) $(DEP_CPP_TEXTU) "$(INTDIR)"


!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=.\gldraw.c
DEP_CPP_GLDRA=\
	"..\common\bspfile.h"\
	"..\common\cmdlib.h"\
	"..\common\mathlib.h"\
	"..\common\polylib.h"\
	"..\common\scriplib.h"\
	"..\common\threads.h"\
	".\csg.h"\
	{$(INCLUDE)}"\GL\gl.h"\
	{$(INCLUDE)}"\GL\glaux.h"\
	{$(INCLUDE)}"\GL\glu.h"\
	

!IF  "$(CFG)" == "qcsg - Win32 Release"


"$(INTDIR)\gldraw.obj" : $(SOURCE) $(DEP_CPP_GLDRA) "$(INTDIR)"


!ELSEIF  "$(CFG)" == "qcsg - Win32 Debug"


"$(INTDIR)\gldraw.obj" : $(SOURCE) $(DEP_CPP_GLDRA) "$(INTDIR)"

"$(INTDIR)\gldraw.sbr" : $(SOURCE) $(DEP_CPP_GLDRA) "$(INTDIR)"


!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=..\common\threads.c
DEP_CPP_THREA=\
	"..\common\cmdlib.h"\
	"..\common\threads.h"\
	

!IF  "$(CFG)" == "qcsg - Win32 Release"


"$(INTDIR)\threads.obj" : $(SOURCE) $(DEP_CPP_THREA) "$(INTDIR)"
   $(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "qcsg - Win32 Debug"


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
	{$(INCLUDE)}"\sys\Stat.h"\
	{$(INCLUDE)}"\sys\Types.h"\
	

!IF  "$(CFG)" == "qcsg - Win32 Release"


"$(INTDIR)\cmdlib.obj" : $(SOURCE) $(DEP_CPP_CMDLI) "$(INTDIR)"
   $(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "qcsg - Win32 Debug"


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
	

!IF  "$(CFG)" == "qcsg - Win32 Release"


"$(INTDIR)\mathlib.obj" : $(SOURCE) $(DEP_CPP_MATHL) "$(INTDIR)"
   $(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "qcsg - Win32 Debug"


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

SOURCE=..\common\polylib.c
DEP_CPP_POLYL=\
	"..\common\cmdlib.h"\
	"..\common\mathlib.h"\
	"..\common\polylib.h"\
	

!IF  "$(CFG)" == "qcsg - Win32 Release"


"$(INTDIR)\polylib.obj" : $(SOURCE) $(DEP_CPP_POLYL) "$(INTDIR)"
   $(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "qcsg - Win32 Debug"


BuildCmds= \
	$(CPP) $(CPP_PROJ) $(SOURCE) \
	

"$(INTDIR)\polylib.obj" : $(SOURCE) $(DEP_CPP_POLYL) "$(INTDIR)"
   $(BuildCmds)

"$(INTDIR)\polylib.sbr" : $(SOURCE) $(DEP_CPP_POLYL) "$(INTDIR)"
   $(BuildCmds)

!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=..\common\scriplib.c
DEP_CPP_SCRIP=\
	"..\common\cmdlib.h"\
	"..\common\scriplib.h"\
	

!IF  "$(CFG)" == "qcsg - Win32 Release"


"$(INTDIR)\scriplib.obj" : $(SOURCE) $(DEP_CPP_SCRIP) "$(INTDIR)"
   $(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "qcsg - Win32 Debug"


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
	

!IF  "$(CFG)" == "qcsg - Win32 Release"


"$(INTDIR)\bspfile.obj" : $(SOURCE) $(DEP_CPP_BSPFI) "$(INTDIR)"
   $(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "qcsg - Win32 Debug"


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

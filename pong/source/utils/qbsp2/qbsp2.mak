# Microsoft Developer Studio Generated NMAKE File, Format Version 4.20
# ** DO NOT EDIT **

# TARGTYPE "Win32 (x86) Console Application" 0x0103

!IF "$(CFG)" == ""
CFG=qbsp2 - Win32 Debug
!MESSAGE No configuration specified.  Defaulting to qbsp2 - Win32 Debug.
!ENDIF 

!IF "$(CFG)" != "qbsp2 - Win32 Release" && "$(CFG)" != "qbsp2 - Win32 Debug"
!MESSAGE Invalid configuration "$(CFG)" specified.
!MESSAGE You can specify a configuration when running NMAKE on this makefile
!MESSAGE by defining the macro CFG on the command line.  For example:
!MESSAGE 
!MESSAGE NMAKE /f "qbsp2.mak" CFG="qbsp2 - Win32 Debug"
!MESSAGE 
!MESSAGE Possible choices for configuration are:
!MESSAGE 
!MESSAGE "qbsp2 - Win32 Release" (based on "Win32 (x86) Console Application")
!MESSAGE "qbsp2 - Win32 Debug" (based on "Win32 (x86) Console Application")
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
# PROP Target_Last_Scanned "qbsp2 - Win32 Debug"
CPP=cl.exe
RSC=rc.exe

!IF  "$(CFG)" == "qbsp2 - Win32 Release"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 0
# PROP BASE Output_Dir "qbsp2___"
# PROP BASE Intermediate_Dir "qbsp2___"
# PROP BASE Target_Dir ""
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 0
# PROP Output_Dir "release"
# PROP Intermediate_Dir "release"
# PROP Target_Dir ""
OUTDIR=.\release
INTDIR=.\release

ALL : "$(OUTDIR)\qbsp2.exe"

CLEAN : 
	-@erase "$(INTDIR)\bspfile.obj"
	-@erase "$(INTDIR)\cmdlib.obj"
	-@erase "$(INTDIR)\gldraw.obj"
	-@erase "$(INTDIR)\mathlib.obj"
	-@erase "$(INTDIR)\merge.obj"
	-@erase "$(INTDIR)\outside.obj"
	-@erase "$(INTDIR)\portals.obj"
	-@erase "$(INTDIR)\qbsp.obj"
	-@erase "$(INTDIR)\scriplib.obj"
	-@erase "$(INTDIR)\solidbsp.obj"
	-@erase "$(INTDIR)\surfaces.obj"
	-@erase "$(INTDIR)\threads.obj"
	-@erase "$(INTDIR)\tjunc.obj"
	-@erase "$(INTDIR)\writebsp.obj"
	-@erase "$(OUTDIR)\qbsp2.exe"

"$(OUTDIR)" :
    if not exist "$(OUTDIR)/$(NULL)" mkdir "$(OUTDIR)"

# ADD BASE CPP /nologo /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_CONSOLE" /YX /c
# ADD CPP /nologo /MT /GX /O2 /I "..\common" /D "NDEBUG" /D "WIN32" /D "_CONSOLE" /D "DOUBLEVEC_T" /YX /c
CPP_PROJ=/nologo /MT /GX /O2 /I "..\common" /D "NDEBUG" /D "WIN32" /D\
 "_CONSOLE" /D "DOUBLEVEC_T" /Fp"$(INTDIR)/qbsp2.pch" /YX /Fo"$(INTDIR)/" /c 
CPP_OBJS=.\release/
CPP_SBRS=.\.
# ADD BASE RSC /l 0x409 /d "NDEBUG"
# ADD RSC /l 0x409 /d "NDEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
BSC32_FLAGS=/nologo /o"$(OUTDIR)/qbsp2.bsc" 
BSC32_SBRS= \
	
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:console /machine:I386
# ADD LINK32 opengl32.lib glu32.lib glaux.lib kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:console /machine:I386
LINK32_FLAGS=opengl32.lib glu32.lib glaux.lib kernel32.lib user32.lib gdi32.lib\
 winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib\
 uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:console /incremental:no\
 /pdb:"$(OUTDIR)/qbsp2.pdb" /machine:I386 /out:"$(OUTDIR)/qbsp2.exe" 
LINK32_OBJS= \
	"$(INTDIR)\bspfile.obj" \
	"$(INTDIR)\cmdlib.obj" \
	"$(INTDIR)\gldraw.obj" \
	"$(INTDIR)\mathlib.obj" \
	"$(INTDIR)\merge.obj" \
	"$(INTDIR)\outside.obj" \
	"$(INTDIR)\portals.obj" \
	"$(INTDIR)\qbsp.obj" \
	"$(INTDIR)\scriplib.obj" \
	"$(INTDIR)\solidbsp.obj" \
	"$(INTDIR)\surfaces.obj" \
	"$(INTDIR)\threads.obj" \
	"$(INTDIR)\tjunc.obj" \
	"$(INTDIR)\writebsp.obj"

"$(OUTDIR)\qbsp2.exe" : "$(OUTDIR)" $(DEF_FILE) $(LINK32_OBJS)
    $(LINK32) @<<
  $(LINK32_FLAGS) $(LINK32_OBJS)
<<

!ELSEIF  "$(CFG)" == "qbsp2 - Win32 Debug"

# PROP BASE Use_MFC 0
# PROP BASE Use_Debug_Libraries 1
# PROP BASE Output_Dir "qbsp2__0"
# PROP BASE Intermediate_Dir "qbsp2__0"
# PROP BASE Target_Dir ""
# PROP Use_MFC 0
# PROP Use_Debug_Libraries 1
# PROP Output_Dir "debug"
# PROP Intermediate_Dir "debug"
# PROP Target_Dir ""
OUTDIR=.\debug
INTDIR=.\debug

ALL : "$(OUTDIR)\qbsp2.exe"

CLEAN : 
	-@erase "$(INTDIR)\bspfile.obj"
	-@erase "$(INTDIR)\cmdlib.obj"
	-@erase "$(INTDIR)\gldraw.obj"
	-@erase "$(INTDIR)\mathlib.obj"
	-@erase "$(INTDIR)\merge.obj"
	-@erase "$(INTDIR)\outside.obj"
	-@erase "$(INTDIR)\portals.obj"
	-@erase "$(INTDIR)\qbsp.obj"
	-@erase "$(INTDIR)\scriplib.obj"
	-@erase "$(INTDIR)\solidbsp.obj"
	-@erase "$(INTDIR)\surfaces.obj"
	-@erase "$(INTDIR)\threads.obj"
	-@erase "$(INTDIR)\tjunc.obj"
	-@erase "$(INTDIR)\vc40.idb"
	-@erase "$(INTDIR)\vc40.pdb"
	-@erase "$(INTDIR)\writebsp.obj"
	-@erase "$(OUTDIR)\qbsp2.exe"
	-@erase "$(OUTDIR)\qbsp2.ilk"
	-@erase "$(OUTDIR)\qbsp2.pdb"

"$(OUTDIR)" :
    if not exist "$(OUTDIR)/$(NULL)" mkdir "$(OUTDIR)"

# ADD BASE CPP /nologo /W3 /Gm /GX /Zi /Od /D "WIN32" /D "_DEBUG" /D "_CONSOLE" /YX /c
# ADD CPP /nologo /MT /Gm /GX /Zi /Od /I "..\common" /D "_DEBUG" /D "WIN32" /D "_CONSOLE" /D "DOUBLEVEC_T" /YX /c
CPP_PROJ=/nologo /MT /Gm /GX /Zi /Od /I "..\common" /D "_DEBUG" /D "WIN32" /D\
 "_CONSOLE" /D "DOUBLEVEC_T" /Fp"$(INTDIR)/qbsp2.pch" /YX /Fo"$(INTDIR)/"\
 /Fd"$(INTDIR)/" /c 
CPP_OBJS=.\debug/
CPP_SBRS=.\.
# ADD BASE RSC /l 0x409 /d "_DEBUG"
# ADD RSC /l 0x409 /d "_DEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
BSC32_FLAGS=/nologo /o"$(OUTDIR)/qbsp2.bsc" 
BSC32_SBRS= \
	
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:console /debug /machine:I386
# ADD LINK32 opengl32.lib glu32.lib glaux.lib kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:console /debug /machine:I386
LINK32_FLAGS=opengl32.lib glu32.lib glaux.lib kernel32.lib user32.lib gdi32.lib\
 winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib\
 uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:console /incremental:yes\
 /pdb:"$(OUTDIR)/qbsp2.pdb" /debug /machine:I386 /out:"$(OUTDIR)/qbsp2.exe" 
LINK32_OBJS= \
	"$(INTDIR)\bspfile.obj" \
	"$(INTDIR)\cmdlib.obj" \
	"$(INTDIR)\gldraw.obj" \
	"$(INTDIR)\mathlib.obj" \
	"$(INTDIR)\merge.obj" \
	"$(INTDIR)\outside.obj" \
	"$(INTDIR)\portals.obj" \
	"$(INTDIR)\qbsp.obj" \
	"$(INTDIR)\scriplib.obj" \
	"$(INTDIR)\solidbsp.obj" \
	"$(INTDIR)\surfaces.obj" \
	"$(INTDIR)\threads.obj" \
	"$(INTDIR)\tjunc.obj" \
	"$(INTDIR)\writebsp.obj"

"$(OUTDIR)\qbsp2.exe" : "$(OUTDIR)" $(DEF_FILE) $(LINK32_OBJS)
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

# Name "qbsp2 - Win32 Release"
# Name "qbsp2 - Win32 Debug"

!IF  "$(CFG)" == "qbsp2 - Win32 Release"

!ELSEIF  "$(CFG)" == "qbsp2 - Win32 Debug"

!ENDIF 

################################################################################
# Begin Source File

SOURCE=.\merge.c
DEP_CPP_MERGE=\
	"..\common\bspfile.h"\
	"..\common\cmdlib.h"\
	"..\common\mathlib.h"\
	"..\common\threads.h"\
	".\bsp5.h"\
	

"$(INTDIR)\merge.obj" : $(SOURCE) $(DEP_CPP_MERGE) "$(INTDIR)"


# End Source File
################################################################################
# Begin Source File

SOURCE=.\gldraw.c
DEP_CPP_GLDRA=\
	"..\common\bspfile.h"\
	"..\common\cmdlib.h"\
	"..\common\mathlib.h"\
	"..\common\threads.h"\
	".\bsp5.h"\
	{$(INCLUDE)}"\GL\gl.h"\
	{$(INCLUDE)}"\GL\glaux.h"\
	{$(INCLUDE)}"\GL\glu.h"\
	

"$(INTDIR)\gldraw.obj" : $(SOURCE) $(DEP_CPP_GLDRA) "$(INTDIR)"


# End Source File
################################################################################
# Begin Source File

SOURCE=.\writebsp.c
DEP_CPP_WRITE=\
	"..\common\bspfile.h"\
	"..\common\cmdlib.h"\
	"..\common\mathlib.h"\
	"..\common\threads.h"\
	".\bsp5.h"\
	

"$(INTDIR)\writebsp.obj" : $(SOURCE) $(DEP_CPP_WRITE) "$(INTDIR)"


# End Source File
################################################################################
# Begin Source File

SOURCE=.\portals.c
DEP_CPP_PORTA=\
	"..\common\bspfile.h"\
	"..\common\cmdlib.h"\
	"..\common\mathlib.h"\
	"..\common\threads.h"\
	".\bsp5.h"\
	

"$(INTDIR)\portals.obj" : $(SOURCE) $(DEP_CPP_PORTA) "$(INTDIR)"


# End Source File
################################################################################
# Begin Source File

SOURCE=.\qbsp.c
DEP_CPP_QBSP_=\
	"..\common\bspfile.h"\
	"..\common\cmdlib.h"\
	"..\common\mathlib.h"\
	"..\common\threads.h"\
	".\bsp5.h"\
	

"$(INTDIR)\qbsp.obj" : $(SOURCE) $(DEP_CPP_QBSP_) "$(INTDIR)"


# End Source File
################################################################################
# Begin Source File

SOURCE=.\solidbsp.c
DEP_CPP_SOLID=\
	"..\common\bspfile.h"\
	"..\common\cmdlib.h"\
	"..\common\mathlib.h"\
	"..\common\threads.h"\
	".\bsp5.h"\
	

"$(INTDIR)\solidbsp.obj" : $(SOURCE) $(DEP_CPP_SOLID) "$(INTDIR)"


# End Source File
################################################################################
# Begin Source File

SOURCE=.\surfaces.c
DEP_CPP_SURFA=\
	"..\common\bspfile.h"\
	"..\common\cmdlib.h"\
	"..\common\mathlib.h"\
	"..\common\threads.h"\
	".\bsp5.h"\
	

"$(INTDIR)\surfaces.obj" : $(SOURCE) $(DEP_CPP_SURFA) "$(INTDIR)"


# End Source File
################################################################################
# Begin Source File

SOURCE=.\tjunc.c
DEP_CPP_TJUNC=\
	"..\common\bspfile.h"\
	"..\common\cmdlib.h"\
	"..\common\mathlib.h"\
	"..\common\threads.h"\
	".\bsp5.h"\
	

"$(INTDIR)\tjunc.obj" : $(SOURCE) $(DEP_CPP_TJUNC) "$(INTDIR)"


# End Source File
################################################################################
# Begin Source File

SOURCE=.\outside.c
DEP_CPP_OUTSI=\
	"..\common\bspfile.h"\
	"..\common\cmdlib.h"\
	"..\common\mathlib.h"\
	"..\common\threads.h"\
	".\bsp5.h"\
	

"$(INTDIR)\outside.obj" : $(SOURCE) $(DEP_CPP_OUTSI) "$(INTDIR)"


# End Source File
################################################################################
# Begin Source File

SOURCE=.\bsp5.h

!IF  "$(CFG)" == "qbsp2 - Win32 Release"

!ELSEIF  "$(CFG)" == "qbsp2 - Win32 Debug"

!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=..\common\threads.c
DEP_CPP_THREA=\
	"..\common\cmdlib.h"\
	"..\common\threads.h"\
	

"$(INTDIR)\threads.obj" : $(SOURCE) $(DEP_CPP_THREA) "$(INTDIR)"
   $(CPP) $(CPP_PROJ) $(SOURCE)


# End Source File
################################################################################
# Begin Source File

SOURCE=..\common\bspfile.c
DEP_CPP_BSPFI=\
	"..\common\bspfile.h"\
	"..\common\cmdlib.h"\
	"..\common\mathlib.h"\
	"..\common\scriplib.h"\
	

"$(INTDIR)\bspfile.obj" : $(SOURCE) $(DEP_CPP_BSPFI) "$(INTDIR)"
   $(CPP) $(CPP_PROJ) $(SOURCE)


# End Source File
################################################################################
# Begin Source File

SOURCE=..\common\scriplib.c
DEP_CPP_SCRIP=\
	"..\common\cmdlib.h"\
	"..\common\scriplib.h"\
	

"$(INTDIR)\scriplib.obj" : $(SOURCE) $(DEP_CPP_SCRIP) "$(INTDIR)"
   $(CPP) $(CPP_PROJ) $(SOURCE)


# End Source File
################################################################################
# Begin Source File

SOURCE=..\common\mathlib.c
DEP_CPP_MATHL=\
	"..\common\cmdlib.h"\
	"..\common\mathlib.h"\
	

"$(INTDIR)\mathlib.obj" : $(SOURCE) $(DEP_CPP_MATHL) "$(INTDIR)"
   $(CPP) $(CPP_PROJ) $(SOURCE)


# End Source File
################################################################################
# Begin Source File

SOURCE=..\common\cmdlib.c
DEP_CPP_CMDLI=\
	"..\common\cmdlib.h"\
	{$(INCLUDE)}"\sys\stat.h"\
	{$(INCLUDE)}"\sys\types.h"\
	

"$(INTDIR)\cmdlib.obj" : $(SOURCE) $(DEP_CPP_CMDLI) "$(INTDIR)"
   $(CPP) $(CPP_PROJ) $(SOURCE)


# End Source File
# End Target
# End Project
################################################################################

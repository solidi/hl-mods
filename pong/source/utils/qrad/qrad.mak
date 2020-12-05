# Microsoft Developer Studio Generated NMAKE File, Format Version 4.20
# ** DO NOT EDIT **

# TARGTYPE "Win32 (x86) Console Application" 0x0103

!IF "$(CFG)" == ""
CFG=qrad - Win32 Debug
!MESSAGE No configuration specified.  Defaulting to qrad - Win32 Debug.
!ENDIF 

!IF "$(CFG)" != "qrad - Win32 Release" && "$(CFG)" != "qrad - Win32 Debug"
!MESSAGE Invalid configuration "$(CFG)" specified.
!MESSAGE You can specify a configuration when running NMAKE on this makefile
!MESSAGE by defining the macro CFG on the command line.  For example:
!MESSAGE 
!MESSAGE NMAKE /f "qrad.mak" CFG="qrad - Win32 Debug"
!MESSAGE 
!MESSAGE Possible choices for configuration are:
!MESSAGE 
!MESSAGE "qrad - Win32 Release" (based on "Win32 (x86) Console Application")
!MESSAGE "qrad - Win32 Debug" (based on "Win32 (x86) Console Application")
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
# PROP Target_Last_Scanned "qrad - Win32 Debug"
CPP=cl.exe
RSC=rc.exe

!IF  "$(CFG)" == "qrad - Win32 Release"

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

ALL : "$(OUTDIR)\qrad.exe"

CLEAN : 
	-@erase "$(INTDIR)\bspfile.obj"
	-@erase "$(INTDIR)\cmdlib.obj"
	-@erase "$(INTDIR)\lightmap.obj"
	-@erase "$(INTDIR)\mathlib.obj"
	-@erase "$(INTDIR)\polylib.obj"
	-@erase "$(INTDIR)\qrad.obj"
	-@erase "$(INTDIR)\scriplib.obj"
	-@erase "$(INTDIR)\threads.obj"
	-@erase "$(INTDIR)\trace.obj"
	-@erase "$(INTDIR)\vc40.pdb"
	-@erase "$(INTDIR)\vismat.obj"
	-@erase "$(OUTDIR)\qrad.exe"
	-@erase "$(OUTDIR)\qrad.map"

"$(OUTDIR)" :
    if not exist "$(OUTDIR)/$(NULL)" mkdir "$(OUTDIR)"

# ADD BASE CPP /nologo /W3 /GX /O2 /D "WIN32" /D "NDEBUG" /D "_CONSOLE" /YX /c
# ADD CPP /nologo /MT /GX /Zi /O2 /I "..\common" /D "WIN32" /D "NDEBUG" /D "_CONSOLE" /YX /c
CPP_PROJ=/nologo /MT /GX /Zi /O2 /I "..\common" /D "WIN32" /D "NDEBUG" /D\
 "_CONSOLE" /Fp"$(INTDIR)/qrad.pch" /YX /Fo"$(INTDIR)/" /Fd"$(INTDIR)/" /c 
CPP_OBJS=.\Release/
CPP_SBRS=.\.
# ADD BASE RSC /l 0x409 /d "NDEBUG"
# ADD RSC /l 0x409 /d "NDEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
BSC32_FLAGS=/nologo /o"$(OUTDIR)/qrad.bsc" 
BSC32_SBRS= \
	
LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:console /machine:I386
# ADD LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:console /profile /map /machine:I386
LINK32_FLAGS=kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib\
 advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib\
 odbccp32.lib /nologo /subsystem:console /profile /map:"$(INTDIR)/qrad.map"\
 /machine:I386 /out:"$(OUTDIR)/qrad.exe" 
LINK32_OBJS= \
	"$(INTDIR)\bspfile.obj" \
	"$(INTDIR)\cmdlib.obj" \
	"$(INTDIR)\lightmap.obj" \
	"$(INTDIR)\mathlib.obj" \
	"$(INTDIR)\polylib.obj" \
	"$(INTDIR)\qrad.obj" \
	"$(INTDIR)\scriplib.obj" \
	"$(INTDIR)\threads.obj" \
	"$(INTDIR)\trace.obj" \
	"$(INTDIR)\vismat.obj"

"$(OUTDIR)\qrad.exe" : "$(OUTDIR)" $(DEF_FILE) $(LINK32_OBJS)
    $(LINK32) @<<
  $(LINK32_FLAGS) $(LINK32_OBJS)
<<

!ELSEIF  "$(CFG)" == "qrad - Win32 Debug"

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

ALL : "$(OUTDIR)\qrad.exe" "$(OUTDIR)\qrad.bsc"

CLEAN : 
	-@erase "$(INTDIR)\bspfile.obj"
	-@erase "$(INTDIR)\bspfile.sbr"
	-@erase "$(INTDIR)\cmdlib.obj"
	-@erase "$(INTDIR)\cmdlib.sbr"
	-@erase "$(INTDIR)\lightmap.obj"
	-@erase "$(INTDIR)\lightmap.sbr"
	-@erase "$(INTDIR)\mathlib.obj"
	-@erase "$(INTDIR)\mathlib.sbr"
	-@erase "$(INTDIR)\polylib.obj"
	-@erase "$(INTDIR)\polylib.sbr"
	-@erase "$(INTDIR)\qrad.obj"
	-@erase "$(INTDIR)\qrad.sbr"
	-@erase "$(INTDIR)\scriplib.obj"
	-@erase "$(INTDIR)\scriplib.sbr"
	-@erase "$(INTDIR)\threads.obj"
	-@erase "$(INTDIR)\threads.sbr"
	-@erase "$(INTDIR)\trace.obj"
	-@erase "$(INTDIR)\trace.sbr"
	-@erase "$(INTDIR)\vc40.idb"
	-@erase "$(INTDIR)\vc40.pdb"
	-@erase "$(INTDIR)\vismat.obj"
	-@erase "$(INTDIR)\vismat.sbr"
	-@erase "$(OUTDIR)\qrad.bsc"
	-@erase "$(OUTDIR)\qrad.exe"
	-@erase "$(OUTDIR)\qrad.map"

"$(OUTDIR)" :
    if not exist "$(OUTDIR)/$(NULL)" mkdir "$(OUTDIR)"

# ADD BASE CPP /nologo /W3 /Gm /GX /Zi /Od /D "WIN32" /D "_DEBUG" /D "_CONSOLE" /YX /c
# ADD CPP /nologo /MT /Gm /GX /Zi /Od /I "..\common" /D "WIN32" /D "_DEBUG" /D "_CONSOLE" /FR /YX /c
CPP_PROJ=/nologo /MT /Gm /GX /Zi /Od /I "..\common" /D "WIN32" /D "_DEBUG" /D\
 "_CONSOLE" /FR"$(INTDIR)/" /Fp"$(INTDIR)/qrad.pch" /YX /Fo"$(INTDIR)/"\
 /Fd"$(INTDIR)/" /c 
CPP_OBJS=.\Debug/
CPP_SBRS=.\Debug/
# ADD BASE RSC /l 0x409 /d "_DEBUG"
# ADD RSC /l 0x409 /d "_DEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
BSC32_FLAGS=/nologo /o"$(OUTDIR)/qrad.bsc" 
BSC32_SBRS= \
	"$(INTDIR)\bspfile.sbr" \
	"$(INTDIR)\cmdlib.sbr" \
	"$(INTDIR)\lightmap.sbr" \
	"$(INTDIR)\mathlib.sbr" \
	"$(INTDIR)\polylib.sbr" \
	"$(INTDIR)\qrad.sbr" \
	"$(INTDIR)\scriplib.sbr" \
	"$(INTDIR)\threads.sbr" \
	"$(INTDIR)\trace.sbr" \
	"$(INTDIR)\vismat.sbr"

"$(OUTDIR)\qrad.bsc" : "$(OUTDIR)" $(BSC32_SBRS)
    $(BSC32) @<<
  $(BSC32_FLAGS) $(BSC32_SBRS)
<<

LINK32=link.exe
# ADD BASE LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:console /debug /machine:I386
# ADD LINK32 kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib odbccp32.lib /nologo /subsystem:console /profile /map /debug /machine:I386
LINK32_FLAGS=kernel32.lib user32.lib gdi32.lib winspool.lib comdlg32.lib\
 advapi32.lib shell32.lib ole32.lib oleaut32.lib uuid.lib odbc32.lib\
 odbccp32.lib /nologo /subsystem:console /profile /map:"$(INTDIR)/qrad.map"\
 /debug /machine:I386 /out:"$(OUTDIR)/qrad.exe" 
LINK32_OBJS= \
	"$(INTDIR)\bspfile.obj" \
	"$(INTDIR)\cmdlib.obj" \
	"$(INTDIR)\lightmap.obj" \
	"$(INTDIR)\mathlib.obj" \
	"$(INTDIR)\polylib.obj" \
	"$(INTDIR)\qrad.obj" \
	"$(INTDIR)\scriplib.obj" \
	"$(INTDIR)\threads.obj" \
	"$(INTDIR)\trace.obj" \
	"$(INTDIR)\vismat.obj"

"$(OUTDIR)\qrad.exe" : "$(OUTDIR)" $(DEF_FILE) $(LINK32_OBJS)
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

# Name "qrad - Win32 Release"
# Name "qrad - Win32 Debug"

!IF  "$(CFG)" == "qrad - Win32 Release"

!ELSEIF  "$(CFG)" == "qrad - Win32 Debug"

!ENDIF 

################################################################################
# Begin Source File

SOURCE=.\trace.c
DEP_CPP_TRACE=\
	"..\common\bspfile.h"\
	"..\common\cmdlib.h"\
	"..\common\mathlib.h"\
	"..\common\polylib.h"\
	

!IF  "$(CFG)" == "qrad - Win32 Release"


"$(INTDIR)\trace.obj" : $(SOURCE) $(DEP_CPP_TRACE) "$(INTDIR)"


!ELSEIF  "$(CFG)" == "qrad - Win32 Debug"


"$(INTDIR)\trace.obj" : $(SOURCE) $(DEP_CPP_TRACE) "$(INTDIR)"

"$(INTDIR)\trace.sbr" : $(SOURCE) $(DEP_CPP_TRACE) "$(INTDIR)"


!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=.\qrad.c
DEP_CPP_QRAD_=\
	"..\common\bspfile.h"\
	"..\common\cmdlib.h"\
	"..\common\mathlib.h"\
	"..\common\polylib.h"\
	"..\common\threads.h"\
	".\qrad.h"\
	{$(INCLUDE)}"\sys\STAT.H"\
	{$(INCLUDE)}"\sys\TYPES.H"\
	

!IF  "$(CFG)" == "qrad - Win32 Release"


"$(INTDIR)\qrad.obj" : $(SOURCE) $(DEP_CPP_QRAD_) "$(INTDIR)"


!ELSEIF  "$(CFG)" == "qrad - Win32 Debug"


"$(INTDIR)\qrad.obj" : $(SOURCE) $(DEP_CPP_QRAD_) "$(INTDIR)"

"$(INTDIR)\qrad.sbr" : $(SOURCE) $(DEP_CPP_QRAD_) "$(INTDIR)"


!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=.\vismat.c

!IF  "$(CFG)" == "qrad - Win32 Release"

DEP_CPP_VISMA=\
	"..\common\bspfile.h"\
	"..\common\cmdlib.h"\
	"..\common\mathlib.h"\
	"..\common\polylib.h"\
	"..\common\threads.h"\
	".\qrad.h"\
	{$(INCLUDE)}"\sys\STAT.H"\
	{$(INCLUDE)}"\sys\TYPES.H"\
	

"$(INTDIR)\vismat.obj" : $(SOURCE) $(DEP_CPP_VISMA) "$(INTDIR)"


!ELSEIF  "$(CFG)" == "qrad - Win32 Debug"

DEP_CPP_VISMA=\
	"..\common\bspfile.h"\
	"..\common\cmdlib.h"\
	"..\common\mathlib.h"\
	"..\common\polylib.h"\
	"..\common\threads.h"\
	".\qrad.h"\
	{$(INCLUDE)}"\sys\STAT.H"\
	{$(INCLUDE)}"\sys\TYPES.H"\
	

"$(INTDIR)\vismat.obj" : $(SOURCE) $(DEP_CPP_VISMA) "$(INTDIR)"

"$(INTDIR)\vismat.sbr" : $(SOURCE) $(DEP_CPP_VISMA) "$(INTDIR)"


!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=.\lightmap.c
DEP_CPP_LIGHT=\
	"..\..\engine\anorms.h"\
	"..\common\bspfile.h"\
	"..\common\cmdlib.h"\
	"..\common\mathlib.h"\
	"..\common\polylib.h"\
	"..\common\threads.h"\
	".\qrad.h"\
	{$(INCLUDE)}"\sys\STAT.H"\
	{$(INCLUDE)}"\sys\TYPES.H"\
	

!IF  "$(CFG)" == "qrad - Win32 Release"


"$(INTDIR)\lightmap.obj" : $(SOURCE) $(DEP_CPP_LIGHT) "$(INTDIR)"


!ELSEIF  "$(CFG)" == "qrad - Win32 Debug"


"$(INTDIR)\lightmap.obj" : $(SOURCE) $(DEP_CPP_LIGHT) "$(INTDIR)"

"$(INTDIR)\lightmap.sbr" : $(SOURCE) $(DEP_CPP_LIGHT) "$(INTDIR)"


!ENDIF 

# End Source File
################################################################################
# Begin Source File

SOURCE=..\common\threads.c
DEP_CPP_THREA=\
	"..\common\cmdlib.h"\
	"..\common\threads.h"\
	

!IF  "$(CFG)" == "qrad - Win32 Release"


"$(INTDIR)\threads.obj" : $(SOURCE) $(DEP_CPP_THREA) "$(INTDIR)"
   $(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "qrad - Win32 Debug"


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
	

!IF  "$(CFG)" == "qrad - Win32 Release"


"$(INTDIR)\cmdlib.obj" : $(SOURCE) $(DEP_CPP_CMDLI) "$(INTDIR)"
   $(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "qrad - Win32 Debug"


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
	

!IF  "$(CFG)" == "qrad - Win32 Release"


"$(INTDIR)\mathlib.obj" : $(SOURCE) $(DEP_CPP_MATHL) "$(INTDIR)"
   $(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "qrad - Win32 Debug"


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
	

!IF  "$(CFG)" == "qrad - Win32 Release"


"$(INTDIR)\polylib.obj" : $(SOURCE) $(DEP_CPP_POLYL) "$(INTDIR)"
   $(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "qrad - Win32 Debug"


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
	".\..\common\scriplib.h"\
	

!IF  "$(CFG)" == "qrad - Win32 Release"


"$(INTDIR)\scriplib.obj" : $(SOURCE) $(DEP_CPP_SCRIP) "$(INTDIR)"
   $(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "qrad - Win32 Debug"


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
	".\..\common\scriplib.h"\
	

!IF  "$(CFG)" == "qrad - Win32 Release"


"$(INTDIR)\bspfile.obj" : $(SOURCE) $(DEP_CPP_BSPFI) "$(INTDIR)"
   $(CPP) $(CPP_PROJ) $(SOURCE)


!ELSEIF  "$(CFG)" == "qrad - Win32 Debug"


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

@ECHO OFF
SET msdev="C:\Program Files\Microsoft Visual Studio\Common\MSDev98\Bin\msdev"
SET hldir=C:\Sierra\Half-Life
SET icedir=%hldir%\iceg
SET hlexe=%hldir%\hl.exe

REM https://docs.microsoft.com/en-us/previous-versions/visualstudio/visual-studio-6.0/aa699274(v=vs.60)
%msdev% z:\src\dlls\hl.dsp /make "hl - Win32 Release"
%msdev% z:\src\cl_dll\cl_dll.dsp /make "cl_dll - Win32 Release"

IF %ERRORLEVEL% NEQ 0 (
  ECHO Could not compile dll.
  PAUSE
  EXIT
)

ECHO Y|RMDIR %icedir% /Q /S
MKDIR %icedir%
ECHO Y|XCOPY Z:\redist "%icedir%" /E

IF NOT EXIST %icedir%\dlls\hl.dll (
  ECHO Could not find hl.dll.
  PAUSE
  EXIT
)

IF NOT EXIST %icedir%\cl_dlls\client.dll (
  ECHO Could not find client.dll.
  PAUSE
  EXIT
)

REM Making PAK file
COPY Z:\bin\qpakman.exe %icedir%
CD %icedir%
%icedir%\qpakman models -o pak0.pak | FIND "FAILURE" >nul2>nul

if %ERRORLEVEL% EQU 0 (
  ECHO Could not recreate pak file.
  PAUSE
  EXIT
)

ECHO Y|RMDIR %icedir%\models /Q /S
DEL %icedir%\qpakman.exe

REM https://developer.valvesoftware.com/wiki/Command_Line_Options
%hlexe% -dev -windowed -console -game iceg -condebug +log on +sv_lan 1 +map stalkyard

IF %ERRORLEVEL% NEQ 0 (
  ECHO Something went wrong with Half-Life.
)

REM Get out of %icedir% so that the folder can be removed later
CD %hldir%
CMD
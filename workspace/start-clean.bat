SET msdev="C:\Program Files\Microsoft Visual Studio\Common\MSDev98\Bin\msdev"
SET icedir=C:\Sierra\Half-Life\iceg
SET hlexe=C:\Sierra\Half-Life\hl.exe

REM https://docs.microsoft.com/en-us/previous-versions/visualstudio/visual-studio-6.0/aa699274(v=vs.60)
%msdev% z:\src\dlls\hl.dsp /make "hl - Win32 Debug"

ECHO Y|RMDIR %icedir% /Q /S
MKDIR %icedir%
ECHO Y|XCOPY Z:\redist "%icedir%" /E

REM Making PAK file
COPY Z:\bin\qpakman.exe %icedir%
CD %icedir%
%icedir%\qpakman models -o pak0.pak
ECHO Y|RMDIR %icedir%\models /Q /S
DEL %icedir%\qpakman.exe

REM https://developer.valvesoftware.com/wiki/Command_Line_Options
%hlexe% -dev -console -game iceg +sv_lan 1 +map stalkyard

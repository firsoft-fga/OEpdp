@echo off 
rem run 1 slave with number in first param %1
call setenv

set DISPBANNER=no
set ipcnum=%1

if "%DLC%"==""    set DLC=C:\Progress\OpenEdge
if exist "%DLC%"\promsgs goto BIN
   echo DLC environment variable not set correctly - Please set DLC variable
   goto END

:BIN
if not "%PROEXE%"=="" goto START
   set PROEXE=%DLC%\bin\_progres

if "%ICU_DATA%"==""    set ICU_DATA="%DLC%\bin\icu\data\\" 
:START
if "%DISPBANNER%"=="no" goto NOBANNER
   type "%DLC%"\hello

:NOBANNER
 echo %ipcnum% 
 
jvmstart c:\progress\openedge\bin\_progres.exe -db demo -H localhost -S 5555  -b -p oeipcslave | tee -a oeipc.log >nul

exit /B 0
:END



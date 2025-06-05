@echo off
call setenv.bat 
set DISPBANNER=no


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
 echo %maxslave%
  
rem  start /B 
jvmstart _progres.exe -db demo -H localhost -S 5555  -b -p oeipcmaster | tee -a oeipc.log >nul

exit /B 0
:END



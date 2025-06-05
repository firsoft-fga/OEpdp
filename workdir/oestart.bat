@echo off
call setenv.bat  
rem  echo %maxslave% 
start /B oeipc.bat
timeout /t 5 /nobreak
for /L %%i in (1,1,%maxslave%) do (
echo %%i
start /B oeipc1.bat %%i 
timeout /t 1 /nobreak
)

exit /B

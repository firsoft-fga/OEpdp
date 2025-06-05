@echo off
call setenv.bat  
shm_writes %ipcname% 0 16 stat
exit /B

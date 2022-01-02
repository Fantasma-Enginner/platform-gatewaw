@echo off

setlocal
%~d0
cd %~dp0

:install
if not "%VPS_HOME%" == "" goto checkVPSHome
set VPS_HOME=C:\Software\VPS

:checkVPSHome
if exist "%VPS_HOME%" goto okVPS
mkdir %VPS_HOME%
:okVPS
set "APP_NAME=platform-gateway"
set "APP_HOME=%VPS_HOME%\%APP_NAME%"
set "SERVICE_NAME=VPS-%APP_NAME%"

:installService
sc query state=all | find "%SERVICE_NAME%"
if %ERRORLEVEL% equ 1 goto copyBin
sc query | find "%SERVICE_NAME%"
if %ERRORLEVEL% equ 1 goto copyBin 
net stop %SERVICE_NAME%
if %ERRORLEVEL% equ 0 goto copyBin 
echo ERROR: No ha sido posible detener el servicio %SERVICE_NAME%. No es posible continuar con la instalación.
goto end

if exist %APP_HOME% goto copyBin
mkdir %APP_HOME%
:copyBin
xcopy /e /y /q bin %APP_HOME%\bin\
echo Recursos ejecutables copiados 

sc query state=all | find "%SERVICE_NAME%"
if %ERRORLEVEL% equ 1 %APP_HOME%/bin/%APP_NAME%.exe install
if %ERRORLEVEL% equ 0 goto starService
echo ADVERTENCIA: No ha sido posible instalar el servicio.
:starService
net start %SERVICE_NAME%
if %ERRORLEVEL% equ 2 echo ADVERTENCIA: No ha sido posible iniciar el servicio. Un usuario con privilegios administrativos debe iniciar el servicio manualmente.  

:end
echo Finalizado
pause
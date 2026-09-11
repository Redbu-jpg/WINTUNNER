```bat
@echo off
setlocal EnableExtensions EnableDelayedExpansion
title WinTuner
color 0A

:: ============================================================
:: WinTuner - Windows Tweaker
:: Version 1.2 - Modo DEMO
:: ============================================================

set "BASE=%~dp0"
set "BACKUP=%BASE%backup"
set "LOGS=%BASE%logs"

if not exist "%BACKUP%" mkdir "%BACKUP%"
if not exist "%LOGS%" mkdir "%LOGS%"

:: ============================================================
:: MENU PRINCIPAL
:: ============================================================

:MENU
cls
echo.
echo  ==========================================================
echo.
echo                      W I N T U N E R
echo.
echo                  Windows Tweaking Utility
echo.
echo  ==========================================================
echo.
echo       [1]  Rendimiento
echo       [2]  Limpieza
echo       [3]  Red
echo       [4]  Privacidad
echo       [5]  Herramientas de Windows
echo       [6]  Informacion del sistema
echo.
echo       [0]  Salir
echo.
echo  ==========================================================
echo.

set "opcion="
set /p "opcion=  Selecciona una opcion: "

if "%opcion%"=="1" goto RENDIMIENTO
if "%opcion%"=="2" goto LIMPIEZA
if "%opcion%"=="3" goto RED
if "%opcion%"=="4" goto PRIVACIDAD
if "%opcion%"=="5" goto WINDOWS
if "%opcion%"=="6" goto INFO
if "%opcion%"=="0" goto SALIR

echo.
echo  [!] Opcion no valida.
timeout /t 2 >nul
goto MENU


:: ============================================================
:: RENDIMIENTO
:: ============================================================

:RENDIMIENTO
cls
echo.
echo  ==========================================================
echo                       RENDIMIENTO
echo  ==========================================================
echo.
echo    [1] Activar plan Alto rendimiento
echo    [2] Activar Game Mode
echo    [3] Reducir efectos visuales
echo    [4] Ver programas de inicio
echo    [5] Aplicar optimizacion recomendada
echo    [6] Restaurar plan de energia anterior
echo    [7] Modo DEMO (NO cambia nada)
echo    [8] Volver
echo.
echo  ==========================================================
echo.

set "rend="
set /p "rend=  Selecciona una opcion: "

if "%rend%"=="1" goto ALTO_RENDIMIENTO
if "%rend%"=="2" goto GAME_MODE
if "%rend%"=="3" goto EFECTOS
if "%rend%"=="4" goto INICIO
if "%rend%"=="5" goto OPTIMIZACION
if "%rend%"=="6" goto RESTAURAR_ENERGIA
if "%rend%"=="7" goto DEMO
if "%rend%"=="8" goto MENU

echo.
echo  [!] Opcion no valida.
timeout /t 2 >nul
goto RENDIMIENTO


:: ============================================================
:: MODO DEMO
:: ============================================================

:DEMO
cls
echo.
echo  ==========================================================
echo                       MODO DEMO
echo                  NO SE CAMBIARA NADA
echo  ==========================================================
echo.
echo  Este modo solamente simula un analisis.
echo  No modifica configuraciones de Windows.
echo.
echo  Analizando...
echo.

echo  [1/5] Analizando rendimiento...
timeout /t 1 >nul

echo  [2/5] Comprobando configuracion de Windows...
timeout /t 1 >nul

echo  [3/5] Buscando posibles optimizaciones...
timeout /t 1 >nul

echo  [4/5] Analizando archivos temporales...
timeout /t 1 >nul

echo  [5/5] Preparando recomendaciones...
timeout /t 1 >nul

echo.
echo  ==========================================================
echo                    ANALISIS TERMINADO
echo  ==========================================================
echo.
echo    [OK] Rendimiento analizado
echo    [OK] Configuracion analizada
echo    [OK] Limpieza analizada
echo    [OK] Optimizaciones detectadas
echo.
echo  Ningun cambio ha sido realizado.
echo.
pause
goto RENDIMIENTO


:: ============================================================
:: ALTO RENDIMIENTO
:: ============================================================

:ALTO_RENDIMIENTO
cls
echo.
echo  ==========================================================
echo                   ALTO RENDIMIENTO
echo  ==========================================================
echo.

call :ADMIN_CHECK

echo  Guardando plan de energia actual...
powercfg /getactivescheme > "%BACKUP%\plan_energia.txt"

echo.
echo  Planes disponibles:
echo.
powercfg /list
echo.

echo  Activando Alto rendimiento...
powercfg /setactive SCHEME_MIN

if errorlevel 1 (
    echo.
    echo  [!] No se pudo activar el plan.
) else (
    echo.
    echo  [OK] Alto rendimiento activado.
)

echo.
pause
goto RENDIMIENTO


:: ============================================================
:: GAME MODE
:: ============================================================

:GAME_MODE
cls
echo.
echo  ==========================================================
echo                       GAME MODE
echo  ==========================================================
echo.

call :ADMIN_CHECK

echo  Activando Game Mode de Windows...
echo.

reg add "HKCU\Software\Microsoft\GameBar" /v AutoGameModeEnabled /t REG_DWORD /d 1 /f >nul

if errorlevel 1 (
    echo  [!] No se pudo modificar Game Mode.
) else (
    echo  [OK] Game Mode activado.
)

echo.
pause
goto RENDIMIENTO


:: ============================================================
:: EFECTOS VISUALES
:: ============================================================

:EFECTOS
cls
echo.
echo  ==========================================================
echo                    EFECTOS VISUALES
echo  ==========================================================
echo.
echo  Esto reducira algunos efectos visuales de Windows.
echo.
choice /c SN /n /m "  Aplicar este ajuste? [S/N]: "

if errorlevel 2 goto RENDIMIENTO

call :ADMIN_CHECK

echo.
echo  Aplicando configuracion...

reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" /v VisualFXSetting /t REG_DWORD /d 2 /f >nul

if errorlevel 1 (
    echo  [!] No se pudo aplicar el ajuste.
) else (
    echo  [OK] Efectos visuales ajustados.
)

echo.
pause
goto RENDIMIENTO


:: ============================================================
:: PROGRAMAS DE INICIO
:: ============================================================

:INICIO
cls
echo.
echo  ==========================================================
echo                  PROGRAMAS DE INICIO
echo  ==========================================================
echo.
echo  Mostrando aplicaciones configuradas para iniciarse.
echo.
echo  ----------------------------------------------------------
echo.

powershell -NoProfile -Command "Get-CimInstance Win32_StartupCommand | Select-Object Name,Command,Location | Format-Table -AutoSize"

echo.
echo  ----------------------------------------------------------
echo.
pause
goto RENDIMIENTO


:: ============================================================
:: OPTIMIZACION RECOMENDADA
:: ============================================================

:OPTIMIZACION
cls
echo.
echo  ==========================================================
echo                OPTIMIZACION RECOMENDADA
echo  ==========================================================
echo.
echo  Se aplicaran:
echo.
echo    - Alto rendimiento
echo    - Game Mode
echo    - Reduccion de efectos visuales
echo.
choice /c SN /n /m "  Continuar? [S/N]: "

if errorlevel 2 goto RENDIMIENTO

call :ADMIN_CHECK

echo.
echo  Aplicando ajustes...
echo.

echo  [1/3] Guardando plan actual...
powercfg /getactivescheme > "%BACKUP%\plan_energia.txt"

echo  [2/3] Activando Alto rendimiento...
powercfg /setactive SCHEME_MIN

echo  [3/3] Activando Game Mode...
reg add "HKCU\Software\Microsoft\GameBar" /v AutoGameModeEnabled /t REG_DWORD /d 1 /f >nul

echo.
echo  Ajustando efectos visuales...
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" /v VisualFXSetting /t REG_DWORD /d 2 /f >nul

echo.
echo  ==========================================================
echo                    OPTIMIZACION TERMINADA
echo  ==========================================================
echo.
pause
goto RENDIMIENTO


:: ============================================================
:: RESTAURAR PLAN DE ENERGIA
:: ============================================================

:RESTAURAR_ENERGIA
cls
echo.
echo  ==========================================================
echo                 RESTAURAR PLAN DE ENERGIA
echo  ==========================================================
echo.

if not exist "%BACKUP%\plan_energia.txt" (
    echo  [!] No existe una copia del plan anterior.
    echo.
    pause
    goto RENDIMIENTO
)

for /f "tokens=4" %%A in ('type "%BACKUP%\plan_energia.txt" ^| findstr /i "Power Scheme GUID"') do (
    set "OLDPLAN=%%A"
)

if not defined OLDPLAN (
    echo  [!] No se pudo identificar el plan anterior.
    echo.
    pause
    goto RENDIMIENTO
)

call :ADMIN_CHECK

echo  Restaurando plan:
echo  %OLDPLAN%
echo.

powercfg /setactive %OLDPLAN%

if errorlevel 1 (
    echo  [!] No se pudo restaurar el plan.
) else (
    echo  [OK] Plan restaurado.
)

echo.
pause
goto RENDIMIENTO


:: ============================================================
:: HERRAMIENTAS DE WINDOWS
:: ============================================================

:WINDOWS
cls
echo.
echo  ==========================================================
echo                  HERRAMIENTAS DE WINDOWS
echo  ==========================================================
echo.
echo    [1] Comprobar archivos del sistema (SFC)
echo    [2] Reparar imagen de Windows (DISM)
echo    [3] Comprobar disco
echo    [4] Volver
echo.

set "winop="
set /p "winop=  Selecciona una opcion: "

if "%winop%"=="1" goto SFC
if "%winop%"=="2" goto DISM
if "%winop%"=="3" goto CHKDSK
if "%winop%"=="4" goto MENU

echo.
echo  [!] Opcion no valida.
timeout /t 2 >nul
goto WINDOWS


:SFC
cls
echo.
echo  ==========================================================
echo                    COMPROBACION SFC
echo  ==========================================================
echo.

call :ADMIN_CHECK
sfc /scannow

echo.
pause
goto WINDOWS


:DISM
cls
echo.
echo  ==========================================================
echo                     REPARACION DISM
echo  ==========================================================
echo.

call :ADMIN_CHECK
DISM /Online /Cleanup-Image /RestoreHealth

echo.
pause
goto WINDOWS


:CHKDSK
cls
echo.
echo  ==========================================================
echo                    COMPROBAR DISCO
echo  ==========================================================
echo.

call :ADMIN_CHECK
chkdsk C: /scan

echo.
pause
goto WINDOWS


:: ============================================================
:: INFORMACION DEL SISTEMA
:: ============================================================

:INFO
cls
echo.
echo  ==========================================================
echo                   INFORMACION DEL SISTEMA
echo  ==========================================================
echo.
echo  Usuario:
echo    %USERNAME%
echo.
echo  Equipo:
echo    %COMPUTERNAME%
echo.
echo  Windows:
ver
echo.
echo  Arquitectura:
echo    %PROCESSOR_ARCHITECTURE%
echo.
echo  Procesadores:
echo    %NUMBER_OF_PROCESSORS%
echo.
echo  ==========================================================
echo.
systeminfo
echo.
pause
goto MENU


:: ============================================================
:: SECCIONES FUTURAS
:: ============================================================

:LIMPIEZA
cls
echo.
echo  ==========================================================
echo                         LIMPIEZA
echo  ==========================================================
echo.
echo  Esta seccion esta en construccion.
echo.
pause
goto MENU


:RED
cls
echo.
echo  ==========================================================
echo                           RED
echo  ==========================================================
echo.
echo  Esta seccion esta en construccion.
echo.
pause
goto MENU


:PRIVACIDAD
cls
echo.
echo  ==========================================================
echo                       PRIVACIDAD
echo  ==========================================================
echo.
echo  Esta seccion esta en construccion.
echo.
pause
goto MENU


:: ============================================================
:: COMPROBAR ADMINISTRADOR
:: ============================================================

:ADMIN_CHECK
net session >nul 2>&1

if %errorlevel% equ 0 exit /b

echo.
echo  ==========================================================
echo              SE NECESITAN PERMISOS DE ADMIN
echo  ==========================================================
echo.
echo  WinTuner se reiniciara como administrador.
echo.

powershell -NoProfile -Command "Start-Process '%~f0' -Verb RunAs"

exit /b


:: ============================================================
:: SALIR
:: ============================================================

:SALIR
cls
echo.
echo  ==========================================================
echo.
echo                  Gracias por usar WinTuner
echo.
echo  ==========================================================
echo.
timeout /t 2 >nul
exit /b
```

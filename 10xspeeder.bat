
@echo off
title Video Speed Changer
cd /d "%~dp0"

set "FFMPEG=C:\ffmpeg\ffmpeg-9.0.1-essentials_build\bin\ffmpeg.exe"
set "INPUT=merged.mkv"

if not exist "%FFMPEG%" (
    echo ERROR: FFmpeg not found!
    pause
    exit /b
)

if not exist "%INPUT%" (
    echo ERROR: merged.mkv not found!
    pause
    exit /b
)

echo.
echo ================================
echo       VIDEO SPEED CHANGER
echo ================================
echo.
echo   [1] 10x
echo   [2] 12x
echo   [3] 14x
echo   [4] 16x
echo   [5] 18x
echo.

choice /c 12345 /n /m "Select speed: "

if errorlevel 5 set "SPEED=18" & set "SCALE=0.0555555556"
if errorlevel 4 if not errorlevel 5 set "SPEED=16" & set "SCALE=0.0625"
if errorlevel 3 if not errorlevel 4 set "SPEED=14" & set "SCALE=0.0714285714"
if errorlevel 2 if not errorlevel 3 set "SPEED=12" & set "SCALE=0.0833333333"
if errorlevel 1 if not errorlevel 2 set "SPEED=10" & set "SCALE=0.1"

echo.
echo Creating %SPEED%x video...
echo.

"%FFMPEG%" -y -itsscale %SCALE% -i "%INPUT%" -map 0:v:0 -an -c:v copy -avoid_negative_ts make_zero "merged_%SPEED%x.mkv"

echo.
echo ================================
echo Finished!
echo Output: merged_%SPEED%x.mkv
echo ================================

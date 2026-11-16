@echo off
setlocal EnableExtensions EnableDelayedExpansion
cd /d "%~dp0"

:: ==========================================
:: SETTINGS
:: ==========================================
set "FFMPEG=C:\ffmpeg\ffmpeg-9.0.1-essentials_build\bin\ffmpeg.exe"
set "SECONDS_PER_IMAGE=0.07"
set "OUTPUT_FILE=slideshow.mkv"
set "AUDIO_FILE=music.mp3"

if not exist "%FFMPEG%" (
    echo [ERROR] FFmpeg not found at "%FFMPEG%"
    pause
    exit /b 1
)

echo Sorting images by timestamp in filename (oldest to newest)...
echo Expected pattern: WIN_YYYYMMDD_HH_MM_SS_Pro.jpg
echo.

:: First pass: rename supported images to temporary names.
:: /O:N sorts filenames alphabetically; the timestamp format sorts chronologically.
set /a count=0
for /f "delims=" %%F in ('dir /b /a-d /o:n 2^>nul') do (
    set "ext=%%~xF"
    if /i "!ext!"==".jpg"  call :TEMP_RENAME "%%F"
    if /i "!ext!"==".jpeg" call :TEMP_RENAME "%%F"
    if /i "!ext!"==".png"  call :TEMP_RENAME "%%F"
)

if !count! EQU 0 (
    echo [ERROR] No JPG, JPEG, or PNG images found.
    pause
    exit /b 1
)

:: Second pass: assign sequential names and build FFmpeg concat list.
if exist "list.txt" del "list.txt"
set /a idx=0

for /l %%i in (1,1,!count!) do (
    set "num=000000%%i"
    set "num=!num:~-6!"
    for %%F in ("__slideshow_tmp_!num!.*") do (
        set /a idx+=1
        set "outnum=0000!idx!"
        set "outnum=!outnum:~-4!"
        set "newname=!outnum!%%~xF"
        ren "%%~F" "!newname!"
        >>"list.txt" echo file '!newname!'
        >>"list.txt" echo duration %SECONDS_PER_IMAGE%
        set "lastfile=!newname!"
    )
)

:: Repeat final frame so FFmpeg honours its duration.
>>"list.txt" echo file '!lastfile!'

echo Renamed !count! images in filename-timestamp order.
echo Duration per image: %SECONDS_PER_IMAGE% seconds
echo.

if exist "%AUDIO_FILE%" (
    echo Creating slideshow with looping %AUDIO_FILE%...
    "%FFMPEG%" -y -f concat -safe 0 -i "list.txt" -stream_loop -1 -i "%AUDIO_FILE%" -map 0:v:0 -map 1:a:0 -vf "scale=1920:1080:force_original_aspect_ratio=decrease,pad=1920:1080:(ow-iw)/2:(oh-ih)/2,setsar=1" -c:v libx264 -preset medium -crf 20 -r 30 -pix_fmt yuv420p -c:a aac -b:a 192k -shortest "%OUTPUT_FILE%"
) else (
    echo [WARNING] music.mp3 not found. Creating video without audio...
    "%FFMPEG%" -y -f concat -safe 0 -i "list.txt" -vf "scale=1920:1080:force_original_aspect_ratio=decrease,pad=1920:1080:(ow-iw)/2:(oh-ih)/2,setsar=1" -c:v libx264 -preset medium -crf 20 -r 30 -pix_fmt yuv420p "%OUTPUT_FILE%"
)

if exist "list.txt" del "list.txt"

echo.
echo Done! Video saved as "%OUTPUT_FILE%" in:
echo %CD%
pause
exit /b

:TEMP_RENAME
set /a count+=1
set "num=000000!count!"
set "num=!num:~-6!"
ren "%~1" "__slideshow_tmp_!num!%~x1"
exit /b

@echo off
setlocal enabledelayedexpansion

:: ==========================================
:: SETTINGS (Edit these numbers if desired)
:: ==========================================
set "FFMPEG=C:\ffmpeg\ffmpeg-9.0.1-essentials_build\bin\ffmpeg.exe"
set "SECONDS_PER_IMAGE=3"
set "OUTPUT_FILE=slideshow.mkv"

:: Verify FFmpeg exists
if not exist "%FFMPEG%" (
    echo [ERROR] FFmpeg not found at "%FFMPEG%"
    pause
    exit /b
)

echo Step 1: Renaming images sequentially (0001, 0002, ...)...
:: First pass: Rename to temporary names so existing numbered files never collide
set /a count=0
for /f "delims=" %%F in ('dir /b /a-d /o:d *.jpg *.jpeg *.png 2^>nul') do (
    set /a count+=1
    ren "%%F" "temp_rename_!count!%%~xF"
)

if %count%==0 (
    echo [ERROR] No JPG, JPEG, or PNG images found in this folder!
    pause
    exit /b
)

:: Second pass: Rename to clean 4-digit numbers and build the FFmpeg input list
if exist "list.txt" del "list.txt"
set /a idx=0
for /l %%i in (1,1,%count%) do (
    for %%F in ("temp_rename_%%i.*") do (
        set /a idx+=1
        set "num=000!idx!"
        set "num=!num:~-4!"
        set "newname=!num!%%~xF"
        ren "%%F" "!newname!"
        >> "list.txt" echo file '!newname!'
        >> "list.txt" echo duration %SECONDS_PER_IMAGE%
        set "lastfile=!newname!"
    )
)

:: Repeat the final image once so FFmpeg does not cut the last slide short
>> "list.txt" echo file '!lastfile!'

echo Renamed %count% images successfully!
echo.
echo Step 2: Scaling images to 1080p and building %OUTPUT_FILE%...
"%FFMPEG%" -y -f concat -safe 0 -i "list.txt" -vf "scale=1920:1080:force_original_aspect_ratio=decrease,pad=1920:1080:(ow-iw)/2:(oh-ih)/2,setsar=1" -c:v libx264 -preset medium -crf 20 -r 30 -pix_fmt yuv420p "%OUTPUT_FILE%"

:: Clean up temporary list file
if exist "list.txt" del "list.txt"

echo.
echo Done! Your video is saved as %OUTPUT_FILE% in this folder.
pause

@echo off
cd /d "%~dp0"

C:\ffmpeg\ffmpeg-9.0.1-essentials_build\bin\ffmpeg.exe -f concat -safe 0 -i files.txt -c copy merged.mkv


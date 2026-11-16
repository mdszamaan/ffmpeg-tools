@echo off
cd /d "%~dp0"

set "FFMPEG=C:\ffmpeg\ffmpeg-9.0.1-essentials_build\bin\ffmpeg.exe"

"%FFMPEG%" -y -i "merged_14x.mkv" -stream_loop -1 -i "music.mp3" -map 0:v:0 -map 1:a:0 -c:v copy -c:a aac -shortest "merged_with_audio.mkv"

pause

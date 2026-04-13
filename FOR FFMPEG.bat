@echo off
setlocal EnableDelayedExpansion
title FFmpeg Video Tools
mode con: cols=90 lines=32

:: Run from this script's folder so relative paths work when double-clicked
pushd "%~dp0" 2>nul

:menu
color 0B
cls
call :draw_main_menu
choice /c 12345 /n /m "  Select [1]-[5] : "
if errorlevel 5 goto exit_app
if errorlevel 4 goto gif_converter
if errorlevel 3 goto cutter
if errorlevel 2 goto joiner
if errorlevel 1 goto resizer
goto menu

:draw_main_menu
echo.
echo    __________________________________________________________________________________
echo.
echo FFMPEG VIDEO TOOLS
echo      Resize, join, cut, or turn clips into GIFs - all from this menu.
echo    __________________________________________________________________________________
echo.
echo      [1]  Batch Video Resizer - all .mkv / .mp4 in this folder ^(prefix: resized_^)
echo      [2]  Video Joiner            - expects 1.mkv, 2.mkv, 3.mkv  -^> output_combined.mkv
echo      [3]  Video Cutter            - stream copy to cut_filename
echo      [4]  Video to GIF            - short clip to GIF ^(fps 10, width 320^)
echo      [5]  Exit
echo.
echo    __________________________________________________________________________________
exit /b 0

:resizer
color 0E
call :section_header "BATCH VIDEO RESIZER"
echo      Pick a target resolution. Files are scaled with ffmpeg scale=WxH.
echo      Output names: resized_originalname.ext
echo.
choice /c HMLB /n /m "  [H] Full HD 1920x1080   [M] HD 1280x720   [L] SD 640x360   [B] Back : "
if errorlevel 4 goto menu
if errorlevel 3 set "scale=640:360" & set "quality=low"
if errorlevel 2 set "scale=1280:720" & set "quality=medium"
if errorlevel 1 set "scale=1920:1080" & set "quality=high"

echo.
echo      Processing .mkv and .mp4 in:
echo      %CD%
echo.
for %%A in (*.mkv *.mp4) do (
    echo      --- Resizing %%A ^(!quality!^) ---
    ffmpeg -hide_banner -loglevel error -i "%%A" -vf "scale=!scale!" -progress "progress.txt" -nostats -y "resized_%%A"
    call :show_progress
)
color 0A
echo.
echo      Done. Resized files use the prefix resized_
call :pause_menu
goto menu

:joiner
color 0E
call :section_header "VIDEO JOINER"
echo      Builds joinlist.txt from 1.mkv, 2.mkv, 3.mkv then concat-copies to output_combined.mkv
echo.
echo      Working folder: %CD%
echo.
echo      Building list...
(for %%A in (1.mkv 2.mkv 3.mkv) do echo file '%%A') > joinlist.txt

echo      Joining with ffmpeg...
ffmpeg -hide_banner -loglevel error -f concat -safe 0 -i joinlist.txt -c copy -progress "progress.txt" -nostats -y output_combined.mkv
call :show_progress

del joinlist.txt 2>nul
color 0A
echo.
echo      Saved: output_combined.mkv
call :pause_menu
goto menu

:cutter
color 0E
call :section_header "VIDEO CUTTER"
echo      Stream-copy cut ^(fast^). Output: cut_yourfile.ext
echo.
set "filename="
set "starttime="
set "endtime="
set /p "filename= Video file name (with extension): "
if "!filename!"=="" (
    color 0C
    echo      No file name - cancelled.
    timeout /t 2 >nul
    goto menu
)
set /p "starttime=      Start time (HH:MM:SS): "
set /p "endtime=      End time   (HH:MM:SS): "

ffmpeg -hide_banner -loglevel error -i "!filename!" -ss !starttime! -to !endtime! -progress "progress.txt" -nostats -c copy -y "cut_!filename!"
call :show_progress

color 0A
echo.
echo      Saved: cut_!filename!
call :pause_menu
goto menu

:gif_converter
color 0E
call :section_header "VIDEO TO GIF"
echo      Segment to GIF: fps=10, scale=320px wide. Output: output_name.gif
echo.
set "gifvid="
set "gifstart="
set "gifduration="
set /p "gifvid=      Video file name (with extension): "
if "!gifvid!"=="" (
    color 0C
    echo      No file name - cancelled.
    timeout /t 2 >nul
    goto menu
)
set /p "gifstart=      Start time (HH:MM:SS): "
set /p "gifduration=      Duration (seconds): "

ffmpeg -hide_banner -loglevel error -i "!gifvid!" -ss !gifstart! -t !gifduration! -vf "fps=10,scale=320:-1:flags=lanczos" -progress "progress.txt" -nostats -c:v gif -y "output_!gifvid!.gif"
call :show_progress

color 0A
echo.
echo      Saved: output_!gifvid!.gif
call :pause_menu
goto menu

:section_header
cls
echo.
echo    ----------------------------------------------------------------------------------
echo      %~1
echo    ----------------------------------------------------------------------------------
echo.
exit /b 0

:show_progress
if exist progress.txt del /q progress.txt >nul 2>&1
exit /b 0

:pause_menu
echo    Press any key to return to the menu . . .
pause >nul
exit /b 0

:exit_app
color 07
popd 2>nul
endlocal
exit /b 0

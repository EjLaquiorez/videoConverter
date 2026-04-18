@echo off
setlocal EnableDelayedExpansion
title FFmpeg Video Tools
mode con: cols=90 lines=32

:: Run from this script's folder so relative paths work when double-clicked
pushd "%~dp0" 2>nul

where ffmpeg >nul 2>&1
if errorlevel 1 (
    color 0C
    cls
    echo.
    echo   FFmpeg was not found in PATH.
    echo   Install FFmpeg and add its bin folder to your system PATH, then run this again.
    echo   https://ffmpeg.org/download.html
    echo.
    pause
    popd 2>nul
    endlocal
    exit /b 1
)

:menu
color 0B
cls
call :draw_main_menu
choice /c 12345 /n /m "  Select [1]-[5] : "
if errorlevel 5 goto exit_app
if errorlevel 4 goto tool_gif
if errorlevel 3 goto tool_cut
if errorlevel 2 goto tool_join
if errorlevel 1 goto tool_resize
goto menu

:draw_main_menu
echo.
echo    __________________________________________________________________________________
echo.
echo   FFMPEG VIDEO TOOLS
echo      Batch resize, join, trim, or export GIFs. Output names use clear suffixes.
echo    __________________________________________________________________________________
echo.
echo      [1]  Batch resize     - all .mkv / .mp4  -^>  name_converted.ext
echo      [2]  Join videos     - numbered clips OR all .mkv A-Z  -^>  your_name.mkv
echo      [3]  Trim / cut      - stream copy  -^>  name_converted.ext
echo      [4]  Clip to GIF     - pick size preset  -^>  name_converted.gif
echo      [5]  Exit
echo.
echo    __________________________________________________________________________________
exit /b 0

:tool_resize
color 0E
call :section_header "BATCH RESIZE"
echo      Output pattern:  basename_converted.ext   ^(e.g. vacation_converted.mkv^)
echo      Presets fit inside W x H ^(aspect kept; no stretch^)
echo.
choice /c UHMLB /n /m "  [U] 4K 3840x2160   [H] 1080p   [M] 720p   [L] 360p   [B] Back : "
if errorlevel 5 goto menu
if errorlevel 4 set "scaleFilter=640:360:force_original_aspect_ratio=decrease" & set "presetName=360p"
if errorlevel 3 set "scaleFilter=1280:720:force_original_aspect_ratio=decrease" & set "presetName=720p"
if errorlevel 2 set "scaleFilter=1920:1080:force_original_aspect_ratio=decrease" & set "presetName=1080p"
if errorlevel 1 set "scaleFilter=3840:2160:force_original_aspect_ratio=decrease" & set "presetName=2160p"

echo.
echo      Folder:  %CD%
echo.
set "resizeHadErr=0"
for %%A in (*.mkv *.mp4) do (
    set "resizeOut=%%~nA_converted%%~xA"
    echo      --- %%A  -^>  !resizeOut! ---
    ffmpeg -hide_banner -loglevel error -i "%%A" -vf "scale=!scaleFilter!" -progress "progress.txt" -nostats -y "!resizeOut!"
    if errorlevel 1 set "resizeHadErr=1"
    call :clean_progress
)
if "!resizeHadErr!"=="1" (
    color 0C
    echo.
    echo      One or more resizes failed. Check FFmpeg output above.
) else (
    color 0A
    echo.
    echo      Done. Files named like:  basename_converted.ext
)
call :pause_menu
goto menu

:tool_join
color 0E
call :section_header "JOIN VIDEOS"
echo      Builds a concat list, then ffmpeg -c copy ^(same codec required^).
echo.
choice /c NAB /n /m "  [N] Numbered 1.ext .. N.ext   [A] All .mkv A-Z   [B] Back : "
if errorlevel 3 goto menu
if errorlevel 2 goto join_all_mkv
if errorlevel 1 goto join_numbered

:join_numbered
set "joinMax="
set "joinExt="
set /p "joinMax=      Highest index N ^(files 1 through N^): "
if "!joinMax!"=="" (
    color 0C
    echo      Cancelled.
    timeout /t 2 >nul
    goto menu
)
set /p "joinExt=      Extension without dot [mkv]: "
if "!joinExt!"=="" set "joinExt=mkv"
(for /l %%i in (1,1,!joinMax!) do echo file '%%i.!joinExt!') > joinlist.txt
goto join_run_ffmpeg

:join_all_mkv
set "joinCount=0"
for %%A in (*.mkv) do set /a joinCount+=1
if !joinCount! equ 0 (
    color 0C
    echo      No .mkv files in this folder.
    timeout /t 2 >nul
    goto menu
)
(for %%A in (*.mkv) do echo file '%%A') > joinlist.txt

:join_run_ffmpeg
echo.
set "joinOutput="
set /p "joinOutput=      Output filename [vc_joined.mkv]: "
if "!joinOutput!"=="" set "joinOutput=vc_joined.mkv"
echo      Joining to:  !joinOutput!
ffmpeg -hide_banner -loglevel error -f concat -safe 0 -i joinlist.txt -c copy -progress "progress.txt" -nostats -y "!joinOutput!"
set "joinFfErr=%errorlevel%"
call :clean_progress

del joinlist.txt 2>nul
if not "!joinFfErr!"=="0" (
    color 0C
    echo.
    echo      Join failed ^(exit !joinFfErr!^). Same codec/settings usually required for -c copy.
    call :pause_menu
    goto menu
)
color 0A
echo.
echo      Saved:  !joinOutput!
call :pause_menu
goto menu

:tool_cut
color 0E
call :section_header "TRIM / CUT"
echo      Fast stream copy. Output:  basename_converted.ext
echo.
set "cutSource="
set "cutStart="
set "cutEnd="
set /p "cutSource=      Source video ^(with extension^): "
if "!cutSource!"=="" (
    color 0C
    echo      No file - cancelled.
    timeout /t 2 >nul
    goto menu
)
set /p "cutStart=      Start time (HH:MM:SS): "
set /p "cutEnd=      End time   (HH:MM:SS): "

for %%I in ("!cutSource!") do set "cutOutput=%%~nI_converted%%~xI"

ffmpeg -hide_banner -loglevel error -i "!cutSource!" -ss !cutStart! -to !cutEnd! -progress "progress.txt" -nostats -c copy -y "!cutOutput!"
set "cutFfErr=%errorlevel%"
call :clean_progress

if not "!cutFfErr!"=="0" (
    color 0C
    echo.
    echo      Trim failed ^(exit !cutFfErr!^). Check times and that the file is readable.
    call :pause_menu
    goto menu
)
color 0A
echo.
echo      Saved:  !cutOutput!
call :pause_menu
goto menu

:tool_gif
color 0E
call :section_header "CLIP TO GIF"
echo      Output:  basename_converted.gif
echo.
choice /c SMLB /n /m "  [S] Small 240px 8fps   [M] Medium 320px 10fps   [L] Large 480px 12fps   [B] Back : "
if errorlevel 4 goto menu
if errorlevel 3 set "gifVf=fps=12,scale=480:-1:flags=lanczos" & set "gifPreset=large"
if errorlevel 2 set "gifVf=fps=10,scale=320:-1:flags=lanczos" & set "gifPreset=medium"
if errorlevel 1 set "gifVf=fps=8,scale=240:-1:flags=lanczos" & set "gifPreset=small"

set "gifSource="
set "gifStart="
set "gifSeconds="
set /p "gifSource=      Source video ^(with extension^): "
if "!gifSource!"=="" (
    color 0C
    echo      No file - cancelled.
    timeout /t 2 >nul
    goto menu
)
set /p "gifStart=      Start time (HH:MM:SS): "
set /p "gifSeconds=      Duration (seconds): "

for %%G in ("!gifSource!") do set "gifOutput=%%~nG_converted.gif"

ffmpeg -hide_banner -loglevel error -i "!gifSource!" -ss !gifStart! -t !gifSeconds! -vf "!gifVf!" -progress "progress.txt" -nostats -c:v gif -y "!gifOutput!"
set "gifFfErr=%errorlevel%"
call :clean_progress

if not "!gifFfErr!"=="0" (
    color 0C
    echo.
    echo      GIF export failed ^(exit !gifFfErr!^).
    call :pause_menu
    goto menu
)
color 0A
echo.
echo      Saved:  !gifOutput!
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

:clean_progress
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

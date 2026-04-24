@echo off
setlocal EnableDelayedExpansion
title FFmpeg Video Tools
mode con: cols=90 lines=42

:: Run from this script's folder so relative paths work when double-clicked
pushd "%~dp0" 2>nul

where ffmpeg >nul 2>&1
if errorlevel 1 (
    call :color_error
    cls
    echo.
    echo   FFmpeg was not found in PATH.
    echo   This menu does not install FFmpeg. Download a Windows build, unzip it, then add
    echo   the folder that contains ffmpeg.exe to your system PATH and open a NEW console.
    echo   https://ffmpeg.org/download.html
    echo.
    pause
    popd 2>nul
    endlocal
    exit /b 1
)

:menu
call :color_main
cls
call :draw_main_menu
call :color_prompt
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
echo   FFMPEG VIDEO TOOLS   ^(needs FFmpeg installed and on your PATH^)
echo    __________________________________________________________________________________
echo.
echo      FIRST-TIME / HOW TO USE THIS MENU
echo        * Keep this .bat in the SAME FOLDER as your videos ^(double-click it there^).
echo        * Press a number key 1-5 when asked. Each tool shows extra help on its screen.
echo        * New files are named:  yourfile_converted.ext   ^(originals are not deleted^).
echo        * Join ^(option 2^) is different: YOU choose the output filename ^(e.g. final.mkv^).
echo.
echo      [1]  Batch resize   Re-encode every .mkv and .mp4 here -^>  name_converted.ext
echo      [2]  Join videos    Glue clips together ^(same codec^) -^>  filename YOU type
echo      [3]  Trim / cut     Copy out a time range fast -^>  name_converted.ext
echo      [4]  Clip to GIF    Short animated GIF from part of a video -^>  name_converted.gif
echo      [5]  Exit           Close this menu
echo.
echo    __________________________________________________________________________________
exit /b 0

:tool_resize
call :section_header "BATCH RESIZE"
call :color_info
echo      WHAT THIS DOES
echo        - Processes every .mkv and .mp4 in THIS folder ^(not subfolders^).
echo        - Writes NEW files:  vacation.mkv  becomes  vacation_converted.mkv
echo        - If name_converted already exists, it is overwritten. Your original stays.
echo      SIZE PRESETS  ^(video fits inside the box; aspect ratio kept; no stretching^)
echo.
call :color_prompt
choice /c UHMLB /n /m "  [U] 4K 3840x2160   [H] 1080p   [M] 720p   [L] 360p   [B] Back : "
if errorlevel 5 goto menu
if errorlevel 4 set "scaleFilter=640:360:force_original_aspect_ratio=decrease"
if errorlevel 3 set "scaleFilter=1280:720:force_original_aspect_ratio=decrease"
if errorlevel 2 set "scaleFilter=1920:1080:force_original_aspect_ratio=decrease"
if errorlevel 1 set "scaleFilter=3840:2160:force_original_aspect_ratio=decrease"

call :color_run
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
    call :color_error
    echo.
    echo      One or more resizes failed. Check FFmpeg output above.
) else (
    call :color_success
    echo.
    echo      Done. Files named like:  basename_converted.ext
)
call :pause_menu
goto menu

:tool_join
call :section_header "JOIN VIDEOS"
call :color_info
echo      WHAT THIS DOES
echo        - Plays clips one after another into ONE file ^(no re-encode: -c copy^).
echo        - All parts should match ^(same resolution, codec, frame rate^) or join may fail.
echo      TWO WAYS TO ORDER CLIPS
echo        [N] Numbered: name files 1.mkv, 2.mkv, ... up to N.mkv in THIS folder.
echo            You will type N ^(highest number^) and the extension ^(mkv is default^).
echo        [A] All .mkv: joins every .mkv here in A-Z filename order ^(check names first!^).
echo      At the end you TYPE the output name ^(example: my_movie.mkv^).
echo.
call :color_prompt
choice /c NAB /n /m "  [N] Numbered 1.ext .. N.ext   [A] All .mkv A-Z   [B] Back : "
if errorlevel 3 goto menu
if errorlevel 2 goto join_all_mkv
if errorlevel 1 goto join_numbered

:join_numbered
set "joinMax="
set "joinExt="
call :color_prompt
set /p "joinMax=      Highest index N ^(files 1 through N^): "
if "!joinMax!"=="" (
    call :color_error
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
    call :color_error
    echo      No .mkv files in this folder.
    timeout /t 2 >nul
    goto menu
)
(for %%A in (*.mkv) do echo file '%%A') > joinlist.txt

:join_run_ffmpeg
call :color_info
echo.
echo      OUTPUT FILE  ^(include extension: .mkv or .mp4^). Press Enter for default.
echo.
call :color_prompt
set "joinOutput="
set /p "joinOutput=      Output filename [vc_joined.mkv]: "
if "!joinOutput!"=="" set "joinOutput=vc_joined.mkv"
call :color_run
echo      Joining to:  !joinOutput!
ffmpeg -hide_banner -loglevel error -f concat -safe 0 -i joinlist.txt -c copy -progress "progress.txt" -nostats -y "!joinOutput!"
set "joinFfErr=%errorlevel%"
call :clean_progress

del joinlist.txt 2>nul
if not "!joinFfErr!"=="0" (
    call :color_error
    echo.
    echo      Join failed ^(exit !joinFfErr!^). Same codec/settings usually required for -c copy.
    call :pause_menu
    goto menu
)
call :color_success
echo.
echo      Saved:  !joinOutput!
call :pause_menu
goto menu

:tool_cut
call :section_header "TRIM / CUT"
call :color_info
echo      WHAT THIS DOES
echo        - Saves ONLY the part between start and end time ^(fast stream copy^).
echo        - Output name is always:  yourfile_converted.ext  ^(same folder as source^).
echo      HOW TO FILL IN THE PROMPTS
echo        - Video file: type the name you see in the folder ^(e.g. clip.mp4^).
echo          Or paste a full path if the file is somewhere else.
echo        - Times use  HH:MM:SS  ^(examples: 0:00:05  or  00:01:30^). Start must be before end.
echo.
set "cutSource="
set "cutStart="
set "cutEnd="
call :color_prompt
set /p "cutSource=      Source video ^(with extension^): "
if "!cutSource!"=="" (
    call :color_error
    echo      No file - cancelled.
    timeout /t 2 >nul
    goto menu
)
set /p "cutStart=      Start time (HH:MM:SS): "
set /p "cutEnd=      End time   (HH:MM:SS): "

for %%I in ("!cutSource!") do set "cutOutput=%%~nI_converted%%~xI"

call :color_run
ffmpeg -hide_banner -loglevel error -i "!cutSource!" -ss !cutStart! -to !cutEnd! -progress "progress.txt" -nostats -c copy -y "!cutOutput!"
set "cutFfErr=%errorlevel%"
call :clean_progress

if not "!cutFfErr!"=="0" (
    call :color_error
    echo.
    echo      Trim failed ^(exit !cutFfErr!^). Check times and that the file is readable.
    call :pause_menu
    goto menu
)
call :color_success
echo.
echo      Saved:  !cutOutput!
call :pause_menu
goto menu

:tool_gif
call :section_header "CLIP TO GIF"
call :color_info
echo      WHAT THIS DOES
echo        - Makes an animated GIF from part of your video ^(re-encodes that part^).
echo        - Output:  yourfile_converted.gif
echo      STEPS
echo        1^) Pick size/quality below ^(S=smallest file, L=bigger/clearer^).
echo        2^) Type video filename, start time HH:MM:SS, then LENGTH in SECONDS ^(not end time^).
echo      TIP: Keep duration small ^(a few seconds^); long GIFs get very large.
echo.
call :color_prompt
choice /c SMLB /n /m "  [S] Small 240px 8fps   [M] Medium 320px 10fps   [L] Large 480px 12fps   [B] Back : "
if errorlevel 4 goto menu
if errorlevel 3 set "gifVf=fps=12,scale=480:-1:flags=lanczos"
if errorlevel 2 set "gifVf=fps=10,scale=320:-1:flags=lanczos"
if errorlevel 1 set "gifVf=fps=8,scale=240:-1:flags=lanczos"

set "gifSource="
set "gifStart="
set "gifSeconds="
call :color_prompt
set /p "gifSource=      Source video ^(with extension^): "
if "!gifSource!"=="" (
    call :color_error
    echo      No file - cancelled.
    timeout /t 2 >nul
    goto menu
)
set /p "gifStart=      Start time (HH:MM:SS): "
set /p "gifSeconds=      Duration (seconds): "

for %%G in ("!gifSource!") do set "gifOutput=%%~nG_converted.gif"

call :color_run
ffmpeg -hide_banner -loglevel error -i "!gifSource!" -ss !gifStart! -t !gifSeconds! -vf "!gifVf!" -progress "progress.txt" -nostats -c:v gif -y "!gifOutput!"
set "gifFfErr=%errorlevel%"
call :clean_progress

if not "!gifFfErr!"=="0" (
    call :color_error
    echo.
    echo      GIF export failed ^(exit !gifFfErr!^).
    call :pause_menu
    goto menu
)
call :color_success
echo.
echo      Saved:  !gifOutput!
call :pause_menu
goto menu

:section_header
cls
call :color_title
echo.
echo    ----------------------------------------------------------------------------------
echo      %~1
echo    ----------------------------------------------------------------------------------
echo.
exit /b 0

:color_main
color 0B
exit /b 0

:color_title
color 0D
exit /b 0

:color_info
color 09
exit /b 0

:color_prompt
color 0E
exit /b 0

:color_run
color 07
exit /b 0

:color_success
color 0A
exit /b 0

:color_error
color 0C
exit /b 0

:color_neutral
color 07
exit /b 0

:clean_progress
if exist progress.txt del /q progress.txt >nul 2>&1
exit /b 0

:pause_menu
call :color_neutral
echo    Press any key to return to the menu . . .
pause >nul
exit /b 0

:exit_app
call :color_neutral
popd 2>nul
endlocal
exit /b 0

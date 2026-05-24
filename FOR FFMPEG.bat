@echo off
setlocal EnableDelayedExpansion
title FFmpeg Video Tools

:: Resize window only when Explorer launches via cmd /c (skip if already in a console)
echo %CMDCMDLINE%| findstr /i /c:" /c " >nul && mode con: cols=90 lines=42

:: Temp files under %TEMP% so they never collide with user media
set "VC_TEMPDIR=%TEMP%\videoConverter"
if not exist "%VC_TEMPDIR%" mkdir "%VC_TEMPDIR%" 2>nul
set "VC_PROGRESS=%VC_TEMPDIR%\progress.txt"
set "VC_JOINLIST=%VC_TEMPDIR%\joinlist.txt"

:: Run from this script's folder so relative paths work when double-clicked
pushd "%~dp0" 2>nul

call :resolve_ffmpeg
if errorlevel 1 (
    call :color_error
    cls
    echo.
    echo   FFmpeg was not found.
    echo   Put ffmpeg.exe next to this .bat, set FFMPEG_EXE to its full path,
    echo   or add the folder that contains ffmpeg.exe to your system PATH
    echo   and open a NEW console.
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

:: ---------- Batch resize ----------

:tool_resize
call :section_header "BATCH RESIZE"
call :color_info
echo      WHAT THIS DOES
echo        - Processes every .mkv and .mp4 in THIS folder ^(not subfolders^).
echo        - Writes NEW files:  vacation.mkv  becomes  vacation_converted.mkv
echo        - If name_converted already exists, it is OVERWRITTEN. Your original stays.
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
set "resizeCount=0"
for %%A in (*.mkv *.mp4) do (
    if exist "%%~fA" (
        call :is_converted_basename "%%~nA"
        if "!IS_CONV!"=="0" (
            set /a resizeCount+=1
            set "resizeOut=%%~nA_converted%%~xA"
            echo      --- %%A  -^>  !resizeOut! ---
            "%FFMPEG%" -hide_banner -loglevel error -i "%%A" -vf "scale=!scaleFilter!" -c:v libx264 -preset medium -crf 23 -c:a copy -progress "%VC_PROGRESS%" -nostats -y "!resizeOut!"
            if errorlevel 1 set "resizeHadErr=1"
            call :clean_progress
        )
    )
)
if "!resizeCount!"=="0" (
    call :color_error
    echo.
    echo      No source .mkv or .mp4 files found ^(or only *_converted files^).
) else (
    if "!resizeHadErr!"=="1" (
        call :color_error
        echo.
        echo      One or more resizes failed. Check FFmpeg output above.
    ) else (
        call :color_success
        echo.
        echo      Done. Files named like:  basename_converted.ext
    )
)
call :pause_menu
goto menu

:: ---------- Join ----------

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
echo            Skips *_converted files and the output name you choose.
echo      You TYPE the output name ^(example: my_movie.mkv^) before joining starts.
echo.
call :color_prompt
choice /c NAB /n /m "  [N] Numbered 1.ext .. N.ext   [A] All .mkv A-Z   [B] Back : "
if errorlevel 3 goto menu
if errorlevel 2 goto join_all_mkv
if errorlevel 1 goto join_numbered

:join_numbered
set "joinMode=numbered"
set "joinMax="
set "joinExt="
call :color_prompt
set /p "joinMax=      Highest index N ^(files 1 through N^): "
if "!joinMax!"=="" (
    call :show_err_short "Cancelled."
    goto menu
)
echo !joinMax!| findstr /r "^[1-9][0-9]*$" >nul || (
    call :show_err_short "N must be a positive whole number ^(1, 2, 3, ...^)."
    goto menu
)
set /p "joinExt=      Extension without dot [mkv]: "
if "!joinExt!"=="" set "joinExt=mkv"
echo !joinExt!| findstr /r "[/\\:.]" >nul && (
    call :show_err_short "Extension must be letters/numbers only ^(e.g. mkv^)."
    goto menu
)
set "joinMissing="
for /l %%i in (1,1,!joinMax!) do (
    if not exist "%%i.!joinExt!" set "joinMissing=!joinMissing! %%i.!joinExt!"
)
if not "!joinMissing!"=="" (
    call :color_error
    echo.
    echo      Missing clip files:!joinMissing!
    call :pause_menu
    goto menu
)
goto join_ask_output

:join_all_mkv
set "joinMode=all"
set "joinCount=0"
for %%A in (*.mkv) do (
    call :is_converted_basename "%%~nA"
    if "!IS_CONV!"=="0" set /a joinCount+=1
)
if !joinCount! equ 0 (
    call :show_err_short "No .mkv files in this folder ^(excluding *_converted^)."
    goto menu
)
goto join_ask_output

:join_ask_output
call :color_info
echo.
echo      OUTPUT FILE  ^(include extension: .mkv or .mp4^). Press Enter for default.
echo.
call :color_prompt
set "joinOutput="
set /p "joinOutput=      Output filename [vc_joined.mkv]: "
if "!joinOutput!"=="" set "joinOutput=vc_joined.mkv"
echo !joinOutput!| findstr /r "[/\\:]" >nul && (
    call :show_err_short "Use a simple filename here ^(no folder path^)."
    goto menu
)

del "%VC_JOINLIST%" 2>nul
if "!joinMode!"=="numbered" (
    for /l %%i in (1,1,!joinMax!) do (
        if /i not "%%i.!joinExt!"=="!joinOutput!" call :join_append "%%i.!joinExt!"
    )
) else (
    set "joinCount=0"
    for %%A in (*.mkv) do (
        if /i not "%%~nxA"=="!joinOutput!" (
            call :is_converted_basename "%%~nA"
            if "!IS_CONV!"=="0" (
                set /a joinCount+=1
                call :join_append "%%A"
            )
        )
    )
    if !joinCount! equ 0 (
        call :show_err_short "No .mkv clips left to join ^(output name may match the only file^)."
        goto menu
    )
)
if not exist "%VC_JOINLIST%" (
    call :show_err_short "No clips to join after excluding the output file."
    goto menu
)

:join_run_ffmpeg
call :color_run
echo      Joining to:  !joinOutput!
"%FFMPEG%" -hide_banner -loglevel error -f concat -safe 0 -i "%VC_JOINLIST%" -c copy -progress "%VC_PROGRESS%" -nostats -y "!joinOutput!"
set "joinFfErr=!errorlevel!"
call :clean_progress

del "%VC_JOINLIST%" 2>nul
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

:: ---------- Trim ----------

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
    call :show_err_short "No file - cancelled."
    goto menu
)
if not exist "!cutSource!" (
    call :show_err_short "File not found: !cutSource!"
    goto menu
)
set /p "cutStart=      Start time (HH:MM:SS): "
set /p "cutEnd=      End time   (HH:MM:SS): "
if "!cutStart!"=="" (
    call :show_err_short "Start time is required."
    goto menu
)
if "!cutEnd!"=="" (
    call :show_err_short "End time is required."
    goto menu
)

for %%I in ("!cutSource!") do set "cutOutput=%%~nI_converted%%~xI"

call :color_run
"%FFMPEG%" -hide_banner -loglevel error -ss "!cutStart!" -to "!cutEnd!" -i "!cutSource!" -progress "%VC_PROGRESS%" -nostats -c copy -y "!cutOutput!"
set "cutFfErr=!errorlevel!"
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

:: ---------- GIF ----------

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
    call :show_err_short "No file - cancelled."
    goto menu
)
if not exist "!gifSource!" (
    call :show_err_short "File not found: !gifSource!"
    goto menu
)
set /p "gifStart=      Start time (HH:MM:SS): "
if "!gifStart!"=="" set "gifStart=0:00:00"
set /p "gifSeconds=      Duration (seconds): "
if "!gifSeconds!"=="" (
    call :show_err_short "Duration ^(seconds^) is required."
    goto menu
)
echo !gifSeconds!| findstr /r "^[1-9][0-9]*$" >nul || (
    call :show_err_short "Enter duration as a whole number of seconds ^(e.g. 5^), at least 1."
    goto menu
)

for %%G in ("!gifSource!") do set "gifOutput=%%~nG_converted.gif"

call :color_run
"%FFMPEG%" -hide_banner -loglevel error -ss "!gifStart!" -t "!gifSeconds!" -i "!gifSource!" -vf "!gifVf!" -progress "%VC_PROGRESS%" -nostats -c:v gif -y "!gifOutput!"
set "gifFfErr=!errorlevel!"
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

:: ---------- UI helpers ----------

:section_header
cls
call :color_title
echo.
echo    ----------------------------------------------------------------------------------
echo      %~1
echo    ----------------------------------------------------------------------------------
echo.
exit /b 0

:: Palette (black bg): default, blue headers, gray help, cyan prompts, soft green/red results
:color_main
color 07
exit /b 0

:color_title
color 09
exit /b 0

:color_info
color 08
exit /b 0

:color_prompt
color 0B
exit /b 0

:color_run
color 08
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

:show_err_short
call :color_error
echo      %~1
timeout /t 2 >nul
exit /b 0

:clean_progress
if exist "%VC_PROGRESS%" del /q "%VC_PROGRESS%" >nul 2>&1
exit /b 0

:pause_menu
call :color_neutral
echo    Press any key to return to the menu . . .
pause >nul
exit /b 0

:: ---------- Logic helpers ----------

:resolve_ffmpeg
set "FFMPEG="
if defined FFMPEG_EXE if exist "!FFMPEG_EXE!" set "FFMPEG=!FFMPEG_EXE!"
if not defined FFMPEG if exist "%~dp0ffmpeg.exe" set "FFMPEG=%~dp0ffmpeg.exe"
if not defined FFMPEG (
    where ffmpeg >nul 2>&1
    if not errorlevel 1 set "FFMPEG=ffmpeg"
)
if not defined FFMPEG exit /b 1
exit /b 0

:is_converted_basename
set "IS_CONV=0"
echo %~1| findstr /i /r "_converted$" >nul && set "IS_CONV=1"
exit /b 0

:: Appends one concat demuxer line to VC_JOINLIST (escapes apostrophes in paths)
:join_append
set "joinLinePath=%~f1"
set "joinLinePath=!joinLinePath:\=/!"
set "joinLinePath=!joinLinePath:'='\'\''!"
>> "%VC_JOINLIST%" echo file '!joinLinePath!'
exit /b 0

:exit_app
call :color_neutral
popd 2>nul
endlocal
exit /b 0

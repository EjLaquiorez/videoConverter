@echo off
:: Video Utility Script using FFMPEG
setlocal enabledelayedexpansion

:menu
cls
echo.
echo =============================
echo  Video Utility Script
echo =============================
echo 1. Batch Video Resizer
echo 2. Video Joiner
echo 3. Video Cutter
echo 4. Video to GIF Converter (Additional Feature)
echo 5. Exit
echo =============================
set /p choice="Choose an option: "

if %choice%==1 goto resizer
if %choice%==2 goto joiner
if %choice%==3 goto cutter
if %choice%==4 goto gif_converter
if %choice%==5 exit

:resizer
cls
echo =============================
echo  Batch Video Resizer
echo =============================
echo Purpose: Resize multiple video files to different resolutions (high, medium, low).
echo How to Use:
echo 1. Choose a quality level:
echo    - high: 1920x1080 (Full HD)
echo    - medium: 1280x720 (HD)
echo    - low: 640x360 (SD)
echo 2. The script will process all .mkv and .mp4 files in the folder.
echo 3. New files will be created with the prefix "resized_".
echo.
set /p quality="Choose quality (high, medium, low): "

if /i "%quality%"=="high" set scale=1920:1080
if /i "%quality%"=="medium" set scale=1280:720
if /i "%quality%"=="low" set scale=640:360

for %%A in (*.mkv *.mp4) do (
    echo Resizing %%A to %quality%...
    ffmpeg -i "%%A" -vf "scale=%scale%" -progress "progress.txt" -nostats "resized_%%A"
    call :show_progress
)

echo Done resizing videos!
pause
goto menu

:joiner
cls
echo =============================
echo  Video Joiner
echo =============================
echo Purpose: Combine multiple video files into one, maintaining numerical order.
echo How to Use:
echo 1. Ensure your video files are named as 1.mkv, 2.mkv, 3.mkv, etc.
echo 2. The script will join these videos into "output_combined.mkv".
echo.
echo Creating a list of videos to join...
(for %%A in (1.mkv 2.mkv 3.mkv) do echo file '%%A') > joinlist.txt

echo Joining videos...
ffmpeg -f concat -safe 0 -i joinlist.txt -c copy -progress "progress.txt" -nostats output_combined.mkv
call :show_progress

del joinlist.txt
echo Videos joined into output_combined.mkv!
pause
goto menu

:cutter
cls
echo =============================
echo  Video Cutter
echo =============================
echo Purpose: Cut a specific portion from a video based on user-defined start and end times.
echo How to Use:
echo 1. Enter the full name of the video file (e.g., example.mkv).
echo 2. Input the start time in HH:MM:SS format (e.g., 00:01:30).
echo 3. Input the end time in the same format.
echo 4. A new file named "cut_example.mkv" will be created with the specified segment.
echo.
set /p filename="Enter the video file name (with extension): "
set /p starttime="Enter the start time (format HH:MM:SS): "
set /p endtime="Enter the end time (format HH:MM:SS): "

ffmpeg -i "%filename%" -ss %starttime% -to %endtime% -progress "progress.txt" -nostats -c copy "cut_%filename%"
call :show_progress

echo Video cut saved as cut_%filename%!
pause
goto menu

:gif_converter
cls
echo =============================
echo  Video to GIF Converter
echo =============================
echo Purpose: Convert a segment of a video into a GIF.
echo How to Use:
echo 1. Enter the full name of the video file (e.g., example.mkv).
echo 2. Input the start time in HH:MM:SS format (e.g., 00:01:30).
echo 3. Specify the duration in seconds (e.g., 5 for a 5-second GIF).
echo 4. A GIF named "output_example.gif" will be created from the specified segment.
echo.
set /p gifvid="Enter the video file name (with extension): "
set /p gifstart="Enter the start time (format HH:MM:SS): "
set /p gifduration="Enter the duration in seconds: "

ffmpeg -i "%gifvid%" -ss %gifstart% -t %gifduration% -vf "fps=10,scale=320:-1:flags=lanczos" -progress "progress.txt" -nostats -c:v gif "output_%gifvid%.gif"
call :show_progress

echo GIF created: output_%gifvid%.gif
pause
goto menu




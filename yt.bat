REM Description: Download YouTube videos and audios using yt-dlp
REM Author: Akash Meshram (akashmeshram.com)
REM Version: 1.0


@ECHO OFF
SETLOCAL ENABLEDELAYEDEXPANSION

REM Prompt the user to choose between downloading a video or audio file
ECHO Choose an option (default: video):
ECHO 1. Video 
ECHO 2. Audio
ECHO 3. Music (with square thumbnail)
SET /P "OPTION=Enter the option number (1/2/3): "

REM Check if a YouTube URL is provided as an argument
IF "%~1"=="" GOTO HELP


REM Define variables for the yt-dlp command options
SET "METADATA_OPTIONS=--parse-metadata "description:(?s)(?P<meta_comment>.+)" --parse-metadata "description:(?s)(?P<meta_year>\b\d{4}\b)" --parse-metadata "description:(?s)(?P<meta_date>\d{4}-\d{2}-\d{2})" --embed-metadata"
SET "THUMBNAIL_OPTIONS=--embed-thumbnail --convert-thumbnails jpg "
SET "SUBTITLE_OPTIONS=--sub-lang en.* --embed-subs"
SET "SQUARE_THUMBNAIL_OPTIONS=--ppa "ffmpeg: -c:v mjpeg -vf crop=\"'if(gt(ih,iw),iw,ih)':'if(gt(iw,ih),ih,iw)'\"""
SET "OTHER_OPTIONS=--ignore-errors --no-check-certificate"

REM Define variables for the format options
SET "VIDEO_FORMAT_OPTIONS=-f "bv+ba" --audio-multistreams"
SET "AUDIO_FORMAT_OPTIONS=-f 251/bestaudio"
SET "MUSIC_FORMAT_OPTIONS=--xattrs -x --audio-format mp3 -f 251/bestaudio"

REM Define file name format for the output file
SET "FILE_NAME_FORMAT=-o %%(title)s [%%(id)s].%%(ext)s"
SET "MUSIC_FILE_NAME_FORMAT=-o %%(title)s.%%(ext)s"


REM If a YouTube URL is provided, execute the main process based on the user's choice
SET "OPTION_TYPE=VIDEO"
IF "%OPTION%"=="1" GOTO DOWNLOAD_VIDEO
IF "%OPTION%"=="2" GOTO DOWNLOAD_AUDIO
IF "%OPTION%"=="3" GOTO DOWNLOAD_MUSIC

SET "OPTION=1"
ECHO.
ECHO No valid option selected. Downloading video by default
GOTO DOWNLOAD_VIDEO


REM Function to execute yt-dlp command with the given arguments
:EXECUTE_YT-DLP
SET "YT-DLP_CMD=yt-dlp %ARGS%"
ECHO.
ECHO Downloading %OPTION_TYPE% file...
ECHO Executing: !YT-DLP_CMD!
ECHO.
!YT-DLP_CMD!
GOTO :EOF

REM Main process to download a video file
:DOWNLOAD_VIDEO
SET "OPTION_TYPE=VIDEO"
SET "ARGS=%METADATA_OPTIONS% %THUMBNAIL_OPTIONS% %SUBTITLE_OPTIONS% %OTHER_OPTIONS% %VIDEO_FORMAT_OPTIONS% %*"
CALL :EXECUTE_YT-DLP
GOTO END

REM Main process to download an audio file
:DOWNLOAD_AUDIO
SET "OPTION_TYPE=AUDIO"
SET "ARGS=%METADATA_OPTIONS% %THUMBNAIL_OPTIONS% %OTHER_OPTIONS% %AUDIO_FORMAT_OPTIONS% %*"
CALL :EXECUTE_YT-DLP
GOTO END

REM Main process to download a music file
:DOWNLOAD_MUSIC
SET "OPTION_TYPE=MUSIC"
SET "ARGS=%METADATA_OPTIONS% %THUMBNAIL_OPTIONS% %OTHER_OPTIONS% %SQUARE_THUMBNAIL_OPTIONS% %MUSIC_FORMAT_OPTIONS% %MUSIC_FILE_NAME_FORMAT% %*"
CALL :EXECUTE_YT-DLP
GOTO END

REM Help section to display usage when no YouTube URL is provided
:HELP
ECHO Usage: %~0 <YouTube-URL>
GOTO END

REM End of the batch file
:END

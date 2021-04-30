@ECHO OFF
IF "%~1"=="" GOTO HELP
GOTO EXEC

:EXEC
youtube-dl.exe -i --no-check-certificate -o ""%%(playlist)s/%%(playlist_index)s-%%(title)s.%%(ext)s"" --write-sub --sub-lang en --embed-subs --embed-thumbnail --add-metadata --merge-output-format mp4 --format bestvideo[ext=mp4]+bestaudio[ext=m4a] %*
GOTO END

:HELP
ECHO %~0 ^<YouTube-URL^>
GOTO END

:END
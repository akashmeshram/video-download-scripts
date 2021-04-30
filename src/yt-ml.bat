@ECHO OFF
IF "%~1"=="" GOTO HELP
GOTO EXEC

:EXEC
youtube-dl.exe -i --format bestaudio[ext=m4a] --no-check-certificate -o ""%%(playlist)s/%%(playlist_index)s-%%(title)s.%%(ext)s"" --embed-thumbnail --add-metadata --xattrs %*
GOTO END

:HELP
ECHO %~0 ^<YouTube-URL^>
GOTO END

:END
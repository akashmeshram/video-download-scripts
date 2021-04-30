@ECHO OFF
IF "%~1"=="" GOTO HELP
GOTO EXEC

:EXEC
youtube-dl.exe --format bestaudio[ext=m4a] --no-check-certificate --embed-thumbnail --add-metadata --xattrs  --no-playlist %*
GOTO END

:HELP
ECHO %~0 ^<YouTube-URL^>
GOTO END

:END
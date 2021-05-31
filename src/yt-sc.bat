@ECHO OFF
IF "%~1"=="" GOTO HELP
GOTO EXEC

:EXEC
youtube-dl.exe -x --audio-format m4a --no-check-certificate --embed-thumbnail --add-metadata --xattrs  --no-playlist %*
GOTO END

:HELP
ECHO %~0 ^<SoundCloud-URL^>
GOTO END

:END
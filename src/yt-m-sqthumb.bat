@ECHO OFF
IF "%~1"=="" GOTO HELP
GOTO EXEC

:EXEC
youtube-dl.exe --format bestaudio[ext=m4a] --no-check-certificate --embed-thumbnail --add-metadata --xattrs  --no-playlist --postprocessor-args "-vf crop=\'if(gt(ih,iw),iw,ih)':'if(gt(iw,ih),ih,iw)\'" %*
GOTO END

:HELP
ECHO %~0 ^<YouTube-URL^>
GOTO END

:END
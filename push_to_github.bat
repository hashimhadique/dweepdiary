@echo off
title Dweep Diary - Push to GitHub
color 0A
cls

set GIT="C:\Users\hp\AppData\Local\GitHubDesktop\app-3.6.10\resources\app\git\cmd\git.exe"
set REPO="C:\Users\hp\Downloads\dweepdiary"

echo.
echo  ================================================================
echo   DWEEP DIARY  -  Push to GitHub
echo  ================================================================
echo.

cd /d %REPO%

echo  Changed files:
%GIT% status --short
echo.

set /p MSG="Commit message (Enter = 'Update'): "
if "%MSG%"=="" set MSG=Update

%GIT% add .
%GIT% commit -m "%MSG%"
%GIT% push origin main

if %errorlevel% == 0 (
    echo.
    echo  ================================================================
    echo   SUCCESS! Pushed to GitHub!
    echo   Check: https://github.com/hashimhadique/dweepdiary/actions
    echo  ================================================================
) else (
    echo.
    echo  Push failed.
)

echo.
pause

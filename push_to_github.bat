@echo off
title Dweep Diary - Push to GitHub
color 0B
cls

set GIT="C:\Users\hp\AppData\Local\GitHubDesktop\app-3.6.10\resources\app\git\cmd\git.exe"
set REPO="C:\Users\hp\Downloads\dweepdiary"

echo.
echo  🌊 DWEEP DIARY - Push to GitHub
echo  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo.

cd /d %REPO%

echo  📋 Changed Files:
%GIT% status --short
echo.

:: Get commit message from user
set /p MSG="📝 Commit message (or press Enter for 'Update'): "
if "%MSG%"=="" set MSG=Update

%GIT% add .
%GIT% commit -m "%MSG%"
%GIT% push origin main

if %errorlevel% == 0 (
    echo.
    echo  ✅ Successfully pushed to GitHub!
    echo  🔗 Check: https://github.com/
) else (
    echo.
    echo  ⚠️  Something went wrong. Check internet connection.
)

echo.
pause

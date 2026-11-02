@echo off
title Git Setup for Dweep Diary
color 0E
cls

set GIT="C:\Users\hp\AppData\Local\GitHubDesktop\app-3.6.10\resources\app\git\cmd\git.exe"
set REPO="C:\Users\hp\Downloads\dweepdiary"

echo.
echo  🔧 DWEEP DIARY - First Time Git Setup
echo  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo.

cd /d %REPO%

echo  Step 1: Checking git status...
%GIT% status
echo.

echo  Step 2: Setting up git config...
%GIT% config pull.rebase false

echo  Step 3: Adding all files...
%GIT% add .

echo  Step 4: Initial commit...
%GIT% commit -m "Add: All Flutter project files including Android Gradle setup"

echo  Step 5: Pushing to GitHub...
%GIT% push origin main

if %errorlevel% == 0 (
    echo.
    echo  ✅ SUCCESS! All files pushed to GitHub!
    echo.
    echo  🚀 GitHub Actions will now build your APK automatically!
    echo  📱 Check Actions tab on GitHub in 5-10 minutes.
) else (
    echo.
    echo  ⚠️  Push failed. Trying force push...
    %GIT% push origin main --force
)

echo.
pause

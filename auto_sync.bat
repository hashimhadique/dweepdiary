@echo off
title Dweep Diary - GitHub Auto Sync
color 0A
cls

echo.
echo  ╔══════════════════════════════════════════╗
echo  ║   🌊  DWEEP DIARY  -  AUTO SYNC         ║
echo  ║   Local Changes → GitHub (Automatic)    ║
echo  ╚══════════════════════════════════════════╝
echo.

:: Git path (GitHub Desktop bundled git)
set GIT="C:\Users\hp\AppData\Local\GitHubDesktop\app-3.6.10\resources\app\git\cmd\git.exe"
set REPO="C:\Users\hp\Downloads\dweepdiary"

:: Check if git exists
if not exist %GIT% (
    echo  ❌ ERROR: Git not found!
    echo  Please install GitHub Desktop.
    pause
    exit /b 1
)

echo  📁 Project: C:\Users\hp\Downloads\dweepdiary
echo  🔗 Syncing to: GitHub
echo  ⏱️  Auto-checking every 30 seconds...
echo.
echo  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo  Press Ctrl+C to stop auto-sync
echo  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo.

cd /d %REPO%

:LOOP
    :: Get current time
    set TIMESTAMP=%date% %time%
    
    :: Check for changes
    for /f %%i in ('%GIT% status --porcelain') do set CHANGES=%%i
    
    if defined CHANGES (
        echo  [%TIMESTAMP%] 📝 Changes detected! Syncing...
        
        :: Add all changes
        %GIT% add .
        
        :: Commit with timestamp
        %GIT% commit -m "Auto update: %TIMESTAMP%"
        
        :: Push to GitHub
        %GIT% push origin main
        
        if %errorlevel% == 0 (
            echo  [%TIMESTAMP%] ✅ Successfully pushed to GitHub!
        ) else (
            echo  [%TIMESTAMP%] ⚠️  Push failed. Check internet connection.
        )
        
        set CHANGES=
    ) else (
        echo  [%TIMESTAMP%] ✓ No changes. Watching...
    )
    
    :: Wait 30 seconds before checking again
    timeout /t 30 /nobreak >nul
    
goto LOOP

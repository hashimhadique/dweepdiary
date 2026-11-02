@echo off
title Dweep Diary - Auto Sync
color 0A
cls

set GIT="C:\Users\hp\AppData\Local\GitHubDesktop\app-3.6.10\resources\app\git\cmd\git.exe"
set REPO="C:\Users\hp\Downloads\dweepdiary"

echo.
echo  ================================================================
echo   DWEEP DIARY  -  AUTO SYNC (Every 60 seconds)
echo   Press Ctrl+C to stop
echo  ================================================================
echo.

cd /d %REPO%

:LOOP
    set CHANGES=
    for /f %%i in ('%GIT% status --porcelain') do set CHANGES=1

    if defined CHANGES (
        echo  [%TIME%] Changes found! Pushing to GitHub...
        %GIT% add .
        %GIT% commit -m "Auto update: %DATE% %TIME%"
        %GIT% push origin main
        if %errorlevel% == 0 (
            echo  [%TIME%] Pushed successfully!
        ) else (
            echo  [%TIME%] Push failed.
        )
    ) else (
        echo  [%TIME%] No changes. Watching...
    )

    timeout /t 60 /nobreak >nul
goto LOOP

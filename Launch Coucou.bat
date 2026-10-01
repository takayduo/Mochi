@echo off
title Coucou Creator Companion
cd /d "%~dp0"
echo Cleaning up any old background instances...
taskkill /F /IM electron.exe 2>nul
timeout /t 1 /nobreak >nul
echo Building latest Coucou files...
call npm run build
echo Starting Coucou Creator Desktop Overlay...
npm run app

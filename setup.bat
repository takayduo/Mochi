@echo off
setlocal enabledelayedexpansion
title Mochi Setup & Launcher
cd /d "%~dp0"

echo ===================================================
echo             MOCHI INSTALLER & LAUNCHER
echo ===================================================
echo.

:: 1. Check for Node.js
where node >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    if exist "%ProgramFiles%\nodejs\node.exe" (
        set "PATH=%ProgramFiles%\nodejs;%PATH%"
    ) else if exist "%ProgramFiles(x86)%\nodejs\node.exe" (
        set "PATH=%ProgramFiles(x86)%\nodejs;%PATH%"
    ) else (
        echo [!] Node.js was not detected on your PC.
        echo [*] Installing Node.js LTS automatically for you, please wait...
        echo.
        where winget >nul 2>nul
        if !ERRORLEVEL! EQU 0 (
            winget install OpenJS.NodeJS.LTS --silent --accept-package-agreements --accept-source-agreements
        ) else (
            echo Downloading Node.js installer from nodejs.org...
            powershell -Command "Invoke-WebRequest -Uri 'https://nodejs.org/dist/v20.18.0/node-v20.18.0-x64.msi' -OutFile '%TEMP%\nodejs.msi'"
            echo Installing Node.js...
            msiexec /i "%TEMP%\nodejs.msi" /passive /norestart
        )
        set "PATH=%ProgramFiles%\nodejs;%PATH%"
    )
)

:: Verify node again
where node >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo.
    echo [ERROR] Could not automatically install Node.js.
    echo Please download and install Node.js from https://nodejs.org
    echo Then run this setup.bat file again!
    pause
    exit /b 1
)

echo [OK] Node.js is ready!
echo.

:: 2. Install dependencies if node_modules is missing
if not exist "node_modules" (
    echo [*] Installing Mochi dependencies (this only happens once)...
    call npm install
    if !ERRORLEVEL! NEQ 0 (
        echo [ERROR] npm install encountered an issue.
        pause
        exit /b 1
    )
)

:: 3. Build Mochi
echo [*] Building Mochi...
call npm run build

:: 4. Create Desktop Shortcut
powershell -Command "$wsh = New-Object -ComObject WScript.Shell; $s = $wsh.CreateShortcut([System.IO.Path]::Combine([Environment]::GetFolderPath('Desktop'), 'Mochi.lnk')); $s.TargetPath = [System.IO.Path]::Combine('%~dp0', 'Launch Coucou Silent.vbs'); $s.WorkingDirectory = '%~dp0'; if (Test-Path '%~dp0public\icons\icon.ico') { $s.IconLocation = '%~dp0public\icons\icon.ico,0' }; $s.Save()" >nul 2>nul

echo.
echo ===================================================
echo   [SUCCESS] Mochi is installed and ready!
echo   A desktop shortcut 'Mochi' has been created.
echo ===================================================
echo.
echo Starting Mochi now...
start "" "Launch Coucou Silent.vbs"
timeout /t 3 /nobreak >nul
exit

# 🍡 Mochi — 1-Click Automated Installer for Any Windows PC
$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "===================================================" -ForegroundColor Magenta
Write-Host "         🍡 MOCHI 1-CLICK INSTALLER FOR WINDOWS     " -ForegroundColor Cyan
Write-Host "===================================================" -ForegroundColor Magenta
Write-Host ""

# 1. Check & Install Node.js if missing
Write-Host "[1/5] Checking Node.js environment..." -ForegroundColor Yellow

$nodeCmd = Get-Command node -ErrorAction SilentlyContinue
if (-not $nodeCmd) {
    if (Test-Path "$env:ProgramFiles\nodejs\node.exe") {
        $env:Path = "$env:ProgramFiles\nodejs;" + $env:Path
        $nodeCmd = Get-Command node -ErrorAction SilentlyContinue
    } elseif (Test-Path "${env:ProgramFiles(x86)}\nodejs\node.exe") {
        $env:Path = "${env:ProgramFiles(x86)}\nodejs;" + $env:Path
        $nodeCmd = Get-Command node -ErrorAction SilentlyContinue
    }
}

if (-not $nodeCmd) {
    Write-Host "      Node.js not detected. Installing Node.js LTS automatically..." -ForegroundColor Cyan
    $wingetCmd = Get-Command winget -ErrorAction SilentlyContinue
    if ($wingetCmd) {
        Write-Host "      Using Windows Package Manager (winget)..." -ForegroundColor Gray
        Start-Process winget -ArgumentList "install OpenJS.NodeJS.LTS --silent --accept-package-agreements --accept-source-agreements" -Wait
    } else {
        $msiUrl = "https://nodejs.org/dist/v20.18.0/node-v20.18.0-x64.msi"
        $msiDest = "$env:TEMP\nodejs_lts.msi"
        Write-Host "      Downloading Node.js installer from nodejs.org..." -ForegroundColor Gray
        Invoke-WebRequest -Uri $msiUrl -OutFile $msiDest
        Write-Host "      Running installer..." -ForegroundColor Gray
        Start-Process msiexec.exe -ArgumentList "/i `"$msiDest`" /passive /norestart" -Wait
    }
    $env:Path = "$env:ProgramFiles\nodejs;$env:APPDATA\npm;" + $env:Path
}

Write-Host "      ✓ Node.js is ready: $(node -v)" -ForegroundColor Green

# 2. Download Mochi from GitHub
Write-Host "[2/5] Downloading Mochi from GitHub..." -ForegroundColor Yellow
$installFolder = "$env:USERPROFILE\Mochi"
if (-not (Test-Path $installFolder)) {
    New-Item -ItemType Directory -Path $installFolder -Force | Out-Null
}

$zipUrl = "https://github.com/takayduo/Mochi/archive/refs/heads/main.zip"
$zipFile = "$env:TEMP\Mochi_Latest.zip"
$extractTemp = "$env:TEMP\Mochi_Extract"

Invoke-WebRequest -Uri $zipUrl -OutFile $zipFile

if (Test-Path $extractTemp) {
    Remove-Item -Recurse -Force $extractTemp
}
Expand-Archive -Path $zipFile -DestinationPath $extractTemp -Force

# Copy files into target folder
Copy-Item -Path "$extractTemp\Mochi-main\*" -Destination $installFolder -Recurse -Force
Remove-Item -Recurse -Force $zipFile, $extractTemp

Write-Host "      ✓ Downloaded into $installFolder" -ForegroundColor Green

# 3. Install NPM Dependencies
Write-Host "[3/5] Installing packages (npm install)..." -ForegroundColor Yellow
Set-Location -Path $installFolder

# Execute npm install via cmd to ensure smooth PATH pickup
cmd /c "npm install"

# 4. Build Mochi
Write-Host "[4/5] Building application bundle..." -ForegroundColor Yellow
cmd /c "npm run build"

# 5. Create Desktop Shortcut
Write-Host "[5/5] Creating Desktop Shortcut..." -ForegroundColor Yellow
$desktopPath = [System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::Desktop)
$shortcutPath = Join-Path $desktopPath "Mochi.lnk"

$wsh = New-Object -ComObject WScript.Shell
$shortcut = $wsh.CreateShortcut($shortcutPath)
$shortcut.TargetPath = Join-Path $installFolder "Launch Coucou Silent.vbs"
$shortcut.WorkingDirectory = $installFolder
$iconFile = Join-Path $installFolder "public\icons\icon.ico"
if (Test-Path $iconFile) {
    $shortcut.IconLocation = "$iconFile,0"
}
$shortcut.Description = "Mochi — Creator Desktop Companion"
$shortcut.Save()

Write-Host "      ✓ Desktop shortcut created: $shortcutPath" -ForegroundColor Green

Write-Host ""
Write-Host "===================================================" -ForegroundColor Green
Write-Host "   🎉 SUCCESS: Mochi is installed and ready to use! " -ForegroundColor Green
Write-Host "===================================================" -ForegroundColor Green
Write-Host ""
Write-Host "Launching Mochi now..." -ForegroundColor Cyan

Start-Process "wscript.exe" -ArgumentList "`"$installFolder\Launch Coucou Silent.vbs`""

# ==============================
# CODE MODE - Windows v1
# ==============================

# Resolve directories
$MODE_DIR  = Split-Path -Parent $MyInvocation.MyCommand.Definition
$ROOT_DIR  = Split-Path -Parent $MODE_DIR
$STATE_DIR = Join-Path $ROOT_DIR "state"

if (!(Test-Path $STATE_DIR)) {
    New-Item -ItemType Directory -Path $STATE_DIR | Out-Null
}

$PID_FILE  = Join-Path $STATE_DIR "watchdog.pid"
$MODE_FILE = Join-Path $STATE_DIR "current_mode.txt"

# ==============================
# Application Paths
# ==============================

$BRAVE_PATH    = "C:\Program Files\BraveSoftware\Brave-Browser\Application\brave.exe"
$OBSIDIAN_PATH = "C:\Users\anike\AppData\Local\Programs\Obsidian\Obsidian.exe"
$VSCODE_PATH   = "C:\Users\anike\AppData\Local\Programs\Microsoft VS Code\Code.exe"
$VAULT_PATH    = "C:\Users\anike\Documents\Acadence"

# ==============================
# Kill Existing Watchdog
# ==============================

if (Test-Path $PID_FILE) {
    $oldPid = Get-Content $PID_FILE
    Stop-Process -Id $oldPid -Force -ErrorAction SilentlyContinue
    Remove-Item $PID_FILE -Force
}

# ==============================
# Set Mode
# ==============================

"CODE" | Out-File $MODE_FILE -Force

# ==============================
# Blocked Applications
# ==============================

$blockedApps = @("firefox","Discord","Telegram","Spotify")

foreach ($app in $blockedApps) {
    Get-Process -Name $app -ErrorAction SilentlyContinue | Stop-Process -Force
}

# Strict reset of productive apps
Get-Process -Name "Obsidian" -ErrorAction SilentlyContinue | Stop-Process -Force
Get-Process -Name "Code" -ErrorAction SilentlyContinue | Stop-Process -Force

# ==============================
# Launch Productive Apps
# ==============================

Start-Process $BRAVE_PATH "--profile-directory=Default"
Start-Process $OBSIDIAN_PATH "`"$VAULT_PATH`""
Start-Process $VSCODE_PATH

# ==============================
# Watchdog (Detached Hidden Process)
# ==============================

$watchdogScript = {
    $apps = @("firefox","Discord","Telegram","Spotify")
    while ($true) {
        foreach ($app in $apps) {
            Get-Process -Name $app -ErrorAction SilentlyContinue | Stop-Process -Force
        }
        Start-Sleep -Seconds 3
    }
}

$process = Start-Process powershell `
    -ArgumentList "-NoProfile -Command & {$watchdogScript}" `
    -WindowStyle Hidden `
    -PassThru

$process.Id | Out-File $PID_FILE -Force

# Auto-close
exit
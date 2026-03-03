# ==============================
# EXIT MODE - Windows v1
# ==============================

# Resolve directories
$MODE_DIR  = Split-Path -Parent $MyInvocation.MyCommand.Definition
$ROOT_DIR  = Split-Path -Parent $MODE_DIR
$STATE_DIR = Join-Path $ROOT_DIR "state"

$PID_FILE  = Join-Path $STATE_DIR "watchdog.pid"
$MODE_FILE = Join-Path $STATE_DIR "current_mode.txt"

# ==============================
# Password Protection
# ==============================

$password = Read-Host "Enter exit password"

if ($password -ne "hakunamatata") {
    Write-Host "Wrong password. Exit denied."
    Start-Sleep -Seconds 2
    exit
}

# ==============================
# Stop Watchdog Process
# ==============================

if (Test-Path $PID_FILE) {
    try {
        $pid = Get-Content $PID_FILE
        if ($pid) {
            Stop-Process -Id $pid -Force -ErrorAction SilentlyContinue
        }
        Remove-Item $PID_FILE -Force -ErrorAction SilentlyContinue
    }
    catch {
        # Silent fail (stability > noise)
    }
}

# ==============================
# Clear Mode State
# ==============================

if (Test-Path $MODE_FILE) {
    Remove-Item $MODE_FILE -Force -ErrorAction SilentlyContinue
}

Write-Host "Exited successfully."

Start-Sleep -Seconds 1
exit
# Starts the Odysseus web UI on http://localhost:7000
# (Assumes deps are already installed by the first-run setup.)
$ErrorActionPreference = "Stop"
$odys = Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) "odysseus"
Set-Location $odys
$env:PYTHONUTF8 = "1"
$env:PYTHONIOENCODING = "utf-8"
Write-Host "Starting Odysseus at http://localhost:7000 (Ctrl+C to stop)" -ForegroundColor Cyan
& ".\venv\Scripts\python.exe" -m uvicorn app:app --host 127.0.0.1 --port 7000

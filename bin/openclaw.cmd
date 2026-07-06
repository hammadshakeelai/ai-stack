@echo off
setlocal EnableExtensions
rem  openclaw wrapper (cmd): bare "openclaw" opens the TUI, starting the gateway if needed.
rem  "openclaw <args>" forwards straight to the real npm CLI so every subcommand still works.
rem  Put this bin\ folder BEFORE %APPDATA%\npm in your PATH so the wrapper wins.
if defined OPENCLAW_REAL (set "OC_REAL=%OPENCLAW_REAL%") else (set "OC_REAL=%APPDATA%\npm\openclaw.cmd")

if "%~1"=="" goto :tui
call "%OC_REAL%" %*
exit /b %errorlevel%

:tui
powershell -NoProfile -ExecutionPolicy Bypass -Command "if(-not(Get-NetTCPConnection -LocalPort 18789 -State Listen -ErrorAction SilentlyContinue)){Write-Host 'Starting OpenClaw gateway...';$null = & '%OC_REAL%' gateway start;for($i=0;$i -lt 30;$i++){if(Get-NetTCPConnection -LocalPort 18789 -State Listen -ErrorAction SilentlyContinue){break};Start-Sleep -Milliseconds 1000}}"
call "%OC_REAL%" tui
exit /b %errorlevel%

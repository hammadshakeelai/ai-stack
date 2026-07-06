# Starts the whole AI stack and opens Odysseus in your browser.
#   1. LiteLLM gateway (port 4000)  — Groq -> Gemini -> OpenRouter fallback
#   2. Odysseus web UI (port 7000)
# Each server runs in its own minimized window. Close that window to stop it.
$ErrorActionPreference = "SilentlyContinue"
$root = Split-Path -Parent $MyInvocation.MyCommand.Path

function Test-Port($p) {
    [bool](Get-NetTCPConnection -LocalPort $p -State Listen -ErrorAction SilentlyContinue)
}

if (-not (Test-Port 4000)) {
    Start-Process powershell -WindowStyle Minimized -ArgumentList @(
        '-ExecutionPolicy','Bypass','-File',"$root\gateway\start-gateway.ps1")
}
if (-not (Test-Port 7000)) {
    Start-Process powershell -WindowStyle Minimized -ArgumentList @(
        '-ExecutionPolicy','Bypass','-File',"$root\start-odysseus.ps1")
}

# Wait (up to ~75s) for Odysseus to accept connections, then open the browser.
for ($i = 0; $i -lt 75; $i++) { if (Test-Port 7000) { break }; Start-Sleep -Seconds 1 }
Start-Sleep -Seconds 1
Start-Process "http://localhost:7000"

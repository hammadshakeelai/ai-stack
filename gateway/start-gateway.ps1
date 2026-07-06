# Starts the LiteLLM fallback gateway on http://localhost:4000
# Loads keys from .env, activates the venv, and runs the proxy.

$ErrorActionPreference = "Stop"
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $here

# Force UTF-8 so LiteLLM's banner/log output doesn't crash on Windows cp1252.
$env:PYTHONUTF8 = "1"
$env:PYTHONIOENCODING = "utf-8"

# --- Load .env into the process environment ---
Get-Content ".\.env" | ForEach-Object {
    $line = $_.Trim()
    if ($line -and -not $line.StartsWith("#") -and $line.Contains("=")) {
        $idx = $line.IndexOf("=")
        $name = $line.Substring(0, $idx).Trim()
        $val  = $line.Substring($idx + 1).Trim()
        Set-Item -Path "Env:$name" -Value $val
    }
}

Write-Host "Starting LiteLLM gateway on http://localhost:4000 ..." -ForegroundColor Cyan
Write-Host "Model 'auto' -> Groq, fallback Gemini -> OpenRouter" -ForegroundColor DarkGray

& ".\venv\Scripts\litellm.exe" --config ".\config.yaml" --port 4000

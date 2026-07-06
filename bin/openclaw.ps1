# openclaw wrapper (PowerShell): bare "openclaw" opens the TUI, starting the gateway if needed.
# "openclaw <args>" forwards straight to the real npm CLI so every subcommand still works.
# Put this bin\ folder BEFORE $env:APPDATA\npm in your PATH so the wrapper wins.
$ErrorActionPreference = 'SilentlyContinue'
$real = if ($env:OPENCLAW_REAL) { $env:OPENCLAW_REAL } else { Join-Path $env:APPDATA 'npm\openclaw.cmd' }

if ($args.Count -gt 0) {
    & $real @args
    exit $LASTEXITCODE
}

if (-not (Get-NetTCPConnection -LocalPort 18789 -State Listen)) {
    Write-Host 'Starting OpenClaw gateway...'
    $null = & $real gateway start
    for ($i = 0; $i -lt 30; $i++) {
        if (Get-NetTCPConnection -LocalPort 18789 -State Listen) { break }
        Start-Sleep -Milliseconds 1000
    }
}

& $real tui
exit $LASTEXITCODE

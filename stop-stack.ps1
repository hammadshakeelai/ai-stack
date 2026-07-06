# Stops the AI stack: gateway (port 4000) and Odysseus (port 7000).
foreach ($p in 4000, 7000) {
    try {
        (Get-NetTCPConnection -LocalPort $p -State Listen -ErrorAction Stop).OwningProcess |
            Select-Object -Unique | ForEach-Object { Stop-Process -Id $_ -Force -ErrorAction SilentlyContinue }
        Write-Host "stopped port $p" -ForegroundColor Yellow
    } catch { Write-Host "nothing running on port $p" -ForegroundColor DarkGray }
}

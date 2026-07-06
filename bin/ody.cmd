@echo off
rem  "ody" — launch the AI stack (gateway + Odysseus) and open the browser.
rem  Add this bin\ folder to your PATH (or make a Win+R App Paths entry) to run it from anywhere.
start "" /min powershell -ExecutionPolicy Bypass -WindowStyle Hidden -File "%~dp0..\start-stack.ps1"

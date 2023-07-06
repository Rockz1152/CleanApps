@echo off
Powershell.exe -NoProfile -Command "&{Start-Process Powershell.exe -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File \"%~dp0CleanApps.ps1\"'}"
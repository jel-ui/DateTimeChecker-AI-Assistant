@echo off
title Unit Testing - Date Time Checker
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0..\scripts\test.ps1"
echo.
echo Nhan phim bat ky de dong cua so unit testing.
pause > nul

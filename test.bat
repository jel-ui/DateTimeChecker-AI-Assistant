@echo off
title Date Time Checker Java - Automated Tests
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\test.ps1"
echo.
echo Nhan phim bat ky de dong cua so test.
pause > nul

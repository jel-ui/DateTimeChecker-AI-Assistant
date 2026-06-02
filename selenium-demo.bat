@echo off
title Date Time Checker Java - Selenium Visible Demo
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\selenium-demo.ps1"
if errorlevel 1 (
  echo.
  echo Selenium demo gap loi. Vui long xem thong bao o tren.
)
echo.
echo Nhan phim bat ky de dong cua so demo.
pause > nul

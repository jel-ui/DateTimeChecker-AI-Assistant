@echo off
title Date Time Checker Java
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\run.ps1"
if errorlevel 1 (
  echo.
  echo Khong the khoi dong ung dung. Vui long xem thong bao loi o tren.
  pause
)

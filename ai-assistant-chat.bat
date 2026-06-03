@echo off
chcp 65001 > nul
title Date Time Checker - Gemini AI Testing Assistant Chat
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\ai-assistant-chat.ps1"
if errorlevel 1 (
  echo.
  echo Gemini AI Assistant gap loi. Vui long xem thong bao o tren.
)
echo.
echo Nhan phim bat ky de dong cua so chat.
pause > nul

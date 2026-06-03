@echo off
chcp 65001 > nul
title Date Time Checker - Offline Sample AI Testing Chat
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0scripts\ai-assistant-chat.ps1" -OfflineSample
echo.
echo Nhan phim bat ky de dong cua so chat.
pause > nul

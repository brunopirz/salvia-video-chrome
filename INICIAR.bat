@echo off
chcp 65001 >nul
title Lugnis Clone Voice
cd /d "%~dp0"
set "PATH=%~dp0ffmpeg;%PATH%"
set PYTHONUTF8=1

if not exist .venv\Scripts\python.exe (
    echo Rode o INSTALAR.bat primeiro!
    pause
    exit /b 1
)

.venv\Scripts\python -c "import torch" >nul 2>&1
if errorlevel 1 (
    echo A instalacao esta incompleta. Rode o INSTALAR.bat de novo!
    pause
    exit /b 1
)

.venv\Scripts\python run.py
pause

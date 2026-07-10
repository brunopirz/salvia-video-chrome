@echo off
chcp 65001 >nul
title Lugnis Clone Voice - Instalador
cd /d "%~dp0"

echo ============================================
echo    Lugnis Clone Voice - Instalacao (Windows)
echo ============================================
echo.

set "PYEXE="
set "PYDIR_USER=%LocalAppData%\Programs\Python\Python312"
set "PYDIR_ALL=C:\Program Files\Python312"

rem ================= [1/5] Python 3.12 =================
call :achar_python
if defined PYEXE goto python_ok

echo [1/5] Python 3.12 nao encontrado. Baixando... aguarde, ~25 MB
%SystemRoot%\System32\curl.exe -L --retry 3 -o "%TEMP%\python-3.12.10-amd64.exe" https://www.python.org/ftp/python/3.12.10/python-3.12.10-amd64.exe
if errorlevel 1 goto erro_download_python

echo       Instalando Python 3.12 automaticamente... 1 a 2 minutos
start /wait "" "%TEMP%\python-3.12.10-amd64.exe" /quiet InstallAllUsers=0 PrependPath=1 Include_launcher=1
del "%TEMP%\python-3.12.10-amd64.exe" >nul 2>&1

call :achar_python
if not defined PYEXE goto erro_python

:python_ok
echo [1/5] Python 3.12 encontrado: %PYEXE%

rem ================= [2/5] Ambiente virtual =================
echo [2/5] Criando ambiente Python...
if not exist .venv\Scripts\python.exe goto criar_venv
.venv\Scripts\python.exe -c "import sys; raise SystemExit(0 if sys.version_info[:2]==(3,12) else 1)" >nul 2>&1
if not errorlevel 1 goto venv_ok
echo       Ambiente antigo incompativel encontrado. Recriando do zero...
rmdir /s /q .venv

:criar_venv
"%PYEXE%" -m venv .venv
if not exist .venv\Scripts\python.exe goto erro_venv

:venv_ok
.venv\Scripts\python -m pip install -q -U pip
if errorlevel 1 goto erro_pip

rem ================= [3/5] PyTorch =================
set GPU=cpu
nvidia-smi -L >nul 2>&1 && set GPU=cuda
if "%GPU%"=="cuda" goto torch_cuda

echo [3/5] Sem placa NVIDIA. Instalando PyTorch para CPU... funciona, so e mais lento
.venv\Scripts\python -m pip install torch==2.6.0 torchaudio==2.6.0
goto torch_check

:torch_cuda
echo [3/5] Placa NVIDIA detectada! Instalando PyTorch com CUDA... download grande, aguarde
.venv\Scripts\python -m pip install torch==2.6.0 torchaudio==2.6.0 --index-url https://download.pytorch.org/whl/cu124

:torch_check
if errorlevel 1 goto erro_pip

rem ================= [4/5] Motor de voz =================
echo [4/5] Instalando o motor de voz... pode demorar alguns minutos
.venv\Scripts\python -m pip install chatterbox-tts fastapi "uvicorn[standard]" python-multipart "setuptools<81"
if errorlevel 1 goto erro_pip

rem ================= [5/5] ffmpeg =================
echo [5/5] Verificando ffmpeg...
where ffmpeg >nul 2>&1
if not errorlevel 1 goto ffmpeg_ok
if exist ffmpeg\ffmpeg.exe goto ffmpeg_ok

echo       Baixando ffmpeg... ~90 MB
%SystemRoot%\System32\curl.exe -L --retry 3 -o "%TEMP%\ffmpeg-elton.zip" https://www.gyan.dev/ffmpeg/builds/ffmpeg-release-essentials.zip
if errorlevel 1 goto erro_ffmpeg
rmdir /s /q "%TEMP%\ffmpeg-elton" >nul 2>&1
mkdir "%TEMP%\ffmpeg-elton"
%SystemRoot%\System32\tar.exe -xf "%TEMP%\ffmpeg-elton.zip" -C "%TEMP%\ffmpeg-elton"
if not exist ffmpeg mkdir ffmpeg
for /r "%TEMP%\ffmpeg-elton" %%f in (ffmpeg.exe) do copy /y "%%f" ffmpeg\ >nul
del "%TEMP%\ffmpeg-elton.zip" >nul 2>&1
rmdir /s /q "%TEMP%\ffmpeg-elton" >nul 2>&1
if not exist ffmpeg\ffmpeg.exe goto erro_ffmpeg

:ffmpeg_ok
echo       ffmpeg OK

rem ================= Verificacao final =================
echo.
echo Verificando a instalacao... aguarde
.venv\Scripts\python -c "import torch, chatterbox; print('       PyTorch', torch.__version__, '+ motor de voz: OK')"
if errorlevel 1 goto erro_verificacao

echo.
echo ============================================
echo  [OK] Instalacao concluida e verificada!
echo  Use o INICIAR.bat para abrir o programa.
echo  O primeiro uso baixa o modelo de voz (3 GB).
echo ============================================
pause
exit /b 0

rem ================= Subrotina =================
:achar_python
set "PYEXE="
for /f "delims=" %%i in ('py -3.12 -c "import sys;print(sys.executable)" 2^>nul') do set "PYEXE=%%i"
call :validar_python
if defined PYEXE goto :eof
if exist "%PYDIR_USER%\python.exe" set "PYEXE=%PYDIR_USER%\python.exe"
call :validar_python
if defined PYEXE goto :eof
if exist "%PYDIR_ALL%\python.exe" set "PYEXE=%PYDIR_ALL%\python.exe"
call :validar_python
goto :eof

rem confere se o PYEXE achado e mesmo um Python 3.12 (launcher py antigo mente no -3.12)
:validar_python
if not defined PYEXE goto :eof
"%PYEXE%" -c "import sys; raise SystemExit(0 if sys.version_info[:2]==(3,12) else 1)" >nul 2>&1
if errorlevel 1 set "PYEXE="
goto :eof

rem ================= Erros =================
:erro_download_python
echo.
echo [ERRO] Nao consegui baixar o Python. Verifique sua internet e rode de novo.
pause
exit /b 1

:erro_python
echo.
echo [ERRO] O Python 3.12 nao instalou direito.
echo Instale manualmente em https://www.python.org/downloads/release/python-31210/
echo Na instalacao, MARQUE a caixa "Add python.exe to PATH" e rode este INSTALAR.bat de novo.
start https://www.python.org/downloads/release/python-31210/
pause
exit /b 1

:erro_venv
echo.
echo [ERRO] Nao consegui criar o ambiente Python. Rode este INSTALAR.bat de novo.
pause
exit /b 1

:erro_pip
echo.
echo [ERRO] A instalacao dos pacotes falhou. Verifique sua internet e rode este INSTALAR.bat de novo.
echo Ele continua de onde parou, nao baixa tudo de novo.
pause
exit /b 1

:erro_ffmpeg
echo.
echo [ERRO] Nao consegui baixar o ffmpeg. Verifique sua internet e rode este INSTALAR.bat de novo.
pause
exit /b 1

:erro_verificacao
echo.
echo [ERRO] A instalacao terminou mas a verificacao falhou.
echo Rode este INSTALAR.bat de novo. Se o erro continuar, consulte a comunidade.
pause
exit /b 1

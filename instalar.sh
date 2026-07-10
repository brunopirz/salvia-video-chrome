#!/bin/bash
# Script de Instalação do Lugnis Clone Voice para Linux

echo "============================================"
echo "    Lugnis Clone Voice - Instalação (Linux)"
echo "============================================"
echo ""

cd "$(dirname "$0")"

# 1. Verificar Python 3.12
PYTHON_CMD="python3"
if ! command -v python3 &> /dev/null; then
    echo "[ERRO] Python 3 não está instalado."
    exit 1
fi

VERSION=$($PYTHON_CMD -c 'import sys; print(f"{sys.version_info.major}.{sys.version_info.minor}")')
if [ "$VERSION" != "3.12" ]; then
    echo "[AVISO] O motor de voz requer Python 3.12. Sua versão detectada é $VERSION."
    echo "Se você tiver múltiplos Pythons instalados, certifique-se de que 'python3' aponta para o 3.12."
fi

# 2. Criar ambiente virtual
echo "[1/4] Criando ambiente virtual (.venv)..."
if [ ! -d ".venv" ]; then
    $PYTHON_CMD -m venv .venv
    if [ $? -ne 0 ]; then
        echo "[ERRO] Não foi possível criar o ambiente virtual."
        echo "Tente instalar o pacote python3-venv da sua distribuição Linux:"
        echo "  - Ubuntu/Debian: sudo apt update && sudo apt install python3-venv python3-dev"
        exit 1
    fi
fi

# Atualizar pip
.venv/bin/pip install -q --upgrade pip

# 3. Instalar PyTorch
GPU="cpu"
if command -v nvidia-smi &> /dev/null && nvidia-smi -L &> /dev/null; then
    echo "Placa NVIDIA detectada! Instalando PyTorch com CUDA..."
    GPU="cuda"
fi

echo "[2/4] Instalando PyTorch e torchaudio..."
if [ "$GPU" = "cuda" ]; then
    .venv/bin/pip install torch==2.6.0 torchaudio==2.6.0 --index-url https://download.pytorch.org/whl/cu124
else
    echo "Sem placa NVIDIA detectada ou ativa. Instalando PyTorch para CPU (mais lento, porém menor)..."
    .venv/bin/pip install torch==2.6.0 torchaudio==2.6.0 --index-url https://download.pytorch.org/whl/cpu
fi

if [ $? -ne 0 ]; then
    echo "[ERRO] Falha ao instalar o PyTorch. Verifique sua conexão com a internet."
    exit 1
fi

# 4. Instalar motor de voz e dependências
echo "[3/4] Instalando as dependências do Lugnis Clone Voice..."
.venv/bin/pip install chatterbox-tts fastapi "uvicorn[standard]" python-multipart "setuptools<81"
if [ $? -ne 0 ]; then
    echo "[ERRO] Falha ao instalar as dependências. Verifique sua internet."
    exit 1
fi

# 5. Garantir o runtime do Pyarmor para Linux
if [ ! -f "pyarmor_runtime_000000/pyarmor_runtime.so" ]; then
    echo "[4/4] Gerando módulo de runtime do Pyarmor para Linux..."
    .venv/bin/pip install -q pyarmor
    .venv/bin/pyarmor gen runtime --platform linux.x86_64 -O temp_runtime >/dev/null 2>&1
    if [ -f "temp_runtime/pyarmor_runtime_000000/pyarmor_runtime.so" ]; then
        cp temp_runtime/pyarmor_runtime_000000/pyarmor_runtime.so pyarmor_runtime_000000/
        rm -rf temp_runtime
        echo "Módulo de runtime do Pyarmor configurado."
    else
        echo "[AVISO] Não foi possível compilar o runtime automaticamente. Tentando prosseguir..."
        rm -rf temp_runtime
    fi
else
    echo "[4/4] Módulo de runtime do Pyarmor para Linux já configurado."
fi

# Verificar ffmpeg
if ! command -v ffmpeg &> /dev/null; then
    echo ""
    echo "[AVISO] ffmpeg não foi detectado no sistema."
    echo "O ffmpeg é necessário para converter áudios e clonar vozes."
    echo "Por favor, instale-o com o gerenciador de pacotes de sua preferência:"
    echo "  - Ubuntu/Debian: sudo apt update && sudo apt install ffmpeg"
    echo "  - Fedora: sudo dnf install ffmpeg"
    echo "  - Arch Linux: sudo pacman -S ffmpeg"
    echo ""
fi

# Verificação final
echo "Verificando a instalação..."
.venv/bin/python -c "import torch, chatterbox; print('       PyTorch', torch.__version__, '+ motor de voz: OK')"
if [ $? -eq 0 ]; then
    echo ""
    echo "============================================"
    echo "  [OK] Instalação concluída com sucesso!"
    echo "  Execute './iniciar.sh' para abrir o programa."
    echo "  O primeiro uso baixa o modelo de voz (~3 GB)."
    echo "============================================"
    chmod +x iniciar.sh 2>/dev/null
else
    echo "[ERRO] A verificação da instalação falhou."
fi

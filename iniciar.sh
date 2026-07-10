#!/bin/bash
# Script para iniciar o Lugnis Clone Voice no Linux

cd "$(dirname "$0")"

if [ ! -f ".venv/bin/python" ]; then
    echo "[ERRO] Ambiente virtual não encontrado. Execute './instalar.sh' primeiro!"
    exit 1
fi

export PYTHONUTF8=1

# Verificar instalação
.venv/bin/python -c "import torch" &> /dev/null
if [ $? -ne 0 ]; then
    echo "[ERRO] A instalação está incompleta ou inválida. Rode './instalar.sh' novamente!"
    exit 1
fi

echo "Iniciando o Lugnis Clone Voice..."
.venv/bin/python run.py

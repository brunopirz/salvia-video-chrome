# Lugnis Clone Voice

100% local and free AI voice studio. Generate narration in Portuguese and clone any voice with just 10 seconds of audio.

Engine: [Chatterbox Multilingual](https://github.com/resemble-ai/chatterbox) by Resemble AI, MIT license, 23 languages. Runs on Apple Silicon GPU (MPS), NVIDIA GPU (CUDA), or fallback to CPU.

---

## English (US)

### Installation

- **Linux**: Open terminal and run `./instalar.sh`. Then start the app with `./iniciar.sh`
- **Windows**: Double-click `INSTALAR.bat` (detects NVIDIA GPU automatically). Then open with `INICIAR.bat`
- **Mac**: Double-click `INSTALAR.command`. Then open with `INICIAR.command`

*Note: Requires 8 GB RAM, 6 GB free disk space. Internet is only required on first run to download the 3 GB voice model. After that, it runs 100% offline.*

### How to Use

Start the app with the script corresponding to your OS. The browser will open at `http://127.0.0.1:8765`.

1. **Voice**: Use the default voice, upload an audio file, or record 10 to 20 seconds using your microphone.
2. **Script**: Paste your text and adjust emotion and fidelity.
3. **Generate**: Click **GERAR ÁUDIO**. The audio plays instantly and is saved in the `saidas/` folder as MP3.

### Manual Installation (First Time Only)

```bash
python3.12 -m venv .venv
.venv/bin/pip install chatterbox-tts fastapi "uvicorn[standard]" python-multipart "setuptools<81"
```

The pin `setuptools<81` is mandatory: Chatterbox's Perth watermarker uses `pkg_resources`, which was removed in newer setuptools versions.

Requirements: Python 3.12, ffmpeg, ~4 GB free space.

---

## Português (BR)

### Instalação

- **Linux**: Abra o terminal e execute `./instalar.sh`. Depois abra o programa com `./iniciar.sh`
- **Windows**: Dois cliques em `INSTALAR.bat` (detecta placa NVIDIA sozinho). Depois abra com `INICIAR.bat`
- **Mac**: Dois cliques em `INSTALAR.command`. Depois abra com `INICIAR.command`

*Mínimo: 8 GB de RAM, 6 GB de disco livre. Internet apenas no primeiro uso (baixa o modelo de 3 GB), depois roda 100% offline.*

### Como Usar

Abra o aplicativo com o script correspondente. O navegador abrirá automaticamente em `http://127.0.0.1:8765`.

1. **Voz**: Use a padrão, envie um arquivo de áudio, ou grave 10 a 20 segundos no microfone.
2. **Roteiro**: Cole o texto e ajuste a emoção e a fidelidade.
3. **Gerar**: Clique em **GERAR ÁUDIO**. O áudio toca na hora e fica salvo na pasta `saidas/` como MP3.

### Instalação Manual (Apenas na primeira vez)

```bash
python3.12 -m venv .venv
.venv/bin/pip install chatterbox-tts fastapi "uvicorn[standard]" python-multipart "setuptools<81"
```

O pin `setuptools<81` é obrigatório: o watermarker Perth do Chatterbox ainda usa `pkg_resources`, removido nas versões novas do setuptools.

Requisitos: Python 3.12, ffmpeg, ~4 GB livres.

---

## Structure / Estrutura

- `app.py`: FastAPI server + TTS engine / Servidor FastAPI + motor TTS (Pyarmor compiled/ofuscado)
- `static/index.html`: Web interface / Interface web do Lugnis Clone Voice
- `vozes/`: Library of reference voices / Biblioteca de vozes de referência (wav 24 kHz mono)
- `saidas/`: Generated audios / Áudios gerados
- `teste_motor.py`: TTS engine smoke test / Teste de fumaça do motor

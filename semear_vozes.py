# Semeia a biblioteca de vozes a partir de uma pasta de áudios
#
# Uso:
#   .venv/bin/python semear_vozes.py /caminho/da/pasta
#
# Convenção do nome do arquivo:  Nome_F.mp3  ou  Nome_M.wav  (F/M = gênero)
#   Ex: "Julia_F.mp3" vira a voz "Julia", feminina
#       "Ricardo Narrador_M.wav" vira "Ricardo Narrador", masculina
# Sem sufixo, a voz entra sem gênero definido.
#
# IMPORTANTE: use apenas áudios que você tem direito de usar
# (sua voz, vozes doadas pela comunidade com consentimento, ou material CC0).

import json
import re
import subprocess
import sys
from pathlib import Path

VOZES = Path(__file__).parent / "vozes"
VOZES.mkdir(exist_ok=True)

if len(sys.argv) < 2:
    print("Uso: semear_vozes.py /pasta/com/audios")
    sys.exit(1)

origem = Path(sys.argv[1])
audios = [f for f in origem.iterdir() if f.suffix.lower() in (".mp3", ".wav", ".m4a", ".ogg", ".webm", ".flac")]
print(f"{len(audios)} áudio(s) encontrados em {origem}")

for f in sorted(audios):
    base = f.stem
    m = re.match(r"^(.*?)[_\- ]+([FMfm])$", base)
    nome, genero = (m.group(1).strip(), m.group(2).upper()) if m else (base.strip(), "")
    nome = re.sub(r"[^\w\- ]", "", nome) or "voz"
    destino = VOZES / f"{nome}.wav"
    r = subprocess.run(
        ["ffmpeg", "-y", "-i", str(f), "-ar", "24000", "-ac", "1", "-t", "30", str(destino)],
        capture_output=True,
    )
    if r.returncode != 0:
        print(f"  ✗ {f.name}: ffmpeg falhou")
        continue
    (VOZES / f"{nome}.json").write_text(
        json.dumps({"genero": genero, "tags": [], "favorita": False}, ensure_ascii=False)
    )
    print(f"  ✓ {nome} {'(' + genero + ')' if genero else ''}")

print("\nPronto! Recarregue a página do Lugnis Clone Voice.")

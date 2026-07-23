# Deploy em Produção — Lugnis Clone Voice

Este documento descreve como esta instância está implantada em servidor (systemd, sem
Docker) para permitir replicar o setup em outro servidor. Nenhuma chave, token ou IP
real está incluído aqui — veja a seção "Segredos" para o que precisa ser gerado/configurado
manualmente em cada ambiente.

## Visão geral da arquitetura

```
Internet ──▶ Caddy (reverse proxy, TLS) ──▶ 127.0.0.1:8765 (uvicorn)
                                                    │
                                            run_server.py
                                                    │
                                    app.py (Pyarmor, motor Chatterbox TTS)
```

- O serviço roda **diretamente no host** (não em container), gerenciado por `systemd`.
- Um **Caddy** (rodando em container, na mesma máquina) faz reverse proxy de um subdomínio
  público (HTTPS) para a porta 8765 do host.
- O app em si usa o motor [Chatterbox Multilingual](https://github.com/resemble-ai/chatterbox)
  (Resemble AI) sobre PyTorch/CUDA.

## Estrutura no servidor

```
/opt/lugnis-clone-voice/
├── .venv/                  # virtualenv Python 3.12
├── .api_key                # arquivo com a API key (root:root, não versionado)
├── app.py                  # servidor FastAPI + motor TTS (compilado/ofuscado via Pyarmor)
├── run_server.py           # entrypoint real usado em produção (ver abaixo)
├── run.py                  # entrypoint simples do repo original (não usado em prod)
├── pyarmor_runtime_000000/ # runtime nativo do Pyarmor
├── vozes/                  # biblioteca de vozes de referência (.wav + .json)
├── saidas/                 # áudios gerados (não versionado)
├── static/index.html       # frontend (SPA vanilla HTML/CSS/JS)
├── API.md                  # referência da API HTTP
└── requirements via instalar.sh
```

## `run_server.py` (diferença em relação ao `run.py` do repo público)

O `run.py` padrão do repositório apenas contorna a checagem de licença embutida no
`app.py` ofuscado. Em produção usamos **`run_server.py`**, que faz o mesmo bypass de
licença e adicionalmente:

- Adiciona uma camada de **autenticação por API key** via middleware Starlette, exigindo
  o header `X-API-Key` em todas as rotas `/api/*`, `/amostra/*` e `/audio/*`.
- Lê a chave esperada de um arquivo `.api_key` no diretório do projeto (fora do
  controle de versão, permissão restrita, não deve ser commitado).
- Sobe o servidor uvicorn em `0.0.0.0:8765`.

Esse arquivo precisa ser recriado manualmente no novo servidor (ver seção "Como
replicar").

## systemd unit

Arquivo: `/etc/systemd/system/lugnis-clone-voice.service`

```ini
[Unit]
Description=Lugnis Clone Voice Server
After=network.target docker.service
Wants=docker.service

[Service]
Type=simple
User=ubuntu
Group=ubuntu
WorkingDirectory=/opt/lugnis-clone-voice
Environment=PYTHONUTF8=1
ExecStart=/opt/lugnis-clone-voice/.venv/bin/python /opt/lugnis-clone-voice/run_server.py
Restart=always
RestartSec=5
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
```

Comandos úteis:

```bash
sudo systemctl daemon-reload
sudo systemctl enable --now lugnis-clone-voice.service
sudo systemctl status lugnis-clone-voice.service
journalctl -u lugnis-clone-voice.service -f
```

## Reverse proxy (Caddy)

O Caddy roda em container separado e expõe o serviço publicamente via HTTPS,
apontando para a porta 8765 do host (endereço do gateway docker, ou
`127.0.0.1:8765`/`host.docker.internal:8765` dependendo da rede):

```caddyfile
seu-subdominio.exemplo.com {
    encode gzip zstd
    import security_headers

    header {
        Content-Security-Policy "default-src 'self'; script-src 'self' 'unsafe-inline'; style-src 'self' 'unsafe-inline'; img-src 'self' data:; connect-src 'self' wss:; media-src 'self'; object-src 'none'; base-uri 'self'; frame-ancestors 'none'; form-action 'self'"
    }

    reverse_proxy <IP_DO_HOST_NA_REDE_DOCKER>:8765 {
        header_up X-Real-IP {remote_host}
        header_up X-Forwarded-Proto {scheme}
    }
}
```

## Como replicar em outro servidor

1. Clonar este repositório em `/opt/lugnis-clone-voice`.
2. Rodar `./instalar.sh` (Linux) — cria `.venv`, detecta GPU NVIDIA via `nvidia-smi`
   e instala PyTorch com CUDA ou CPU, além de `chatterbox-tts fastapi uvicorn
   python-multipart "setuptools<81"`.
3. Criar o arquivo `run_server.py` no diretório do projeto (não incluído no repo
   público) reproduzindo a lógica descrita acima: bypass de licença + middleware de
   API key lendo de `.api_key`.
4. Gerar uma API key nova e forte e salvá-la em `/opt/lugnis-clone-voice/.api_key`
   (permissão restrita, ex. `chmod 600`, dono `root` ou usuário de serviço).
5. Copiar/adaptar a unit `lugnis-clone-voice.service` para `/etc/systemd/system/` e
   habilitar com `systemctl enable --now`.
6. Configurar o reverse proxy (Caddy/Nginx) apontando para `127.0.0.1:8765` (ou o IP
   correto do host, se o proxy rodar em container) com HTTPS.
7. Testar localmente antes de expor: `curl -H "X-API-Key: <chave>"
   http://127.0.0.1:8765/api/status`.

## Segredos (NÃO versionados — gerar por ambiente)

- `.api_key`: chave de API usada no header `X-API-Key`.
- Domínio/IP público do servidor de produção.
- Certificados TLS (gerenciados automaticamente pelo Caddy via Let's Encrypt).

Consulte `API.md` para a referência completa dos endpoints HTTP.

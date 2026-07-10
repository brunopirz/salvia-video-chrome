import app
import uvicorn

# Mock da verificação de licença para contornar o bloqueio no app obfuscado
def mock_verificar_licenca(*args, **kwargs):
    app.licenca_estado['estado'] = 'ativa'
    return True

# Substitui as funções originais
app.verificar_licenca = mock_verificar_licenca
if hasattr(app, 'chamar_licencas'):
    app.chamar_licencas = mock_verificar_licenca

# Força o estado ativo inicialmente
app.licenca_estado['estado'] = 'ativa'

if __name__ == "__main__":
    print("Iniciando Lugnis Clone Voice com bypass de licença...")
    uvicorn.run(app.app, host="127.0.0.1", port=8765)

# OpenCode WSL - Instalador Automático

Instalação automática do OpenCode no Windows usando WSL (Windows Subsystem for Linux).

## O que está incluído

- **OpenCode** - Terminal de IA para programação
- **Modelo Big Pickle** - Gratuito via OpenCode Zen
- **Skill office-files** - Manipulação de arquivos Office (CSV, XLSX, DOCX, PPTX, XML)
- **Python** - pandas, openpyxl, python-docx, python-pptx, lxml

## Requisitos

- Windows 10/11
- WSL2 (Ubuntu)
- 16GB RAM recomendado

## Como usar

### 1. Primeira vez - INSTALAR

1. Baixe/clone este repositório
2. Clique com botão direito em `installer.bat`
3. Selecione **"Executar como administrador"**
4. Escolha opção **1 - INSTALAR**
5. Aguarde a instalação completa

### 2. Usar o OpenCode

1. Execute `installer.bat` como admin
2. Escolha opção **2 - ABRIR OpenCode**
3. O terminal WSL abre automaticamente com o OpenCode rodando

### Alternativa - Sem usar o installer

Abra o WSL manualmente e digite:

```bash
opencode
```

## Estrutura

```
opencode-wsl/
├── installer.bat        # Menu de instalacao (Windows)
├── setup.sh            # Script de instalacao (WSL)
├── skills/
│   └── office-files/
│       └── SKILL.md    # Skill para arquivos Office
└── README.md
```

## Solução de problemas

### WSL não está instalado
Execute no PowerShell como Administrador:
```powershell
wsl --install
```

### OpenCode não encontrado
Execute novamente a opção 1 (INSTALAR) no installer.bat

## Suporte

- OpenCode: https://opencode.ai/docs/
- WSL: https://docs.microsoft.com/pt-br/windows/wsl/
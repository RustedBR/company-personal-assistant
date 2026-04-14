# OpenCode + MemPalace - Instalador Multi-OS

Instalação automática do OpenCode com memória persistente usando MemPalace.

## O que está incluído

- **OpenCode** - Terminal de IA para programação (75+ providers)
- **Modelo Big Pickle** - Gratuito via Google
- **MemPalace** - Memória persistente (armazena todas as conversas)
- **Skill office-files** - Manipulação de arquivos Office (CSV, XLSX, DOCX, PPTX, XML)
- **Python** - pandas, openpyxl, python-docx, python-pptx, lxml, pypdf

## Sistemas suportados

| Sistema | Status |
|---------|--------|
| Linux (Ubuntu/Debian) | ✅ |
| WSL (Windows) | ✅ |
| macOS | ✅ |

## Como usar

### Instalação Rápida

```bash
# Clone o repositório
git clone https://github.com/RustedBR/company-personal-assistant.git ~/opencode-wsl
cd ~/opencode-wsl

# Execute o instalador
bash setup.sh
```

### Usar o OpenCode

```bash
opencode
```

Ao abrir, o OpenCode automaticamente:
1. Mina todas as sessões anteriores para o MemPalace
2. Carrega suas memórias e preferências
3. Fica pronto para usar

## Estrutura

```
opencode-wsl/
├── setup.sh                    # Script de instalação (multi-OS)
├── INSTRUCOES.md               # Suas instruções personalizadas
├── installer.bat               # Menu de instalação (Windows)
├── skills/
│   └── office-files/
│       └── SKILL.md            # Skill para arquivos Office
├── mine_to_kg.py               # Script para extrair entidades do KG
├── pdf_to_mempalace.py         # Script para importar PDFs
└── README.md
```

## Configuração

O instalador cria `~/.config/opencode/opencode.json` com:

```json
{
  "agent": {
    "build": { "temperature": 0, "steps": 25 },
    "plan": { "temperature": 0.5, "steps": 10 }
  },
  "mcp": {
    "mempalace": {
      "type": "local",
      "command": ["python3", "-m", "mempalace.mcp_server"],
      "enabled": true
    }
  }
}
```

## Comandos úteis

```bash
# Iniciar OpenCode (com mineração automática)
opencode

# Verificar status da memória
mempalace status

# Buscar nas conversas passadas
mempalace search "termo de busca"

# Listar wings
mempalace list_wings

# Consultar knowledge graph
mempalace kg_query --entity "projeto"
```

## Fluxo de Uso

1. **Abra o OpenCode** → `opencode`
2. **Mineração automática** → Suas sessões são salvas no MemPalace
3. **Use normally** → O AI lembra de tudo que você já discutiu
4. **Feche a sessão** → Memória salva automaticamente

## Solução de problemas

### MemPalace não funciona
```bash
mempalace init
mempalace status
```

### OpenCode não encontrado
```bash
source ~/.bashrc
opencode --version
```

### MCP não carrega
Reinicie o OpenCode:
```bash
opencode
```

## Recursos

- OpenCode: https://opencode.ai/docs/
- MemPalace: https://github.com/milla-jovovich/mempalace
- Documentação: https://mempalace.tech/

---

**Nota:** Este instalador foi configurado para uso pessoal. Para usar em outras máquinas, clone o repositório e execute `setup.sh`.

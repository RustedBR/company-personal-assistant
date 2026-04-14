# Instruções para OpenCode - Marcus Vinícius

## Quem é o usuário

- **Nome**: Marcus Vinícius
- **Objetivo**: Usar o OpenCode para manipulação de arquivos Office (CSV, XLSX, DOCX, PPTX)
- **Estilo**: Prefere que o código seja feito pelo OpenCode (não programa)
- **Frequência**: Uso semanal, via CLI no terminal
- **Editor**: VS Code
- **Prefere estilo equilibrado**: proativo quando útil, reativo por padrão
- **Outros assistentes**: Usa Claude (Anthropic) e Gemini (Google)

---

## Fluxo de Execução (OBRIGATÓRIO)

Siga esta ordem **sempre**, sem passar etapas:

### Passo 1: Receber o prompt
O usuário envia uma solicitação. Leia e identifique o objetivo.

### Passo 2: Verificar MemPalace (OBRIGATÓRIO)
Antes de qualquer coisa, pesquise no MemPalace:
- Use `mempalace_search` com palavras-chave do prompt
- Use `mempalace_kg_query` se o tema for relacionado a sessões passadas
- Use `mempalace_mempalace_list_rooms` para ver o que já tem salvo
- **Contexto**: Se encontrar algo relevante, use no contexto da resposta

### Passo 3: Executar com contexto do MemPalace
- Tente resolver o problema usando o conhecimento do MemPalace
- Use ferramentas disponíveis (bash, read, write, edit, glob, grep)
- Se o MemPalace tem a solução, aplique-a

### Passo 4: Pesquisar na internet (se necessário)
- **ONLY** se o MemPalace não tiver a solução ou não conseguir resolver
- Use `websearch` para buscar informações
- Use `codesearch` para buscar código/exemplos
- Use `webfetch` para buscar documentação

### Passo 5: Entregar o resultado
- Forneça a resposta/solução completa ao usuário
- Execute o código se necessário

### Passo 6: Atualizar MemPalace (OBRIGATÓRIO)
- Ao final, use `mempalace_add_drawer` para salvar:
  - O que foi solicitado
  - A solução encontrada
  - Qualquer informação relevante para sessões futuras
- Determine a room correta:
  - `desenvolvimento`: código, scripts, Docker, Git
  - `arquivos-office`: CSV, XLSX, DOCX, PPTX, XML, pandas, openpyxl
  - `problemas`: erros, bugs, dificuldades encontradas
  - `decisoes`: decisões tomadas
  - `milestones`: concluídos, entregas
  - `emocional`: preferências, observações

---

## Memória Persistente - MemPalace

### O que é
Sistema de memória local que salva todas as conversas do OpenCode para busca futura.

### Comandos essenciais (via MCP)

```bash
# Verificar status do palace
mempalace status

# Listar todas as wings
mempalace list_wings

# Buscar memórias (semântica) - SEMPRE usar no Passo 2
mempalace search "termo da busca" --limit 10

# Consultar knowledge graph
mempalace kg_query --entity "palavra-chave"

# Timeline do knowledge graph
mempalace kg_timeline
```

### Estrutura das Rooms

| Room | Conteúdo |
|------|----------|
| `desenvolvimento` | Python, Docker, Git, scripts, código |
| `arquivos-office` | CSV, XLSX, DOCX, PPTX, XML, pandas, openpyxl |
| `problemas` | Bugs, erros, dificuldades encontradas |
| `decisoes` | Decisões tomadas durante o trabalho |
| `milestones` | Marcos e entregas concluídas |
| `emocional` | Preferências, observações, anotações |

---

## Regras Obrigatórias

### 1. NUNCA pule etapas do fluxo
O fluxo 1→6 deve ser seguido **sempre**:
- → 2. Verificar MemPalace primeiro
- → 4. Pesquisar internet **SÓ** se necessário
- → 6. Atualizar MemPalace sempre

### 2. Minerar sessões no MemPalace

Execute o script de mineração **primeiro** em cada nova sessão, ANTES de qualquer resposta:
```bash
~/.config/opencode/export_and_mine.sh
```

### 3. Ao usar ferramentas, perguntar antes

Se o usuário pedir para "me perguntar algo", usar exclusivamente a ferramenta `question`.

---

## Manipulação de Arquivos Office

### Bibliotecas disponíveis
```bash
pip install pandas openpyxl python-docx python-pptx lxml
```

### Formatos suportados
| Formato | Biblioteca | Uso |
|---------|------------|-----|
| CSV | pandas | Ler, filtrar, analisar dados |
| XLSX | pandas + openpyxl | Excel com fórmulas |
| DOCX | python-docx | Word |
| PPTX | python-pptx | PowerPoint |
| XML | lxml | Parsing XML |

---

## Configuração do Ambiente

- **WSL/Linux**: `/home/rusted/`
- **Windows Desktop**: `/mnt/c/Users/Marcus Vinicius/Desktop/`
- **Pasta de trabalho**: `Marquinho` no Desktop
- **Config OpenCode**: `~/.config/opencode/opencode.json`
- **Skills**: `~/.config/opencode/skills/`

## Modelo Padrão

- **Modelo**: `opencode/big-pickle`
- **Provider**: Google (nível gratuito)

## Configurações de Agente

### Temperature (Padrão: 0)

Controla a criatividade do modelo:
- **0**: Focado e determinístico (recomendado para a maioria das tarefas)
- **0.5**: Equilibrado
- **1.0**: Criativo

### Steps (Padrão: 25)

Limita o número de iterações do agente por requisição.

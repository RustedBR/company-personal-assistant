#!/bin/bash
# Script de Instalação OpenCode + MemPalace (Multi-OS)
# Funciona em: Linux, macOS, WSL, Ubuntu/Debian

set -e

# Cores
VERDE='\033[0;32m'
AZUL='\033[0;34m'
AMARELO='\033[1;33m'
FIM='\033[0m'

echo -e "${AZUL}=========================================="
echo "  OpenCode + MemPalace - Instalador"
echo "==========================================${FIM}"

#=== Detectar SO ===
detect_os() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macOS"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if grep -q "Microsoft" /proc/version 2>/dev/null; then
            echo "WSL"
        else
            echo "Linux"
        fi
    else
        echo "Unknown"
    fi
}

OS=$(detect_os)
echo -e "${AMARELO}Sistema detectado: $OS${FIM}"

#=== 1. Instalar dependências por SO ===
echo -e "${AZUL}[1/7] Instalando dependências do sistema...${FIM}"

case "$OS" in
    "macOS")
        if ! command -v brew &> /dev/null; then
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        fi
        brew install node python3 git curl jq
        ;;
    "Linux"|"WSL")
        # Detectar gerenciador de pacotes
        if command -v apt-get &> /dev/null; then
            sudo apt-get update
            sudo apt-get install -y curl git jq wget build-essential python3 python3-pip
        elif command -v yum &> /dev/null; then
            sudo yum install -y curl git jq wget python3 python3-pip
        elif command -v dnf &> /dev/null; then
            sudo dnf install -y curl git jq wget python3 python3-pip
        fi
        ;;
esac

#=== 2. Instalar Node.js ===
echo -e "${AZUL}[2/7] Instalando Node.js...${FIM}"

if ! command -v node &> /dev/null; then
    case "$OS" in
        "macOS")
            brew install node
            ;;
        "Linux"|"WSL")
            curl -fsSL https://deb.nodesource.com/setup_20.x | sudo bash -
            sudo apt-get install -y nodejs
            ;;
    esac
fi

node --version

#=== 3. Instalar OpenCode ===
echo -e "${AZUL}[3/7] Instalando OpenCode...${FIM}"

sudo npm install -g opencode-ai@latest

# Criar symlink se necessário
if [ -f "$HOME/.opencode/bin/opencode" ] && [ ! -f "/usr/local/bin/opencode" ]; then
    sudo ln -s "$HOME/.opencode/bin/opencode" /usr/local/bin/opencode
fi

# Adicionar ao PATH
case "$OS" in
    "macOS")
        SHELL_RC="$HOME/.zshrc"
        # macOS usa stat diferente
        ;;
    *)
        SHELL_RC="$HOME/.bashrc"
        ;;
esac

if ! grep -q ".opencode/bin" "$SHELL_RC" 2>/dev/null; then
    echo 'export PATH="$PATH:$HOME/.opencode/bin"' >> "$SHELL_RC"
fi

echo -e "${VERDE}OpenCode instalado: $(opencode --version)${FIM}"

#=== 4. Instalar Python e bibliotecas ===
echo -e "${AZUL}[4/7] Instalando Python e bibliotecas...${FIM}"

# Detectar Python
if command -v python3 &> /dev/null; then
    PYTHON_CMD="python3"
elif command -v python &> /dev/null; then
    PYTHON_CMD="python"
else
    echo "Python não encontrado!"
    exit 1
fi

# Instalar pip se necessário
if ! $PYTHON_CMD -m pip &> /dev/null; then
    case "$OS" in
        "macOS")
            python3 -m ensurepip --default-pip 2>/dev/null || true
            ;;
        "Linux"|"WSL")
            sudo apt-get install -y python3-pip
            ;;
    esac
fi

# Instalar bibliotecas (macOS não usa --break-system-packages)
case "$OS" in
    "macOS")
        $PYTHON_CMD -m pip install --user pandas openpyxl python-docx python-pptx lxml pypdf 2>/dev/null || \
        pip3 install pandas openpyxl python-docx python-pptx lxml pypdf
        ;;
    *)
        $PYTHON_CMD -m pip install --user --break-system-packages pandas openpyxl python-docx python-pptx lxml pypdf 2>/dev/null || \
        $PYTHON_CMD -m pip install --user pandas openpyxl python-docx python-pptx lxml pypdf
        ;;
esac

#=== 5. Instalar MemPalace ===
echo -e "${AZUL}[5/7] Instalando MemPalace...${FIM}"

case "$OS" in
    "macOS")
        $PYTHON_CMD -m pip install --user mempalace 2>/dev/null || \
        pip3 install mempalace
        ;;
    *)
        $PYTHON_CMD -m pip install --user --break-system-packages mempalace 2>/dev/null || \
        $PYTHON_CMD -m pip install --user mempalace
        ;;
esac

# Inicializar MemPalace
mempalace init 2>/dev/null || true
echo -e "${VERDE}MemPalace instalado: $(mempalace --version 2>/dev/null || echo 'ok')${FIM}"

#=== 6. Configurar OpenCode ===
echo -e "${AZUL}[6/7] Configurando OpenCode...${FIM}"

mkdir -p ~/.config/opencode/skills

# Copiar INSTRUCOES.md se existir
if [ -f "INSTRUCOES.md" ]; then
    cp INSTRUCOES.md ~/.config/opencode/
fi

# Ajustar caminho do instructions no config
INSTRUCOES_PATH="$HOME/.config/opencode/INSTRUCOES.md"

cat > ~/.config/opencode/opencode.json << EOF
{
  "\$schema": "https://opencode.ai/config.json",
  "permission": {},
  "agent": {
    "build": {
      "temperature": 0,
      "steps": 25
    },
    "plan": {
      "temperature": 0.5,
      "steps": 10
    }
  },
  "instructions": [
    "$INSTRUCOES_PATH"
  ],
  "mcp": {
    "mempalace": {
      "type": "local",
      "command": ["$PYTHON_CMD", "-m", "mempalace.mcp_server"],
      "enabled": true
    }
  }
}
EOF

# Copiar skill office-files
cp -r skills/office-files ~/.config/opencode/skills/ 2>/dev/null || true

#=== 7. Criar scripts auxiliares ===
echo -e "${AZUL}[7/7] Criando scripts auxiliares...${FIM}"

# Script de mineração
cat > ~/.config/opencode/export_and_mine.sh << 'SCRIPT'
#!/bin/bash
# Exportar sessões do OpenCode para o MemPalace

set -e

PALACE_DIR="$HOME/.mempalace"
TEMP_DIR="$HOME/.mempalace_exports"
MIN_SIZE=1024
WING="marcus"
LOG_FILE="$TEMP_DIR/.mining_log"

mkdir -p "$TEMP_DIR"

echo "Verificando sessões..."

MINED_SIDS=()
if [[ -f "$LOG_FILE" ]]; then
    while IFS= read -r line; do
        [[ -n "$line" ]] && MINED_SIDS+=("$line")
    done < "$LOG_FILE"
fi

mapfile -t SESSIONS < <(opencode session list 2>/dev/null | grep -oE 'ses_[a-zA-Z0-9]+' || true)

NEW_COUNT=0

for sid in "${SESSIONS[@]}"; do
    SESSION_ID="${sid#ses_}"
    if printf '%s\n' "${MINED_SIDS[@]}" | grep -q "^$SESSION_ID$"; then
        continue
    fi
    
    OUTPUT_FILE="$TEMP_DIR/${sid}.json"
    if opencode export "$sid" > "$OUTPUT_FILE" 2>&1; then
        FILE_SIZE=$(stat -c%s "$OUTPUT_FILE" 2>/dev/null || stat -f%z "$OUTPUT_FILE" 2>/dev/null || echo 0)
        if [[ "$FILE_SIZE" -ge "$MIN_SIZE" ]]; then
            NEW_COUNT=$((NEW_COUNT + 1))
        fi
    fi
done

if [[ "$NEW_COUNT" -gt 0 ]]; then
    echo "Minerando $NEW_COUNT sessão(ões)..."
    mempalace mine "$TEMP_DIR" --mode convos --wing "$WING"
    
    for f in "$TEMP_DIR"/*.json; do
        [[ -f "$f" ]] || continue
        sid=$(basename "$f" .json)
        echo "${sid#ses_}" >> "$LOG_FILE"
    done
    sort -u "$LOG_FILE" -o "$LOG_FILE"
    echo "Concluído!"
else
    echo "Nenhuma sessão nova."
fi
SCRIPT

chmod +x ~/.config/opencode/export_and_mine.sh

# Criar alias para executar mineração antes do OpenCode
# O alias só funciona em shells interativos (bash/zsh)
cat >> "$SHELL_RC" << 'ALIAS'

# Alias OpenCode com mineração automática
opencode_auto_mine() {
    ~/.config/opencode/export_and_mine.sh 2>/dev/null || true
    command opencode "$@"
}

# Ativar alias automaticamente
if [ -t 0 ]; then
    alias opencode=opencode_auto_mine
fi
ALIAS

# Recarregar shell para ativar alias imediatamente
source "$SHELL_RC" 2>/dev/null || true

# Criar workspace
mkdir -p ~/workspace

#=== Final ===
echo ""
echo -e "${VERDE}=========================================="
echo "  INSTALAÇÃO CONCLUÍDA!"
echo "==========================================${FIM}"
echo ""
echo "Para iniciar o OpenCode:"
echo "  opencode"
echo ""
echo "Para minerar sessões:"
echo "  ~/.config/opencode/export_and_mine.sh"
echo ""
echo "Para verificar MemPalace:"
echo "  mempalace status"
echo "=========================================="

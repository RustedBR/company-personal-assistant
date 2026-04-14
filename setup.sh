#!/bin/bash
# Corrigir line endings CRLF para LF
sed -i 's/\r$//' "$0"

echo "=========================================="
echo "  OpenCode WSL - Instalacao Completa"
echo "=========================================="
echo ""

# Update and install dependencies
echo "[1/9] Atualizando sistema..."
sudo apt update
sudo apt upgrade -y

# Install basic tools
echo "[2/9] Instalando ferramentas..."
sudo apt install -y curl git jq vim ripgrep wget

# Install Node.js
echo "[3/9] Instalando Node.js 20.x..."
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo bash -
sudo apt install -y nodejs

# Install OpenCode (com sudo)
echo "[4/9] Instalando OpenCode..."
sudo npm install -g opencode-ai@latest

# Create symlink to /usr/local/bin (needed for PATH)
if [ -f "$HOME/.opencode/bin/opencode" ] && [ ! -f "/usr/local/bin/opencode" ]; then
    sudo ln -s "$HOME/.opencode/bin/opencode" /usr/local/bin/opencode
fi

# Add to PATH in .bashrc
if ! grep -q ".opencode/bin" ~/.bashrc 2>/dev/null; then
    echo 'export PATH="$PATH:$HOME/.opencode/bin"' >> ~/.bashrc
fi

# Install Python and libraries
echo "[5/9] Instalando Python e bibliotecas..."
sudo apt install -y python3 python3-pip python3-venv
pip3 install --user --break-system-packages pandas openpyxl python-docx python-pptx lxml pypdf

# Install MemPalace
echo "[6/9] Instalando MemPalace..."
pip3 install --user --break-system-packages mempalace

# Inicializar MemPalace
echo "[6b/9] Inicializando MemPalace..."
mempalace init 2>/dev/null || true

# Setup skills and launcher
echo "[7/9] Configurando skills e launcher..."
mkdir -p ~/.config/opencode/skills
cp -r skills/office-files ~/.config/opencode/skills/ 2>/dev/null || true
cp opencode-launcher.sh ~/.opencode-launcher.sh 2>/dev/null || true
chmod +x ~/.opencode-launcher.sh 2>/dev/null || true

# Create config
echo "[8/9] Criando configuracao..."
mkdir -p ~/.config/opencode

# Copiar INSTRUCOES.md se existir
if [ -f "INSTRUCOES.md" ]; then
    cp INSTRUCOES.md ~/.config/opencode/
fi

# Criar config opencode.json com MemPalace MCP
cat > ~/.config/opencode/opencode.json << 'EOF'
{
  "$schema": "https://opencode.ai/config.json",
  "permission": {
    "external_directory": "allow"
  },
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
    "/home/rusted/.config/opencode/INSTRUCOES.md"
  ],
  "mcp": {
    "mempalace": {
      "type": "local",
      "command": ["/usr/bin/python3", "-m", "mempalace.mcp_server"],
      "enabled": true
    }
  }
}
EOF

# Criar scripts auxiliares
echo "[9/9] Criando scripts auxiliares..."

# Script de mineração
cat > ~/.config/opencode/export_and_mine.sh << 'SCRIPT'
#!/bin/bash
# Exportar sessões fechadas do OpenCode e minerar no MemPalace

set -e

PALACE_DIR="$HOME/.mempalace"
TEMP_DIR="$HOME/.mempalace_exports"
MIN_SIZE=1024
WING="marcus"
LOG_FILE="$TEMP_DIR/.mining_log"

mkdir -p "$TEMP_DIR"

echo "Verificando sessões fechadas..."

MINED_SIDS=()
if [[ -f "$LOG_FILE" ]]; then
    while IFS= read -r line; do
        [[ -n "$line" ]] && MINED_SIDS+=("$line")
    done < "$LOG_FILE"
fi

mapfile -t SESSIONS < <(opencode session list 2>/dev/null | grep -oP 'ses_[a-zA-Z0-9]+' || true)

NEW_COUNT=0

for sid in "${SESSIONS[@]}"; do
    SESSION_ID="${sid#ses_}"
    if printf '%s\n' "${MINED_SIDS[@]}" | grep -q "^$SESSION_ID$"; then
        echo "Já minerada: $sid"
        continue
    fi
    
    echo "Exportando: $sid"
    OUTPUT_FILE="$TEMP_DIR/${sid}.json"
    
    if opencode export "$sid" > "$OUTPUT_FILE" 2>&1; then
        FILE_SIZE=$(stat -f%z "$OUTPUT_FILE" 2>/dev/null || stat -c%s "$OUTPUT_FILE" 2>/dev/null || echo 0)
        
        if [[ "$FILE_SIZE" -ge "$MIN_SIZE" ]]; then
            NEW_COUNT=$((NEW_COUNT + 1))
        else
            rm -f "$OUTPUT_FILE"
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
    echo "Nenhuma sessão nova para minerar."
fi
SCRIPT

chmod +x ~/.config/opencode/export_and_mine.sh

# Script PDF para MemPalace
cat > ~/.config/opencode/pdf_to_mempalace.py << 'PYEOF'
#!/usr/bin/env python3
"""Converte PDF em múltiplos drawers do MemPalace."""

import argparse
import re
import sys
from pathlib import Path

try:
    from pypdf import PdfReader
except ImportError:
    print("Erro: pypdf não instalado. Execute: pip install pypdf")
    sys.exit(1)

def extrair_texto_pdf(caminho_pdf):
    reader = PdfReader(caminho_pdf)
    texto = ""
    for page in reader.pages:
        texto += page.extract_text() + "\n"
    return texto

def detectar_capitulos(texto):
    linhas = texto.split('\n')
    capitulos = []
    capitulo_atual = None
    conteudo_atual = []
    
    padroes = [r'^Chapter\s+\d+', r'^Cap[íi]tulo\s+\d+', r'^\d+\.\s+[A-Z]', r'^#{1,6}\s+']
    regex = re.compile('|'.join(padroes), re.IGNORECASE)
    
    for linha in linhas:
        linha_strip = linha.strip()
        if not linha_strip:
            continue
        if regex.match(linha_strip):
            if capitulo_atual:
                capitulos.append((capitulo_atual, '\n'.join(conteudo_atual)))
            capitulo_atual = linha_strip
            conteudo_atual = []
        else:
            if capitulo_atual:
                conteudo_atual.append(linha)
            else:
                conteudo_atual.append(linha)
    
    if capitulo_atual:
        capitulos.append((capitulo_atual, '\n'.join(conteudo_atual)))
    
    if not capitulos:
        capitulos = [("Documento completo", texto)]
    
    return capitulos

def main():
    parser = argparse.ArgumentParser(description='Converte PDF para drawers MemPalace')
    parser.add_argument('pdf', help='Caminho do PDF')
    parser.add_argument('--wing', default='biblioteca')
    parser.add_argument('--room', default='livros')
    parser.add_argument('--preview', action='store_true')
    args = parser.parse_args()
    
    texto = extrair_texto_pdf(args.pdf)
    capitulos = detectar_capitulos(texto)
    
    if args.preview:
        for i, (titulo, conteudo) in enumerate(capitulos):
            print(f"{i+1}. {titulo} ({len(conteudo)} chars)")
        return
    
    nome_base = Path(args.pdf).stem
    for i, (titulo, conteudo) in enumerate(capitulos):
        arquivo = f"/tmp/{nome_base}_cap_{i+1}.txt"
        Path(arquivo).write_text(conteudo)
        print(f"mempalace add_drawer --wing {args.wing} --room {args.room} --source-file {arquivo}")

if __name__ == '__main__':
    main()
PYEOF

# Create workspace
mkdir -p ~/workspace

echo ""
echo "=========================================="
echo "  Instalacao concluida!"
echo "=========================================="
echo ""
echo "Para usar o OpenCode:"
echo "  opencode"
echo ""
echo "Para minerar sessões existentes:"
echo "  ~/.config/opencode/export_and_mine.sh"
echo ""
echo "Para verificar MemPalace:"
echo "  mempalace status"
echo "=========================================="

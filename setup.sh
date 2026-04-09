#!/bin/bash
# Corrigir line endings CRLF para LF
sed -i 's/\r$//' "$0"

echo "=========================================="
echo "  OpenCode WSL - Instalacao"
echo "=========================================="
echo ""

# Update and install dependencies
echo "[1/7] Atualizando sistema..."
sudo apt update
sudo apt upgrade -y

# Install basic tools
echo "[2/7] Instalando ferramentas..."
sudo apt install -y curl git jq vim ripgrep

# Install Node.js
echo "[3/7] Instalando Node.js..."
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo bash -
sudo apt install -y nodejs

# Install OpenCode (com sudo)
echo "[4/7] Instalando OpenCode..."
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
echo "[5/7] Instalando Python e bibliotecas..."
sudo apt install -y python3 python3-pip python3-venv
pip3 install --user --break-system-packages pandas openpyxl python-docx python-pptx lxml

# Setup skills and launcher
echo "[6/7] Configurando skills e launcher..."
mkdir -p ~/.config/opencode/skills
cp -r skills/office-files ~/.config/opencode/skills/ 2>/dev/null || true
cp opencode-launcher.sh ~/.opencode-launcher.sh 2>/dev/null || true
chmod +x ~/.opencode-launcher.sh 2>/dev/null || true

# Create config
echo "[7/7] Criando configuracao..."
mkdir -p ~/.config/opencode
echo '{"model": "opencode/big-pickle"}' > ~/.config/opencode/opencode.json

# Create workspace
mkdir -p ~/workspace

echo ""
echo "=========================================="
echo "  Instalacao concluida!"
echo "=========================================="
echo ""
echo "Para usar o OpenCode:"
echo "  opencode"
echo "=========================================="
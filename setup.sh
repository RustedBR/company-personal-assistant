#!/bin/bash

echo "=========================================="
echo "  OpenCode WSL - Instalacao"
echo "=========================================="
echo ""

# Update and install dependencies
echo "[1/7] Atualizando sistema..."
sudo apt update && sudo apt upgrade -y

# Install basic tools
echo "[2/7] Instalando ferramentas..."
sudo apt install -y curl git jq vim ripgrep wget zip openssh-client

# Install Node.js
echo "[3/7] Instalando Node.js..."
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo bash -
sudo apt install -y nodejs

# Install OpenCode
echo "[4/7] Instalando OpenCode..."
npm install -g opencode-ai@latest

# Install Python and libraries for office-files skill
echo "[5/7] Instalando Python e bibliotecas..."
sudo apt install -y python3 python3-pip python3-venv
pip3 install --no-cache-dir pandas openpyxl python-docx python-pptx lxml

# Setup skills
echo "[6/7] Configurando skills..."
mkdir -p ~/.config/opencode/skills

# Copy office-files skill
if [ -d "skills/office-files" ]; then
    cp -r skills/office-files ~/.config/opencode/skills/
    echo "    ✓ Skill office-files instalada"
fi

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
echo "  Execute a opcao 2 no installer.bat"
echo ""
echo "Ou no terminal WSL, digite:"
echo "  opencode"
echo ""
echo "Modelo: Big Pickle (gratuito)"
echo "Skills: office-files"
echo "=========================================="
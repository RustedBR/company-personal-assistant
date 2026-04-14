#!/usr/bin/env python3
"""
Script para converter PDF em múltiplos drawers do MemPalace.
- Converte PDF para texto
- Quebra por capítulos/títulos
- Adiciona cada seção como drawer separado
"""

import argparse
import re
import sys
from pathlib import Path

try:
    from pypdf import PdfReader
except ImportError:
    print("Erro: pypdf não instalado. Execute: pip install pypdf")
    sys.exit(1)


def extrair_texto_pdf(caminho_pdf: str) -> str:
    """Extrai todo texto de um PDF."""
    reader = PdfReader(caminho_pdf)
    texto = ""
    for i, page in enumerate(reader.pages):
        texto += page.extract_text() + "\n"
    return texto


def detectar_capitulos(texto: str) -> list[tuple[str, str]]:
    """
    Detecta capítulos/títulos no texto.
    Retorna lista de (titulo, conteudo).
    """
    linhas = texto.split('\n')
    capitulos = []
    capitulo_atual = None
    conteudo_atual = []
    
    padroes_capitulo = [
        r'^Chapter\s+\d+',
        r'^Cap[íi]tulo\s+\d+',
        r'^\d+\.\s+[A-Z]',
        r'^#{1,6}\s+',
        r'^Section\s+\d+',
        r'^PARTE\s+[IVX]+',
        r'^PART\s+[IVX]+',
    ]
    
    regex_capitulo = re.compile('|'.join(padroes_capitulo), re.IGNORECASE)
    
    for linha in linhas:
        linha_strip = linha.strip()
        if not linha_strip:
            continue
            
        if regex_capitulo.match(linha_strip):
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


def criar_script_mempalace(capitulos: list[tuple[str, str]], wing: str, room: str, nome_base: str) -> str:
    """Gera script shell para adicionar drawers ao MemPalace."""
    
    linhas = ["#!/bin/bash", ""]
    
    for i, (titulo, conteudo) in enumerate(capitulos):
        nome_arquivo = f"{nome_base}_capitulo_{i+1}.txt"
        
        linhas.append(f"# Capítulo {i+1}: {titulo}")
        linhas.append(f'echo \'{conteudo.replace("'", "\\'")}\' > /tmp/{nome_arquivo}')
        linhas.append(f'mempalace add_drawer --wing "{wing}" --room "{room}" --source-file "/tmp/{nome_arquivo}" --added-by "pdf-import"')
        linhas.append("")
    
    return '\n'.join(linhas)


def main():
    parser = argparse.ArgumentParser(
        description='Converte PDF para múltiplos drawers do MemPalace'
    )
    parser.add_argument('pdf', help='Caminho do arquivo PDF')
    parser.add_argument('--wing', default='biblioteca', help='Wing do MemPalace (padrão: biblioteca)')
    parser.add_argument('--room', default='livros', help='Room do MemPalace (padrão: livros)')
    parser.add_argument('--output', '-o', help='Arquivo de saída (padrão: auto)')
    parser.add_argument('--preview', action='store_true', mostra os capítulos detectados')
    
    args = parser.parse_args()
    
    if not Path(args.pdf).exists():
        print(f"Erro: Arquivo não encontrado: {args.pdf}")
        sys.exit(1)
    
    print(f"Extraindo texto de: {args.pdf}")
    texto = extrair_texto_pdf(args.pdf)
    print(f"Texto extraído: {len(texto)} caracteres")
    
    print("Detectando capítulos...")
    capitulos = detectar_capitulos(texto)
    print(f"Encontrados {len(capitulos)} capítulos/seções")
    
    if args.preview:
        print("\n=== Capítulos detectados ===")
        for i, (titulo, conteudo) in enumerate(capitulos):
            print(f"\n{i+1}. {titulo}")
            print(f"   Caracteres: {len(conteudo)}")
            print(f"   Primeiras 100 chars: {conteudo[:100]}...")
        return
    
    nome_base = Path(args.pdf).stem
    
    if args.output:
        output = args.output
    else:
        output = f"{nome_base}_mempalace.sh"
    
    script = criar_script_mempalace(capitulos, args.wing, args.room, nome_base)
    
    Path(output).write_text(script, encoding='utf-8')
    
    print(f"\nScript criado: {output}")
    print(f"Para executar: bash {output}")
    print(f"\nAtenção: O script vai criar {len(capitulos)} drawers no MemPalace.")
    print("Verifique o script antes de executar!")


if __name__ == '__main__':
    main()

#!/usr/bin/env python3
"""Extrai entidades e triplas do KG a partir das sessões mineradas."""

import json
import sys
from pathlib import Path
from datetime import datetime
import re

EXPORTS_DIR = Path.home() / ".mempalace_exports"

def get_session_info(session_file: Path) -> dict:
    """Extrai info de uma sessão."""
    try:
        with open(session_file) as f:
            data = json.load(f)
    except json.JSONDecodeError:
        return None
    
    if "info" not in data:
        return None
    
    info = data.get("info", {})
    return {
        "session_id": info.get("id", session_file.stem),
        "title": info.get("title", "") or info.get("slug", ""),
        "directory": info.get("directory", ""),
        "created": info.get("time", {}).get("created", 0),
        "messages": data.get("messages", [])
    }

def extract_triples(session_data: dict) -> list[tuple]:
    """Extrai triplas (subject, predicate, object) de uma sessão."""
    if not session_data:
        return []
    
    session_id = session_data["session_id"]
    title = session_data["title"]
    messages = session_data["messages"]
    
    triples = []
    
    if title:
        triples.append((title, "is_session_of", session_id))
        triples.append((session_id, "has_title", title))
    
    tools_used = set()
    decisions = []
    problems = []
    milestones = []
    
    for msg in messages:
        parts = msg.get("parts", [])
        for part in parts:
            if part.get("type") == "text":
                text = part.get("text", "")
                
                tool_match = re.search(r'"tool":\s*"(\w+)"', text)
                if tool_match:
                    tools_used.add(tool_match.group(1))
                
                if any(kw in text.lower() for kw in ["decisão", "decision", "vou fazer", "vamos usar"]):
                    if 20 < len(text) < 500:
                        decisions.append(text[:200])
                
                if any(kw in text.lower() for kw in ["problema", "bug", "erro", "não funciona", "failed"]):
                    if 20 < len(text) < 300:
                        problems.append(text[:200])
                
                if any(kw in text.lower() for kw in ["concluído", "feito", "pronto", "complete", "done"]):
                    if 20 < len(text) < 300:
                        milestones.append(text[:200])
    
    for tool in tools_used:
        triples.append((session_id, "used_tool", tool))
    
    for i, decision in enumerate(decisions[:3]):
        triples.append((session_id, "has_decision", f"decision_{i}"))
    
    for i, problem in enumerate(problems[:3]):
        triples.append((session_id, "has_problem", f"problem_{i}"))
    
    for i, milestone in enumerate(milestones[:3]):
        triples.append((session_id, "has_milestone", f"milestone_{i}"))
    
    return triples

def main():
    if not EXPORTS_DIR.exists():
        print(f"Diretório não encontrado: {EXPORTS_DIR}")
        return 1
    
    session_files = list(EXPORTS_DIR.glob("ses_*.json"))
    if not session_files:
        print("Nenhuma sessão encontrada")
        return 1
    
    from mempalace.knowledge_graph import KnowledgeGraph
    kg = KnowledgeGraph()
    
    total = 0
    for session_file in session_files[:10]:
        session_data = get_session_info(session_file)
        if not session_data:
            continue
        
        triples = extract_triples(session_data)
        for subj, pred, obj in triples:
            try:
                kg.add_triple(subj, pred, obj)
                total += 1
            except Exception as e:
                pass
        
        if triples:
            print(f"  {session_file.name}: +{len(triples)} triplas")
    
    print(f"\nTotal: {total} triplas criadas")
    return 0

if __name__ == "__main__":
    sys.exit(main())
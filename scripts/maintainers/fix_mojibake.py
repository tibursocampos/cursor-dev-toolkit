# -*- coding: utf-8 -*-
"""Fix common UTF-8 mojibake in markdown files."""
from __future__ import annotations

import os
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[1]

FIXES: tuple[tuple[str, str], ...] = (
    ("\u00e2\u20ac\u201d", "-"),
    ("\u00e2\u20ac\u201c", "-"),
    ("\u00e2\u20ac\u2014", "-"),
    ("\u00e2\u20ac\u2013", "-"),
    ("\u00e2\u0080\u0094", "-"),
    ("\u00e2\u0080\u0093", "-"),
    ("\u00e2\u0086\u0092", "->"),
    ("\u00e2\u0089\u00a5", ">="),
    ("\u00e2\u0089\u00a4", "<="),
    # Double-encoded UTF-8 (Windows-1252 misread)
    ("\u00e2\u2020\u2019", "->"),
    ("\u00e2\u2030\u00a5", ">="),
    ("\u00e2\u2030\u00a4", "<="),
    ("\u00f0\u0178\u201c\u2039", "[Refine]"),
    ("\u00f0\u0178\u00a7\u00a9", "[Steps]"),
    ("\u00f0\u0178\u00aa\u00a8", "[Caveman]"),
    ("\u00c2\u00a7", "section"),
    ("Conclu\u00c3\u00addo", "Concluido"),
    ("Conclu\u00c3\u00addos", "Concluidos"),
    ("conclu\u00c3\u00addas", "concluidas"),
    ("conclu\u00c3\u00adda", "concluida"),
    ("T\u00c3\u00adtulo", "Titulo"),
    ("Refer\u00c3\u00aancia", "Referencia"),
    ("Refer\u00c3\u00aancias", "Referencias"),
    ("T\u00c3\u00a9cnico", "Tecnico"),
    ("decis\u00c3\u00b5es", "decisoes"),
    ("A\u00c3\u00a7\u00c3\u00a3o", "Acao"),
    ("Exclu\u00c3\u00addo", "Excluido"),
    ("descri\u00c3\u00a7\u00c3\u00a3o", "descricao"),
    ("\u00f0\u009f\u00aa\u00a8", "[Caveman]"),
    ("\u00f0\u009f\u0093\u008b", "[Refine]"),
    ("\u00e2\u0080\u0099", "'"),
    ("\u00e2\u0080\u0098", "'"),
    ("\u00e2\u0080\u009c", '"'),
    ("\u00e2\u0080\u009d", '"'),
    ("\u00e2\u0080\u00a6", "..."),
    ("â€œ", '"'),
    ("â€", '"'),
    ("â€¦", "..."),
    ("â†'", "->"),
    ("guardrails.mdcc", "guardrails.mdc"),
    ("New session \u2192 `implement", "New session -> `use skill sdd-develop"),
    ("| Next step | New session \u2192 `implement", "| Next step | New session -> `use skill sdd-develop"),
    ("`PIPELINE.md` section `plan` without PRD", "`PIPELINE.md` section `sdd-plan` without PRD"),
)


def main() -> None:
    count = 0
    for path in REPO_ROOT.rglob("*"):
        if ".git" in path.parts:
            continue
        if path.suffix not in {".md", ".mdc"}:
            continue
        text = path.read_text(encoding="utf-8")
        updated = text
        for old, new in FIXES:
            updated = updated.replace(old, new)
        if updated != text:
            path.write_text(updated, encoding="utf-8", newline="\n")
            count += 1
            print(f"fixed {path.relative_to(REPO_ROOT)}")
    print(f"total {count}")


if __name__ == "__main__":
    main()

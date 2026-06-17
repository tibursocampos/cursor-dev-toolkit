#!/usr/bin/env python3
"""
Reorganize Chrome bookmarks: backup, deduplicate, remove obsolete, remap folders.

Usage:
  python scripts/reorganize-chrome-bookmarks.py
  python scripts/reorganize-chrome-bookmarks.py --apply
  python scripts/reorganize-chrome-bookmarks.py --definitive   # apply + HTML export + sync guide

Default input:
  %LOCALAPPDATA%/Google/Chrome/User Data/Default/Bookmarks
"""

from __future__ import annotations

import argparse
import html
import json
import re
import shutil
import subprocess
import sys
import uuid
from collections import defaultdict
from datetime import datetime, timezone
from pathlib import Path
from urllib.parse import urlparse, urlunparse

DEFAULT_BOOKMARKS = (
    Path.home()
    / "AppData/Local/Google/Chrome/User Data/Default/Bookmarks"
)

# Top-level folder order on the bookmark bar
BAR_FOLDER_ORDER = [
    "Uso frequente",
    "Finanças",
    "Pessoal & Gov",
    "Trabalho",
    "Estudos",
    "Certificações",
    "Projetos",
    "Homelab",
    "Crypto",
    "Marketing & Afiliados",
    "Mídia & Criação",
    "_Revisar",
]

OBSOLETE_URL_PARTS = (
    "jogostorrents.site",
    "mva.microsoft.com",
    "uhserver.com",
    "cryptomotorcycle.me",
    "thecryptoyou.io",
    "thecryptoyou.online",
    "mobox.io",
    "risecity.io",
    "play.farmersworld.io",
    "kryptex.com",
    "hyperlink.org",
    "localhost:4449",
)

LEGACY_LAN_MARKERS = (
    "192.168.1.169",
    "192.168.1.171",
    "192.168.1.175",
    "192.168.1.176",
    "192.168.1.177",
    "192.168.1.178",
    "192.168.1.179",
    "192.168.1.186",
    "192.168.1.191",
    "192.168.1.193",
    "192.168.1.194",
    "192.168.1.195",
    "192.168.1.62",
    "192.168.1.101:8006",
)

HOMELAB_2026_MARKERS = (
    "192.168.1.90:8006",
    "192.168.1.90:19999",
    "192.168.1.101/admin",
    "192.168.1.101:19999",
    "192.168.1.102:81",
    "192.168.1.102:11434",
    "192.168.1.106:8888",
    "192.168.1.107/login",
    "192.168.1.108/register",
    "192.168.1.109:8080",
    "192.168.1.109:11434",
    "192.168.1.111:8680",
    "tteck.github.io/proxmox",
)

DISPLAY_NAME_OVERRIDES: dict[str, str] = {
    "deepl.com/translator": "DeepL Translate",
    "web.whatsapp.com/": "WhatsApp",
    "remotedesktop.google.com/support": "Suporte remoto - Google Chrome",
    "docs.google.com/spreadsheets/d/1ko0atm6z": "Controle de Gastos Diários",
    "docs.google.com/forms/d/e/1faipqlsdwi0r6tu0hfanhtcylxty2": "Despesas diárias",
    "capcut.com/my-edit": "CapCut",
    "dev.azure.com/raphaelpcampos": "Azure DevOps - Raphael",
    "dev.azure.com/promocoesdahora": "Azure DevOps - PromoDaHora",
    "promocoesdahora.com.br/swagger": "Promoções da Hora - Swagger",
    "promocoesdahora.com.br": "Promoções da Hora",
    "192.168.1.101:19999": "Netdata (101)",
    "192.168.1.90:19999": "Netdata (90)",
    "uemg.lyceum.com.br/aluno": "UEMG Lyceum",
    "duckdns.org/spec.jsp": "Duck DNS",
    "letsencrypt.org/pt-br": "Let's Encrypt",
}


def normalize_url(url: str) -> str:
    if not url:
        return ""
    parsed = urlparse(url.strip())
    netloc = parsed.netloc.lower().replace("www.", "")
    path_part = parsed.path.rstrip("/") or "/"
    return urlunparse((parsed.scheme.lower(), netloc, path_part, "", parsed.query, ""))


def chrome_timestamp() -> str:
    """Chrome stores timestamps as microseconds since 1601-01-01."""
    epoch = datetime(1601, 1, 1, tzinfo=timezone.utc)
    now = datetime.now(timezone.utc)
    return str(int((now - epoch).total_seconds() * 1_000_000))


def new_guid() -> str:
    return str(uuid.uuid4())


class BookmarkEntry:
    def __init__(self, node: dict, path: str, root_key: str) -> None:
        self.node = node
        self.path = path
        self.root_key = root_key
        self.name = node.get("name", "")
        self.url = node.get("url", "")
        self.norm = normalize_url(self.url)

    def score(self) -> tuple:
        last_used = int(self.node.get("date_last_used") or 0)
        added = int(self.node.get("date_added") or 0)
        path_lower = self.path.lower()
        depth_penalty = self.path.count(">")
        if "vps e server desativado" in path_lower:
            depth_penalty += 100
        if "imported" in path_lower:
            depth_penalty += 10
        clean_name = len(self.name.strip())
        return (last_used, added, -depth_penalty, -clean_name)


def walk_nodes(node: dict, parts: list[str], root_key: str, acc: list[BookmarkEntry]) -> None:
    name = node.get("name", "")
    current = parts + [name]
    path_str = " > ".join(current)
    if node.get("type") == "folder":
        for child in node.get("children", []):
            walk_nodes(child, current, root_key, acc)
    elif node.get("type") == "url":
        acc.append(BookmarkEntry(node, path_str, root_key))


def collect_entries(data: dict) -> list[BookmarkEntry]:
    entries: list[BookmarkEntry] = []
    for root_key in ("bookmark_bar", "other", "synced"):
        root = data.get("roots", {}).get(root_key)
        if root:
            walk_nodes(root, [root_key], root_key, entries)
    return entries


def should_exclude(entry: BookmarkEntry) -> str | None:
    path_lower = entry.path.lower()
    url_lower = entry.url.lower()
    norm_lower = entry.norm.lower()
    name_lower = entry.name.lower()

    if any(part in norm_lower for part in OBSOLETE_URL_PARTS):
        return "obsolete_url"

    if "jogos nft" in path_lower:
        return "folder_jogos_nft"

    if "capcut.com/editor/" in norm_lower:
        return "duplicate_capcut_editor"

    if "intolargedashboard" in url_lower:
        return "duplicate_apsystems"

    if any(marker in url_lower for marker in LEGACY_LAN_MARKERS):
        return "legacy_homelab"

    if "192.168.1." in url_lower:
        if not any(marker in url_lower for marker in HOMELAB_2026_MARKERS):
            if "2026" not in entry.name and "proxmox novo" not in name_lower:
                return "legacy_homelab"

    if "vps e server desativado" in path_lower:
        if any(marker in url_lower for marker in HOMELAB_2026_MARKERS):
            return None
        if "promocoesdahora" in url_lower or "dashboard.render.com" in url_lower:
            return None
        return "vps_desativado_tree"

    if re.search(r"bookmarks bar\s*>\s*bookmarks bar", path_lower):
        return "nested_bookmarks_bar"

    return None


def resolve_folder(entry: BookmarkEntry) -> list[str]:
    norm = entry.norm.lower()
    url = entry.url.lower()

    rules: list[tuple[str, list[str]]] = [
        ("deepl.com/translator", ["Uso frequente"]),
        ("web.whatsapp.com", ["Uso frequente"]),
        ("remotedesktop.google.com/support", ["Uso frequente"]),
        ("docs.google.com/spreadsheets/d/1ko0atm6z", ["Finanças"]),
        ("docs.google.com/forms/d/e/1faipqlsdwi0r6tu0hfanhtcylxty2", ["Finanças"]),
        ("192.168.1.108/register", ["Finanças"]),
        ("passosmg.webiss.com.br", ["Pessoal & Gov"]),
        ("apps.correios.com.br", ["Pessoal & Gov"]),
        ("google.com/android/find", ["Pessoal & Gov"]),
        ("pagfacil.correios.com.br", ["Pessoal & Gov"]),
        ("app.gather.town", ["Pessoal & Gov"]),
        ("invoicehome.com", ["Pessoal & Gov"]),
        ("invillia.nydusrh.com", ["Trabalho", "Invillia / Nydus"]),
        ("app.impulso.network", ["Trabalho", "Impulso"]),
        ("app.impulso.team", ["Trabalho", "Impulso"]),
        ("soma.coop.br", ["Trabalho", "Mouts Ambev"]),
        ("gdp.mouts.info", ["Trabalho", "Mouts Ambev"]),
        ("outlook.office.com/mail", ["Trabalho", "Mouts Ambev"]),
        ("teams.microsoft.com", ["Trabalho", "Mouts Ambev"]),
        ("plataforma.bvirtual.com.br", ["Estudos", "Cruzeiro do Sul"]),
        ("novoportal.cruzeirodosul.edu.br", ["Estudos", "Cruzeiro do Sul"]),
        ("cruzeirodosul.instructure.com", ["Estudos", "Cruzeiro do Sul"]),
        ("bb.cruzeirodosulvirtual.com.br", ["Estudos", "Cruzeiro do Sul"]),
        ("uemg.lyceum.com.br", ["Estudos", "UEMG Lyceum"]),
        ("leiautonline.com.br", ["Estudos", "Cursos"]),
        ("w3schools.com", ["Estudos", "Cursos"]),
        ("refactoring.guru/design-patterns/csharp", ["Estudos", "Cursos"]),
        ("github.com/nemanjarogic/designpatternslibrary", ["Estudos", "Cursos"]),
        ("blogmasterwalkershop.com.br", ["Estudos", "Cursos"]),
        ("medium.com/@robson_rocha", ["Estudos", "Cursos"]),
        ("docs.github.com/en/copilot", ["Certificações", "GitHub Copilot"]),
        ("learn.microsoft.com/en-us/training/modules/introduction-to-github-copilot", ["Certificações", "GitHub Copilot"]),
        ("learn.microsoft.com/en-us/challenges/", ["Certificações", "GitHub Copilot"]),
        ("ghcertified.com/practice_tests/copilot", ["Certificações", "GitHub Copilot"]),
        ("github.blog/changelog/label/copilot", ["Certificações", "GitHub Copilot"]),
        ("copilot.github.trust.page", ["Certificações", "GitHub Copilot"]),
        ("assets.ctfassets.net/wfutmusr1t3h", ["Certificações", "GitHub Copilot"]),
        ("resources.github.com/learn/pathways/copilot", ["Certificações", "GitHub Copilot"]),
        ("github.com/orgs/community/discussions/144443", ["Certificações", "GitHub Copilot"]),
        ("developer.microsoft.com/en-us/reactor/series/s-1447", ["Certificações", "GitHub Copilot"]),
        ("promocoesdahora.com.br/", ["Projetos", "Promoções da Hora"]),
        ("promocoesdahora.com.br/swagger", ["Projetos", "Promoções da Hora"]),
        ("dashboard.render.com", ["Projetos", "Promoções da Hora"]),
        ("dev.azure.com/promocoesdahora", ["Projetos", "Promoções da Hora"]),
        ("dev.azure.com/raphaelpcampos", ["Projetos", "Raphael"]),
        ("crontab.cronhub.io", ["Projetos", "Azure"]),
        ("192.168.1.", ["Homelab", "Proxmox 2026"]),
        ("tteck.github.io/proxmox", ["Homelab", "Proxmox 2026"]),
        ("duckdns.org", ["Homelab", "Rede & DNS"]),
        ("letsencrypt.org/pt-br", ["Homelab", "Rede & DNS"]),
        ("wallet.polygon.technology", ["Crypto"]),
        ("quickswap.exchange", ["Crypto"]),
        ("wallet.ton.org", ["Crypto"]),
        ("okx.com", ["Crypto"]),
        ("stakely.io/en/faucet/polygon", ["Crypto"]),
        ("tradeogre.com", ["Crypto"]),
        ("dogpool.co", ["Crypto"]),
        ("youtube.com/watch", ["Crypto"]),
        ("ui.awin.com", ["Marketing & Afiliados"]),
        ("docs.google.com/forms/d/1xv", ["Marketing & Afiliados"]),
        ("docs.google.com/forms/d/e/1faipqlscwrmfr07", ["Marketing & Afiliados"]),
        ("banggood.com/pt/affiliate", ["Marketing & Afiliados"]),
        ("associados.amazon.com.br", ["Marketing & Afiliados"]),
        ("portals.aliexpress.com", ["Marketing & Afiliados"]),
        ("magazinevoce.com.br/magazinemania256", ["Marketing & Afiliados"]),
        ("affiliate.shopee.com.br", ["Marketing & Afiliados"]),
        ("accounts.clickbank.com", ["Marketing & Afiliados"]),
        ("myaccount.payoneer.com", ["Marketing & Afiliados"]),
        ("pixabay.com", ["Mídia & Criação"]),
        ("cymatics.fm", ["Mídia & Criação"]),
        ("pt.greenconvert.net/youtube-mp3", ["Mídia & Criação"]),
        ("y2meta.app", ["Mídia & Criação"]),
        ("y2mate.nu", ["Mídia & Criação"]),
        ("elevenlabs.io", ["Mídia & Criação"]),
        ("musopen.org", ["Mídia & Criação"]),
        ("app.leonardo.ai", ["Mídia & Criação"]),
        ("app.runwayml.com", ["Mídia & Criação"]),
        ("capcut.com/my-edit", ["Mídia & Criação"]),
        ("apsystemsema.com", ["_Revisar"]),
    ]

    for needle, folder in rules:
        if needle in norm or needle in url:
            return folder

    return ["_Revisar"]


def display_name(entry: BookmarkEntry) -> str:
    norm = entry.norm.lower()
    url = entry.url.lower()
    for key, label in sorted(DISPLAY_NAME_OVERRIDES.items(), key=lambda item: -len(item[0])):
        if key in norm or key in url:
            return label
    return entry.name.strip()


def build_url_node(entry: BookmarkEntry, node_id: str) -> dict:
    name = display_name(entry)
    node = {
        "date_added": entry.node.get("date_added") or chrome_timestamp(),
        "date_last_used": entry.node.get("date_last_used", "0"),
        "guid": entry.node.get("guid") or new_guid(),
        "id": node_id,
        "name": name,
        "type": "url",
        "url": entry.url,
    }
    if entry.node.get("meta_info"):
        node["meta_info"] = entry.node["meta_info"]
    return node


def build_folder(name: str, children: list[dict], node_id: str) -> dict:
    now = chrome_timestamp()
    return {
        "children": children,
        "date_added": now,
        "date_last_used": "0",
        "date_modified": now,
        "guid": new_guid(),
        "id": node_id,
        "name": name,
        "type": "folder",
    }


def nest_folders(path_parts: list[str], url_node: dict, folders: dict) -> None:
    if not path_parts:
        return
    top = path_parts[0]
    if len(path_parts) == 1:
        folders[top].append(url_node)
        return
    sub_name = path_parts[1]
    if top not in folders["_subfolders"]:
        folders["_subfolders"][top] = {}
    sub_map: dict[str, list] = folders["_subfolders"][top]
    if sub_name not in sub_map:
        sub_map[sub_name] = []
    if len(path_parts) == 2:
        sub_map[sub_name].append(url_node)
    else:
        raise ValueError(f"Unexpected depth > 2: {path_parts}")


def build_bookmark_bar_children(
    grouped: dict[tuple[str, ...], list[BookmarkEntry]], id_counter: list[int]
) -> list[dict]:
    folders: dict = {"_subfolders": {}}
    for key in BAR_FOLDER_ORDER:
        folders[key] = []

    def next_id() -> str:
        id_counter[0] += 1
        return str(id_counter[0])

    for folder_path, entries in sorted(grouped.items(), key=lambda item: (BAR_FOLDER_ORDER.index(item[0][0]) if item[0] and item[0][0] in BAR_FOLDER_ORDER else 999, item[0])):
        for entry in entries:
            node = build_url_node(entry, next_id())
            if len(folder_path) == 1:
                folders[folder_path[0]].append(node)
            elif len(folder_path) == 2:
                nest_folders(list(folder_path), node, folders)
            else:
                folders["_Revisar"].append(node)

    children: list[dict] = []
    for folder_name in BAR_FOLDER_ORDER:
        sub_map = folders["_subfolders"].get(folder_name, {})
        direct = folders.get(folder_name, [])
        if not direct and not sub_map:
            continue
        sub_children: list[dict] = []
        for sub_name in sorted(sub_map.keys()):
            sub_items = sub_map[sub_name]
            if sub_items:
                sub_children.append(build_folder(sub_name, sub_items, next_id()))
        sub_children.extend(direct)
        children.append(build_folder(folder_name, sub_children, next_id()))

    return children


def reorganize(data: dict) -> tuple[dict, dict]:
    entries = collect_entries(data)
    report = {
        "before": {"urls": len(entries), "folders": 0},
        "removed": [],
        "merged": [],
        "unmapped": [],
        "after": {},
    }

    folder_count = 0

    def count_folders(node: dict) -> None:
        nonlocal folder_count
        if node.get("type") == "folder":
            folder_count += 1
            for child in node.get("children", []):
                count_folders(child)

    for root_key in data.get("roots", {}):
        count_folders(data["roots"][root_key])
    report["before"]["folders"] = folder_count

    kept: list[BookmarkEntry] = []
    for entry in entries:
        if entry.root_key != "bookmark_bar":
            kept.append(entry)
            continue
        reason = should_exclude(entry)
        if reason:
            report["removed"].append(
                {"name": entry.name, "url": entry.url, "path": entry.path, "reason": reason}
            )
        else:
            kept.append(entry)

    bar_entries = [e for e in kept if e.root_key == "bookmark_bar"]
    other_entries = [e for e in kept if e.root_key != "bookmark_bar"]

    by_norm: dict[str, list[BookmarkEntry]] = defaultdict(list)
    for entry in bar_entries:
        by_norm[entry.norm].append(entry)

    winners: list[BookmarkEntry] = []
    for norm, group in by_norm.items():
        if not norm:
            continue
        group_sorted = sorted(group, key=lambda e: e.score(), reverse=True)
        winner = group_sorted[0]
        winners.append(winner)
        for loser in group_sorted[1:]:
            report["merged"].append(
                {
                    "kept_name": winner.name,
                    "kept_path": winner.path,
                    "dropped_name": loser.name,
                    "dropped_path": loser.path,
                    "url": winner.url,
                }
            )

    grouped: dict[tuple[str, ...], list[BookmarkEntry]] = defaultdict(list)
    for entry in winners:
        folder = tuple(resolve_folder(entry))
        grouped[folder].append(entry)
        if folder == ("_Revisar",):
            report["unmapped"].append({"name": entry.name, "url": entry.url, "old_path": entry.path})

    id_counter = [10]
    bar_children = build_bookmark_bar_children(grouped, id_counter)

    now = chrome_timestamp()
    new_data = {
        "checksum": data.get("checksum", ""),
        "roots": {
            "bookmark_bar": {
                "children": bar_children,
                "date_added": data["roots"]["bookmark_bar"].get("date_added", now),
                "date_last_used": "0",
                "date_modified": now,
                "guid": data["roots"]["bookmark_bar"].get("guid", new_guid()),
                "id": "1",
                "name": "Bookmarks bar",
                "type": "folder",
            },
            "other": data["roots"].get("other", {"children": [], "type": "folder", "name": "Other bookmarks"}),
            "synced": data["roots"].get("synced"),
        },
        "version": data.get("version", 1),
    }
    if data.get("sync_metadata"):
        new_data["sync_metadata"] = data["sync_metadata"]

    after_urls = len(winners) + len(other_entries)
    after_folders = sum(1 for _ in walk_folder_names(new_data["roots"]["bookmark_bar"]))
    report["after"] = {"urls": after_urls, "folders": after_folders, "bar_urls": len(winners)}
    return new_data, report


def walk_folder_names(node: dict):
    if node.get("type") == "folder":
        yield node.get("name", "")
        for child in node.get("children", []):
            yield from walk_folder_names(child)


def count_urls(node: dict) -> int:
    if node.get("type") == "url":
        return 1
    return sum(count_urls(child) for child in node.get("children", []))


def has_empty_reorganized_folders(bookmark_bar: dict) -> bool:
    targets = set(BAR_FOLDER_ORDER)
    for child in bookmark_bar.get("children", []):
        if child.get("type") != "folder":
            continue
        if child.get("name") in targets and count_urls(child) == 0:
            return True
    return False


def find_original_backup(bookmarks_dir: Path) -> Path | None:
    best: Path | None = None
    best_urls = 0
    for path in sorted(bookmarks_dir.glob("Bookmarks.backup.*")):
        try:
            data = json.loads(path.read_text(encoding="utf-8"))
            bar = data["roots"]["bookmark_bar"]
            if has_empty_reorganized_folders(bar):
                continue
            if any(c.get("name") == "Uso frequente" for c in bar.get("children", [])):
                continue
            urls = count_urls(bar)
            if urls > best_urls:
                best_urls = urls
                best = path
        except (json.JSONDecodeError, KeyError):
            continue
    return best


def is_broken_bookmark_bar(bar: dict) -> bool:
    children = bar.get("children", [])
    if count_urls(bar) < 10:
        return True
    if any(c.get("name") in ("Imported", "Imported (1)") for c in children):
        return True
    if has_empty_reorganized_folders(bar):
        return True
    has_imported = any(c.get("name") in ("Imported", "Imported (1)") for c in children)
    has_new_folders = any(c.get("name") in BAR_FOLDER_ORDER for c in children if c.get("type") == "folder")
    if has_imported and has_new_folders:
        return True
    loose_urls = sum(1 for c in children if c.get("type") == "url")
    return loose_urls > 3


def find_valid_reorganized(bookmarks_dir: Path) -> Path | None:
    path = bookmarks_dir / "Bookmarks.reorganized.json"
    if not path.exists():
        return None
    try:
        data = json.loads(path.read_text(encoding="utf-8"))
        if not verify_applied_structure(data["roots"]["bookmark_bar"]):
            return path
    except (json.JSONDecodeError, KeyError):
        return None
    return None


def resolve_source_input(source: Path) -> Path:
    data = json.loads(source.read_text(encoding="utf-8"))
    bar = data["roots"]["bookmark_bar"]
    if not is_broken_bookmark_bar(bar):
        return source

    backup = find_original_backup(source.parent)
    if backup:
        print("WARN: Live bookmarks broken, empty or merged by Chrome Sync.")
        print(f"WARN: Using original backup as input: {backup.name}")
        return backup

    reorganized = find_valid_reorganized(source.parent)
    if reorganized:
        print("WARN: Using cached Bookmarks.reorganized.json as input.")
        return reorganized

    return source


def export_bookmarks_html(data: dict, path: Path) -> None:
    lines = [
        "<!DOCTYPE NETSCAPE-Bookmark-file-1>",
        "<META HTTP-EQUIV=\"Content-Type\" CONTENT=\"text/html; charset=UTF-8\">",
        "<TITLE>Bookmarks</TITLE>",
        "<H1>Bookmarks</H1>",
        "<DL><p>",
    ]

    def walk_folder(node: dict, depth: int) -> None:
        indent = "    " * depth
        for child in node.get("children", []):
            if child.get("type") == "folder":
                lines.append(f"{indent}<DT><H3>{html.escape(child.get('name', ''))}</H3>")
                lines.append(f"{indent}<DL><p>")
                walk_folder(child, depth + 1)
                lines.append(f"{indent}</DL><p>")
            elif child.get("type") == "url":
                name = html.escape(child.get("name", ""))
                url = html.escape(child.get("url", ""), quote=True)
                lines.append(f"{indent}<DT><A HREF=\"{url}\">{name}</A>")

    walk_folder(data["roots"]["bookmark_bar"], 1)
    lines.append("</DL><p>")
    path.write_text("\n".join(lines), encoding="utf-8")


def print_definitive_sync_guide(html_path: Path) -> None:
    print()
    print("=" * 60)
    print("FLUXO DEFINITIVO (Chrome Sync de favoritos)")
    print("=" * 60)
    print()
    print("Por que volta a bagunca: a NUVEM ainda guarda os favoritos antigos.")
    print("Ao reativar sync, o Chrome MESCLA local + nuvem (nao substitui).")
    print()
    print("PASSO 1 - Em TODOS os dispositivos (PC, celular, outros PCs):")
    print("  chrome://settings/syncSetup -> DESMARQUE 'Favoritos'")
    print("  No Android: Chrome -> Configuracoes -> Sincronizacao -> Favoritos OFF")
    print()
    print("PASSO 2 - So neste PC (Chrome FECHADO, ja aplicado pelo script):")
    print("  Abra o Chrome e valide a barra de favoritos.")
    print(f"  Backup HTML: {html_path}")
    print()
    print("PASSO 3 - Substituir a copia na nuvem (escolha UMA opcao):")
    print()
    print("  OPCAO A (recomendada) - Reset Sync:")
    print("    chrome://settings/syncSetup")
    print("    -> 'Limpar dados e comecar de novo' / Reset sync")
    print("    Isso apaga TODOS os dados sincronizados na nuvem e reenvia do local.")
    print("    Faca SOMENTE com a barra local ja correta.")
    print("    Depois entre de novo na conta Google no Chrome.")
    print()
    print("  OPCAO B - Upload controlado (sem reset total):")
    print("    a) Mantenha Favoritos OFF em celular e outros PCs por 24h")
    print("    b) Neste PC: ligue APENAS 'Favoritos' no sync")
    print("    c) Aguarde 5-10 min; confira chrome://sync-internals/")
    print("    d) So entao ligue Favoritos no celular (vai baixar do servidor)")
    print()
    print("  OPCAO C - Nunca mais sync de favoritos:")
    print("    Mantenha 'Favoritos' desmarcado no sync para sempre.")
    print(f"    Use o HTML em {html_path} para importar se precisar.")
    print()
    print("NAO reative sync de favoritos no celular ANTES do PC enviar a versao limpa.")
    print("=" * 60)


def kill_chrome_processes() -> None:
    if sys.platform == "win32":
        for name in ("chrome.exe", "GoogleCrashHandler.exe", "GoogleCrashHandler64.exe"):
            subprocess.run(
                ["taskkill", "/F", "/IM", name],
                capture_output=True,
                text=True,
                check=False,
            )
    else:
        subprocess.run(["pkill", "-f", "chrome"], capture_output=True, check=False)


def chrome_is_running() -> bool:
    if sys.platform == "win32":
        result = subprocess.run(
            ["tasklist", "/FI", "IMAGENAME eq chrome.exe"],
            capture_output=True,
            text=True,
            check=False,
        )
        return "chrome.exe" in result.stdout
    result = subprocess.run(["pgrep", "-f", "chrome"], capture_output=True, text=True, check=False)
    return bool(result.stdout.strip())


def verify_applied_structure(bookmark_bar: dict) -> list[str]:
    errors: list[str] = []
    children = bookmark_bar.get("children", [])
    if any(c.get("name") in ("Imported", "Imported (1)") for c in children):
        errors.append("Imported folders still present at bookmark bar root")
    if any(c.get("name") == "Bookmarks bar" for c in children if c.get("type") == "folder"):
        errors.append("Nested 'Bookmarks bar' folder still present")

    fin = next((c for c in children if c.get("name") == "Finanças"), None)
    if not fin or count_urls(fin) < 2:
        errors.append("Finanças folder missing or has too few bookmarks")

    uso = next((c for c in children if c.get("name") == "Uso frequente"), None)
    if not uso or count_urls(uso) < 1:
        errors.append("Uso frequente folder missing or empty")

    loose_urls = [c for c in children if c.get("type") == "url"]
    if len(loose_urls) > 2:
        errors.append(f"Too many loose URLs at bar root ({len(loose_urls)})")

    empty_named = [
        c.get("name", "?")
        for c in children
        if c.get("type") == "folder" and c.get("name") in BAR_FOLDER_ORDER and count_urls(c) == 0
    ]
    if empty_named:
        errors.append(f"Empty reorganized folders: {', '.join(empty_named)}")

    return errors


def write_report(report: dict, path: Path) -> None:
    lines = [
        "Chrome Bookmarks Reorganization Report",
        "=" * 40,
        f"Before: {report['before']['urls']} URLs, {report['before']['folders']} folders",
        f"After:  {report['after']['urls']} URLs, {report['after']['folders']} folders (bar: {report['after']['bar_urls']})",
        "",
        f"Removed ({len(report['removed'])}):",
    ]
    for item in report["removed"]:
        lines.append(f"  [{item['reason']}] {item['name']}")
        lines.append(f"    {item['url']}")
        lines.append(f"    @ {item['path']}")
    lines.append("")
    lines.append(f"Merged duplicates ({len(report['merged'])}):")
    for item in report["merged"]:
        lines.append(f"  KEPT: {item['kept_name']} @ {item['kept_path']}")
        lines.append(f"  DROP: {item['dropped_name']} @ {item['dropped_path']}")
    lines.append("")
    lines.append(f"Unmapped -> _Revisar ({len(report['unmapped'])}):")
    for item in report["unmapped"]:
        lines.append(f"  {item['name']}")
        lines.append(f"    {item['url']}")
    path.write_text("\n".join(lines), encoding="utf-8")


def main() -> int:
    parser = argparse.ArgumentParser(description="Reorganize Chrome bookmarks JSON.")
    parser.add_argument("--input", type=Path, default=DEFAULT_BOOKMARKS, help="Source Bookmarks file")
    parser.add_argument("--apply", action="store_true", help="Replace live Bookmarks file")
    parser.add_argument(
        "--kill-chrome",
        action="store_true",
        help="Force-close Chrome before --apply (default when --apply)",
    )
    parser.add_argument(
        "--no-kill-chrome",
        action="store_true",
        help="Do not force-close Chrome (not recommended with --apply)",
    )
    parser.add_argument(
        "--definitive",
        action="store_true",
        help="Apply + export HTML + print definitive Chrome Sync workflow",
    )
    args = parser.parse_args()

    if args.definitive:
        args.apply = True

    live_bookmarks = DEFAULT_BOOKMARKS.expanduser().resolve()
    requested = args.input.expanduser().resolve()
    if not requested.exists():
        print(f"ERROR: Bookmarks file not found: {requested}")
        return 1

    if requested == live_bookmarks:
        source = resolve_source_input(requested)
    else:
        source = requested

    if args.apply and not args.no_kill_chrome:
        if chrome_is_running():
            print("Closing Chrome processes...")
            kill_chrome_processes()
            if chrome_is_running():
                print("ERROR: Chrome is still running. Close it manually and retry.")
                return 1

    stamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    backup_path = live_bookmarks.parent / f"Bookmarks.backup.{stamp}"
    output_path = live_bookmarks.parent / "Bookmarks.reorganized.json"
    report_path = live_bookmarks.parent / f"Bookmarks.reorganization-report.{stamp}.txt"

    if live_bookmarks.exists():
        shutil.copy2(live_bookmarks, backup_path)
        print(f"Backup (live): {backup_path}")

    print(f"Input: {source}")

    with source.open(encoding="utf-8") as handle:
        data = json.load(handle)

    new_data, report = reorganize(data)

    with output_path.open("w", encoding="utf-8") as handle:
        json.dump(new_data, handle, ensure_ascii=False, indent=3)
    print(f"Output: {output_path}")

    write_report(report, report_path)
    print(f"Report: {report_path}")
    print(f"Summary: {report['before']['urls']} -> {report['after']['urls']} URLs, "
          f"{report['before']['folders']} -> {report['after']['folders']} folders")
    print(f"Removed: {len(report['removed'])}, Merged: {len(report['merged'])}, _Revisar: {len(report['unmapped'])}")

    if args.apply:
        shutil.copy2(output_path, live_bookmarks)
        print(f"Applied: {live_bookmarks}")
        applied = json.loads(live_bookmarks.read_text(encoding="utf-8"))
        errors = verify_applied_structure(applied["roots"]["bookmark_bar"])
        if errors:
            print("VERIFY FAILED:")
            for err in errors:
                print(f"  - {err}")
            return 1
        bar = applied["roots"]["bookmark_bar"]
        print(f"Verified: {count_urls(bar)} bookmarks in bar, {len(bar.get('children', []))} top-level items")
        html_path = live_bookmarks.parent / f"Bookmarks.export.{stamp}.html"
        export_bookmarks_html(applied, html_path)
        print(f"HTML export: {html_path}")
        print_validation_checklist(backup_path)
        if args.definitive:
            print_definitive_sync_guide(html_path)
        else:
            print()
            print("IMPORTANT: Desative sync de Favoritos em TODOS os dispositivos antes de abrir o Chrome.")
            print("Para fluxo completo anti-sync, rode com --definitive")
    else:
        print()
        print("Next steps:")
        print("  1. Close Chrome completely")
        print(f"  2. Review {report_path}")
        print("  3. Run with --apply OR copy Bookmarks.reorganized.json over Bookmarks")
        print("  4. Open Chrome and run validation checklist (printed after --apply)")


def print_validation_checklist(backup_path: Path) -> None:
    print()
    print("Validation checklist (after opening Chrome):")
    print("  [ ] No Imported / nested Bookmarks bar folders")
    print("  [ ] DeepL, Gastos and Despesas appear once under Finanças")
    print("  [ ] Homelab > Proxmox 2026 has only the 2026 LAN stack")
    print("  [ ] Promoções da Hora has site, Swagger and Azure DevOps")
    print("  [ ] Paused bookmark sync before opening Chrome")
    print(f"  [ ] If something is wrong: restore {backup_path}")


if __name__ == "__main__":
    raise SystemExit(main())

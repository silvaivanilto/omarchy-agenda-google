"""Lightweight bilingual (en / pt-BR) message helper for the CLI and OAuth flow."""

from __future__ import annotations

import json
import os
from pathlib import Path

DEFAULT_SETTINGS_PATH = (
    Path.home()
    / ".local"
    / "state"
    / "omarchy"
    / "calendar-agenda"
    / "settings.json"
)


def is_pt_br() -> bool:
    """Return True when Portuguese (Brazil) is configured or active in the locale."""
    try:
        raw = json.loads(DEFAULT_SETTINGS_PATH.read_text(encoding="utf-8"))
        if isinstance(raw, dict):
            lang = raw.get("language")
            if lang == "pt-BR":
                return True
            if lang == "en":
                return False
    except (OSError, json.JSONDecodeError):
        pass
    locale = (
        os.environ.get("LC_ALL")
        or os.environ.get("LC_MESSAGES")
        or os.environ.get("LANG")
        or ""
    ).lower()
    return locale.startswith("pt")


def msg(en: str, pt: str) -> str:
    """Return the localized string for the active language."""
    return pt if is_pt_br() else en

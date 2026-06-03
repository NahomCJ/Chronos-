"""
Tier 0 response cache for transaction classification.

Cache keys are normalized merchant strings, not transaction IDs. This lets the
same merchant description reuse a previous result across users without storing
user-specific data.
"""

from __future__ import annotations

import logging
import re
import threading
from typing import Any

from cachetools import TTLCache

logger = logging.getLogger("TransactionClassifierCache")

CACHE_MAXSIZE = 10_000
CACHE_TTL_SECONDS = 86_400

_cache: TTLCache[str, dict[str, Any]] = TTLCache(
    maxsize=CACHE_MAXSIZE,
    ttl=CACHE_TTL_SECONDS,
)
_lock = threading.RLock()


def normalize_merchant_key(text: str) -> str:
    value = str(text or "").upper()
    value = re.sub(r"#\S+", " ", value)
    value = re.sub(r"\bTXN\S*\b", " ", value)
    value = re.sub(r"\b(?:AUTH|POS|CARD|PURCHASE|ONLINE|RECURRING)\b", " ", value)
    value = re.sub(r"\d+", " ", value)
    value = re.sub(r"[^A-Z& ]+", " ", value)
    return re.sub(r"\s+", " ", value).strip()


def get_cached(text: str) -> dict[str, Any] | None:
    key = normalize_merchant_key(text)
    if not key:
        return None
    with _lock:
        cached = _cache.get(key)
    if cached is None:
        logger.info("tier0_cache_miss key=%s", key)
        return None
    logger.info("tier0_cache_hit key=%s", key)
    return dict(cached)


def set_cached(text: str, result: dict[str, Any]) -> None:
    key = normalize_merchant_key(text)
    if not key:
        return
    with _lock:
        _cache[key] = dict(result)


def clear_cache() -> None:
    with _lock:
        _cache.clear()

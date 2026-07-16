"""
Tier 3 Claude fallback for low-confidence transaction classifications.

The Anthropic prompt receives only sanitized transaction text and user_id. Local
transaction IDs are kept out of the prompt and used only to write results back
to Panther's database after classification.
"""

from __future__ import annotations

import json
import logging
import os
import queue
import re
import threading
import time
from dataclasses import dataclass
from typing import Any

from dotenv import load_dotenv

from .taxonomy import TAXONOMY

load_dotenv()

logger = logging.getLogger("Tier3ClassifierQueue")

CLAUDE_MODEL = os.getenv("PANTHER_TIER3_CLAUDE_MODEL", "claude-opus-4-6")
DEFAULT_BATCH_SIZE = int(os.getenv("PANTHER_TIER3_BATCH_SIZE", "20"))
DEFAULT_FLUSH_SECONDS = float(os.getenv("PANTHER_TIER3_FLUSH_SECONDS", "2.0"))

_VALID_SUBCATEGORIES = {
    subcategory["id"]
    for category in TAXONOMY["taxonomy"]
    for subcategory in category["subcategories"]
}

CLASSIFICATION_SYSTEM_PROMPT = f"""\
You classify banking transaction descriptions into Panther's transaction taxonomy.

Return only valid JSON. Do not include explanations.
Each output item must be:
{{"index": <input index>, "subcategory": "<one valid subcategory id>"}}

Valid subcategory ids:
{json.dumps(sorted(_VALID_SUBCATEGORIES))}

Use only the sanitized transaction description and user_id in each input item.
Do not infer or expose personal details. Do not return confidence scores.
"""


@dataclass(frozen=True)
class Tier3Transaction:
    transaction_id: str
    user_id: str
    description: str


class Tier3ClassifierQueue:
    def __init__(
        self,
        batch_size: int = DEFAULT_BATCH_SIZE,
        flush_seconds: float = DEFAULT_FLUSH_SECONDS,
    ):
        self.batch_size = batch_size
        self.flush_seconds = flush_seconds
        self._queue: queue.Queue[Tier3Transaction] = queue.Queue()
        self._started = False
        self._start_lock = threading.Lock()
        self.processed_results: dict[str, str] = {}

    def enqueue(self, transaction: Tier3Transaction) -> None:
        self._queue.put(transaction)
        self._ensure_worker()
        logger.info("tier3_enqueue transaction_id=%s", transaction.transaction_id)

    def process_once(self) -> int:
        batch = self._drain_batch(block=False)
        if not batch:
            return 0
        self._process_batch(batch)
        return len(batch)

    def flush(self, timeout_seconds: float = 10.0) -> None:
        deadline = time.monotonic() + timeout_seconds
        while not self._queue.empty() and time.monotonic() < deadline:
            self.process_once()

    def _ensure_worker(self) -> None:
        with self._start_lock:
            if self._started:
                return
            worker = threading.Thread(target=self._run, name="tier3-classifier", daemon=True)
            worker.start()
            self._started = True

    def _run(self) -> None:
        while True:
            batch = self._drain_batch(block=True)
            if batch:
                self._process_batch(batch)

    def _drain_batch(self, block: bool) -> list[Tier3Transaction]:
        batch: list[Tier3Transaction] = []
        try:
            first = self._queue.get(block=block, timeout=self.flush_seconds if block else 0)
            batch.append(first)
        except queue.Empty:
            return batch

        deadline = time.monotonic() + self.flush_seconds
        while len(batch) < self.batch_size and time.monotonic() < deadline:
            try:
                batch.append(self._queue.get_nowait())
            except queue.Empty:
                break
        return batch

    def _process_batch(self, batch: list[Tier3Transaction]) -> None:
        try:
            classifications = classify_with_claude(batch)
            for transaction in batch:
                subcategory = classifications.get(transaction.transaction_id)
                if not subcategory:
                    continue
                self._save_result(transaction.transaction_id, subcategory)
        except Exception as exc:
            logger.exception("tier3_batch_failed error=%s", type(exc).__name__)

    def _save_result(self, transaction_id: str, subcategory: str) -> None:
        self.processed_results[transaction_id] = subcategory
        sb = _get_supabase()
        if not sb:
            return
        (
            sb.table("transactions")
            .update(
                {
                    "subcategory": subcategory,
                    "category_source": "Claude",
                    "category_confidence": None,
                    "user_corrected": False,
                }
            )
            .eq("id", transaction_id)
            .execute()
        )


def enqueue_low_confidence_transaction(
    transaction_id: str,
    user_id: str,
    description: str,
    classifier_queue: Tier3ClassifierQueue | None = None,
) -> None:
    target_queue = classifier_queue or get_tier3_queue()
    target_queue.enqueue(
        Tier3Transaction(
            transaction_id=transaction_id,
            user_id=user_id,
            description=sanitize_transaction_text(description),
        )
    )


def classify_with_claude(batch: list[Tier3Transaction]) -> dict[str, str]:
    import anthropic

    api_key = os.getenv("ANTHROPIC_API_KEY")
    if not api_key:
        raise RuntimeError("ANTHROPIC_API_KEY is required for Tier 3 classification")

    client = anthropic.Anthropic(api_key=api_key)
    prompt_payload = {
        "transactions": [
            {
                "index": index,
                "user_id": transaction.user_id,
                "description": sanitize_transaction_text(transaction.description),
            }
            for index, transaction in enumerate(batch)
        ]
    }

    response = client.messages.create(
        model=CLAUDE_MODEL,
        max_tokens=1000,
        system=[
            {
                "type": "text",
                "text": CLASSIFICATION_SYSTEM_PROMPT,
                "cache_control": {"type": "ephemeral"},
            }
        ],
        messages=[{"role": "user", "content": json.dumps(prompt_payload)}],
    )

    raw_text = response.content[0].text
    parsed = _parse_claude_json(raw_text)
    output: dict[str, str] = {}
    for item in parsed:
        index = int(item.get("index", -1))
        subcategory = str(item.get("subcategory", ""))
        if 0 <= index < len(batch) and subcategory in _VALID_SUBCATEGORIES:
            output[batch[index].transaction_id] = subcategory
    return output


def sanitize_transaction_text(text: str) -> str:
    sanitized = str(text or "")
    sanitized = re.sub(r"[\w.+-]+@[\w.-]+\.\w+", "[redacted-email]", sanitized)
    sanitized = re.sub(r"\b(?:\+?1[-.\s]?)?(?:\(?\d{3}\)?[-.\s]?)\d{3}[-.\s]?\d{4}\b", "[redacted-phone]", sanitized)
    sanitized = re.sub(r"\b\d{4,}\b", "[redacted-number]", sanitized)
    sanitized = re.sub(r"#\S+", "", sanitized)
    sanitized = re.sub(r"\s+", " ", sanitized).strip()
    return sanitized[:160]


def _parse_claude_json(text: str) -> list[dict[str, Any]]:
    stripped = text.strip()
    if stripped.startswith("```"):
        stripped = re.sub(r"^```(?:json)?\s*", "", stripped)
        stripped = re.sub(r"\s*```$", "", stripped)
    parsed = json.loads(stripped)
    if not isinstance(parsed, list):
        raise ValueError("Claude Tier 3 response must be a JSON array")
    return parsed


def _get_supabase():
    url = os.getenv("SUPABASE_URL")
    key = os.getenv("SUPABASE_KEY")
    if not url or not key:
        return None
    try:
        from supabase import create_client

        return create_client(url, key)
    except Exception:
        return None


_QUEUE: Tier3ClassifierQueue | None = None
_QUEUE_LOCK = threading.Lock()


def get_tier3_queue() -> Tier3ClassifierQueue:
    global _QUEUE
    with _QUEUE_LOCK:
        if _QUEUE is None:
            _QUEUE = Tier3ClassifierQueue()
        return _QUEUE

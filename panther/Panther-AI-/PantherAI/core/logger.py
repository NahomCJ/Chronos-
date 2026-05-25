"""
Structured Logger — JSON-only, machine-readable logging for CHRONOS.

Every log line is a JSON object. No print(). No unstructured messages.
Instrument only contract boundaries (functions imported by other modules
or that touch external data). Internal helpers stay quiet.

Usage:
    from core.logger import log, contract

    log.contract("process_request", user_id="user_123", amount=200.0)

    @contract
    def authorize_payment(request: PaymentRequest) -> dict:
        ...
"""

import functools
import json
import logging
import time
from datetime import datetime, timezone


# ADR: All logging is local (stderr / file). No external services, no Datadog,
# no OpenTelemetry. Post-MVP, plug into any platform by swapping the handler
# in __init__ — zero changes to call sites.

class StructuredLogger:
    """
    Single structured logger for CHRONOS. All output is JSON.

    Every log line is a self-contained JSON object — machine-readable,
    grep-able, and ready to pipe into any external platform post-MVP.

    Usage:
        from core.logger import log
        log.contract("process_request", user_id="user_123", amount=200.0)
    """

    def __init__(self, name: str = "chronos"):
        self._logger = logging.getLogger(name)
        if not self._logger.handlers:
            handler = logging.StreamHandler()
            handler.setFormatter(logging.Formatter("%(message)s"))
            self._logger.addHandler(handler)
        self._logger.setLevel(logging.DEBUG)

    def _emit(self, level: str, event: str, **kwargs):
        record = {
            "ts": datetime.now(timezone.utc).isoformat(),
            "level": level,
            "event": event,
            **kwargs,
        }
        self._logger.info(json.dumps(record, default=str))

    def contract(self, fn_name: str, **kwargs):
        """
        Log a contract boundary call.

        Args:
            fn_name (str): Name of the function being called.
            **kwargs: Arbitrary context (user_id, amount, etc.).
        """
        self._emit("CONTRACT", fn_name, **kwargs)

    def result(self, fn_name: str, duration_ms: float, **kwargs):
        """
        Log the successful result of a contract boundary call.

        Args:
            fn_name (str): Name of the function that returned.
            duration_ms (float): Wall-clock time in milliseconds.
            **kwargs: Arbitrary result context (result_preview, etc.).
        """
        self._emit("RESULT", fn_name, duration_ms=round(duration_ms, 2), **kwargs)

    def failure(self, fn_name: str, error_type: str, message: str, **kwargs):
        """
        Log a contract boundary failure (exception was raised).

        Args:
            fn_name (str): Name of the function that failed.
            error_type (str): Exception class name (e.g. "ValueError").
            message (str): Exception message string.
            **kwargs: Arbitrary failure context (duration_ms, etc.).
        """
        self._emit("FAILURE", fn_name, error_type=error_type, message=message, **kwargs)

    def phase(self, transition: str, module: str):
        """
        Log a phase transition (e.g. server startup, Phase 1 → Phase 2 switch).

        Args:
            transition (str): Identifier for the transition (e.g. "server_started").
            module (str): Module where the transition occurs (e.g. "main").
        """
        self._emit("PHASE_TRANSITION", transition, module=module)


log = StructuredLogger()


# ---------------------------------------------------------------------------
# @contract decorator
# ---------------------------------------------------------------------------

def contract(fn):
    """
    Decorator for contract boundary functions.

    Apply to every public function at a module boundary.
    Automatically logs input, output, duration, and exceptions.

    Usage:
        @contract
        def authorize_payment(request: PaymentRequest) -> dict:
            ...

    What it logs:
        - CONTRACT: function called with these args
        - RESULT: function returned this, took Xms
        - FAILURE: function raised this exception
    """

    @functools.wraps(fn)
    def wrapper(*args, **kwargs):
        fn_name = fn.__name__
        start = time.perf_counter()

        # Log the contract call
        log.contract(fn_name, args=str(args[:2]), kwargs=str(kwargs))

        try:
            result = fn(*args, **kwargs)
            duration_ms = (time.perf_counter() - start) * 1000

            # Log success — truncate large outputs
            result_preview = str(result)[:200] if result else None
            log.result(fn_name, duration_ms=duration_ms, result_preview=result_preview)

            return result

        except Exception as e:
            duration_ms = (time.perf_counter() - start) * 1000
            log.failure(
                fn_name,
                error_type=type(e).__name__,
                message=str(e),
                duration_ms=duration_ms,
            )
            raise  # Never swallow — always re-raise

    return wrapper

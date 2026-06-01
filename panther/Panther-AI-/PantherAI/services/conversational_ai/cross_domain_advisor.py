"""
services/conversational_ai/cross_domain_advisor.py
====================================================
B8 — Cross-Domain Advisor.

When a query spans multiple financial domains (banking + crypto + marketplace, etc.),
this module fires all relevant tools in parallel, then compiles a single coherent
answer using Chris.

Example query: "Given my bank balance, crypto P&L, and upcoming bills — can I afford to invest $500?"

Flow:
  1. Detect which domains the query touches (via router.py)
  2. Fire all relevant tools concurrently (ThreadPoolExecutor — tools are sync)
  3. Build a unified context dict from all tool results
  4. Pass full context to Chris with a cross-domain system prompt
  5. Return a single response

The caller (router or voice endpoint) calls advise(user_id, query).
"""

from __future__ import annotations

import concurrent.futures
from typing import Any

from services.conversational_ai.tools import execute_tool, TOOLS_BY_DOMAIN
from services.conversational_ai.router import route_query


# Tools to fire per domain when running a cross-domain query
_DOMAIN_TOOLS: dict[str, list[str]] = {
    "banking":     ["check_balance", "get_upcoming_bills", "get_spending_summary", "get_recurring_charges"],
    "crypto":      ["get_portfolio", "get_crypto_pnl", "get_position_summary"],
    "investment":  ["check_balance", "get_portfolio", "get_crypto_pnl"],
    "marketplace": ["check_balance", "get_upcoming_bills"],
}


def _gather_context(user_id: str, domains: list[str]) -> dict[str, Any]:
    """
    Fires all relevant tools for the given domains concurrently.

    Returns a merged context dict from all tool results.
    Failures in individual tools are caught and recorded without aborting others.
    """
    # Deduplicate tool calls across domains
    tools_to_run: list[str] = []
    seen: set[str] = set()
    for domain in domains:
        for tool in _DOMAIN_TOOLS.get(domain, []):
            if tool not in seen:
                tools_to_run.append(tool)
                seen.add(tool)

    context: dict[str, Any] = {}

    def _call(tool_name: str) -> tuple[str, dict | None]:
        try:
            result = execute_tool(tool_name, user_id, {})
            return tool_name, result
        except Exception as e:
            return tool_name, {"error": str(e)}

    with concurrent.futures.ThreadPoolExecutor(max_workers=6) as pool:
        futures = {pool.submit(_call, t): t for t in tools_to_run}
        for future in concurrent.futures.as_completed(futures):
            tool_name, result = future.result()
            if result:
                context[tool_name] = result

    return context


def _detect_domains(query: str) -> list[str]:
    """
    Determines which domains a query touches.

    Uses the router for primary classification, then applies heuristics to
    detect secondary domains so we can pull data from all relevant sources.
    """
    primary = route_query(query)
    lower = query.lower()

    active: set[str] = {primary}

    if any(w in lower for w in ("balance", "bank", "bills", "spend", "transfer", "send")):
        active.add("banking")
    if any(w in lower for w in ("crypto", "bitcoin", "btc", "eth", "portfolio", "coin", "p&l", "pnl")):
        active.add("crypto")
    if any(w in lower for w in ("invest", "etf", "stock", "allocation", "retire")):
        active.add("investment")
    if any(w in lower for w in ("buy", "shop", "product", "checkout", "bnpl")):
        active.add("marketplace")

    # unified means everything
    if primary == "unified" or len(active) >= 3:
        return list(_DOMAIN_TOOLS.keys())

    return list(active)


def advise(user_id: str, query: str) -> dict[str, Any]:
    """
    Produces a cross-domain financial answer for a query that spans multiple areas.

    Args:
        user_id: Authenticated user ID.
        query:   Natural-language question spanning multiple domains.

    Returns:
        {
            "response":     str,   # Compiled answer from Chris
            "tools_called": list,  # All tools that were fired
            "context_used": dict,  # Merged data from all tools
            "domains":      list,  # Domains detected
        }
    """
    domains = _detect_domains(query)
    context = _gather_context(user_id, domains)

    # Build a context summary string for Chris
    context_lines = []
    for tool_name, data in context.items():
        if isinstance(data, dict) and "error" not in data:
            context_lines.append(f"[{tool_name}]: {data}")

    context_block = "\n".join(context_lines) if context_lines else "No data available."

    # Use Chris to compile the final answer
    from services.conversational_ai.chris import chris_chat

    synthesis_query = (
        f"Here is fresh data pulled from all relevant sources:\n\n{context_block}\n\n"
        f"User's question: {query}\n\n"
        "Answer using only the data above. Be direct. Give one combined answer — "
        "don't make them ask twice."
    )

    result = chris_chat(
        user_id=user_id,
        message=synthesis_query,
        domain="unified",
    )

    return {
        "response": result["response"],
        "tools_called": list(context.keys()),
        "context_used": context,
        "domains": domains,
    }

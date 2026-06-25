"""
scripts/chris_cli.py
=====================
Interactive CLI to chat with Chris through the terminal.

Features:
  - User selection menu at startup (pulls from banking mock data)
  - Structured logging: input, tools called, context, response
  - Multi-turn conversation with history
  - Commands: /clear, /user, /history, /quit

Usage:
    python scripts/chris_cli.py
"""

from __future__ import annotations

import json
import sys
from pathlib import Path
from typing import Any

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

from services.banking.mock_api import LOCAL_MOCK_DATA
from services.conversational_ai.chris import chris_chat


# ---------------------------------------------------------------------------
# Terminal colors
# ---------------------------------------------------------------------------
class Color:
    BLUE = "\033[94m"
    GREEN = "\033[92m"
    YELLOW = "\033[93m"
    RED = "\033[91m"
    DIM = "\033[2m"
    BOLD = "\033[1m"
    RESET = "\033[0m"


# ---------------------------------------------------------------------------
# Logging
# ---------------------------------------------------------------------------
def log(label: str, data: Any, color: str = Color.DIM) -> None:
    """Print a structured log line to the terminal."""
    if isinstance(data, (dict, list)):
        formatted = json.dumps(data, indent=2, default=str)
        print(f"{color}[{label}] {formatted}{Color.RESET}")
    else:
        print(f"{color}[{label}] {data}{Color.RESET}")


# ---------------------------------------------------------------------------
# User selection
# ---------------------------------------------------------------------------
def get_available_users() -> list[dict[str, Any]]:
    """Returns a list of available users with their basic info."""
    users = []
    for user_id, data in LOCAL_MOCK_DATA.items():
        users.append(
            {
                "id": user_id,
                "email": data.get("email", ""),
                "balance": data.get("balance", 0.0),
            }
        )
    return users


def select_user() -> str:
    """Interactive user selection menu. Returns the selected user_id."""
    users = get_available_users()

    print(f"\n{Color.BOLD}Select a user:{Color.RESET}")
    print(f"{Color.DIM}{'─' * 50}{Color.RESET}")

    for i, user in enumerate(users, 1):
        print(
            f"  {Color.BOLD}{i}.{Color.RESET} {user['id']}"
            f" {Color.DIM}({user['email']} — ${user['balance']:,.2f}){Color.RESET}"
        )

    print(f"{Color.DIM}{'─' * 50}{Color.RESET}")

    while True:
        try:
            raw = input(
                f"{Color.BLUE}Enter number (1-{len(users)}): {Color.RESET}"
            ).strip()
            idx = int(raw) - 1
            if 0 <= idx < len(users):
                selected = users[idx]["id"]
                print(f"{Color.DIM}[selected] {selected}{Color.RESET}")
                return selected
        except (ValueError, IndexError):
            pass
        print(f"{Color.RED}Invalid selection.{Color.RESET}")


# ---------------------------------------------------------------------------
# Chat session
# ---------------------------------------------------------------------------
def process_message(
    user_id: str, message: str, history: list[dict]
) -> tuple[dict[str, Any], list[dict]]:
    """
    Sends a message to Chris and returns (result, updated_history).

    Raises ValueError if user_id is unknown.
    """
    log(
        "input",
        {"user_id": user_id, "message": message, "history_length": len(history)},
    )

    result = chris_chat(
        user_id, message, conversation_history=history, history_user_id=user_id
    )

    # Mode indicator
    mode = result.get("mode", "unknown")
    if mode == "llm":
        print(
            f"{Color.GREEN}[mode] LLM ({result.get('debug', {}).get('model', '?')}){Color.RESET}"
        )
    elif mode == "mock":
        reason = result.get("mock_reason", "")
        print(f"{Color.YELLOW}[mode] MOCK — {reason}{Color.RESET}")

    # Debug info (timing, thinking, tools)
    debug = result.get("debug")
    if debug:
        log("model", debug["model"], Color.DIM)
        for step in debug["llm_steps"]:
            label = f"step {step['iteration']}"

            # Show thinking/reasoning if present
            if step.get("thinking"):
                thinking_preview = step["thinking"][:300]
                if len(step["thinking"]) > 300:
                    thinking_preview += "..."
                print(f"{Color.DIM}[{label} thinking] {thinking_preview}{Color.RESET}")

            # Show tool calls
            if step.get("tools"):
                for t in step["tools"]:
                    print(
                        f"{Color.YELLOW}[{label} tool] "
                        f"{t['name']}({json.dumps(t['args'])}) "
                        f"— {t['duration_s']}s{Color.RESET}"
                    )

            # Show token usage
            usage = step.get("usage", {})
            if usage.get("prompt_tokens"):
                print(
                    f"{Color.DIM}[{label}] "
                    f"{step['action']} in {step['duration_s']}s "
                    f"({usage['prompt_tokens']}→{usage['completion_tokens']} tokens)"
                    f"{Color.RESET}"
                )
            else:
                print(
                    f"{Color.DIM}[{label}] "
                    f"{step['action']} in {step['duration_s']}s"
                    f"{Color.RESET}"
                )

        print(f"{Color.DIM}[total] {debug['total_duration_s']}s{Color.RESET}")

    elif result["tools_called"]:
        log("tools_called", result["tools_called"], Color.YELLOW)
        log("context", result["context_used"], Color.DIM)

    conv = result["conversation_history"]
    messages = conv["messages"] if isinstance(conv, dict) else conv
    return result, messages


def handle_command(
    command: str, user_id: str, history: list[dict]
) -> tuple[str, list[dict], bool]:
    """
    Handles slash commands.

    Returns (user_id, history, should_continue).
    """
    cmd = command.lower().strip()

    if cmd in ("/quit", "/exit", "/q"):
        print(f"{Color.DIM}Bye!{Color.RESET}")
        return user_id, history, False

    if cmd == "/clear":
        print(f"{Color.DIM}[history cleared]{Color.RESET}")
        return user_id, [], True

    if cmd == "/user":
        new_user = select_user()
        return new_user, [], True

    if cmd == "/history":
        if not history:
            print(f"{Color.DIM}[no history]{Color.RESET}")
        else:
            for msg in history:
                role_color = Color.BLUE if msg["role"] == "user" else Color.GREEN
                print(f"{role_color}{msg['role']}: {msg['content'][:100]}{Color.RESET}")
        return user_id, history, True

    if cmd == "/help":
        print(f"{Color.DIM}/clear   — reset conversation history{Color.RESET}")
        print(f"{Color.DIM}/user    — switch user{Color.RESET}")
        print(f"{Color.DIM}/history — show conversation history{Color.RESET}")
        print(f"{Color.DIM}/quit    — exit{Color.RESET}")
        return user_id, history, True

    print(
        f"{Color.RED}Unknown command: {command}. Type /help for options.{Color.RESET}"
    )
    return user_id, history, True


def run_chat_loop(user_id: str) -> None:
    """Main chat loop. Handles input, commands, and message processing."""
    history: list[dict] = []

    print(f"\n{Color.BOLD}Chris CLI — Chronos Financial Assistant{Color.RESET}")
    print(f"{Color.DIM}User: {user_id} | Type /help for commands{Color.RESET}")
    print(f"{Color.DIM}{'─' * 60}{Color.RESET}")

    while True:
        try:
            message = input(f"\n{Color.BLUE}{Color.BOLD}You > {Color.RESET}").strip()
        except (KeyboardInterrupt, EOFError):
            print(f"\n{Color.DIM}Bye!{Color.RESET}")
            break

        if not message:
            continue

        if message.startswith("/"):
            user_id, history, should_continue = handle_command(
                message, user_id, history
            )
            if not should_continue:
                break
            continue

        try:
            result, history = process_message(user_id, message, history)
        except ValueError as e:
            print(f"{Color.RED}[error] {e}{Color.RESET}")
            continue

        print(f"\n{Color.GREEN}{Color.BOLD}Chris > {Color.RESET}{result['response']}")


# ---------------------------------------------------------------------------
# Entry point
# ---------------------------------------------------------------------------
def main() -> None:
    user_id = select_user()
    run_chat_loop(user_id)


if __name__ == "__main__":
    main()

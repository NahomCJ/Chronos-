"""
Restructures the Chronos Postman collection into a clean nested folder layout.

New top-level structure:
  1. Health
  2. Auth
  3. Banking
       Home / Dashboard
       Accounts
       Wallets
       Cards
       Transfers
       Transactions
       Deposits (ACH)
       Bills
       FX & Currency
       KYC
  4. TickPay / BNPL
  5. LifeX  (11 sub-modules, unchanged)
  6. Panther AI
       Kevin Chat
       AI Alerts
       User Level
       BNPL Scoring
       Voice
  7. Notifications
  8. BlockHub  (already nested, unchanged)
"""

import json, os, copy

root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
path = os.path.join(root, "Chronos-API.postman_collection.json")

with open(path, "r", encoding="utf-8") as f:
    col = json.load(f)

# ── helpers ────────────────────────────────────────────────────────────────────

def get_folder(name):
    """Return a top-level folder by name."""
    for item in col["item"]:
        if item["name"] == name:
            return copy.deepcopy(item)
    raise KeyError(f"Folder not found: {name!r}")

def get_sub(folder_name, sub_name):
    """Return a sub-folder from a top-level folder."""
    folder = get_folder(folder_name)
    for item in folder.get("item", []):
        if item["name"] == sub_name:
            return copy.deepcopy(item)
    raise KeyError(f"Sub-folder not found: {folder_name!r} > {sub_name!r}")

def folder(name, items):
    return {"name": name, "item": items}

# ── pull raw data ──────────────────────────────────────────────────────────────

auth_folder        = get_folder("Auth")
home_folder        = get_folder("Home")
notif_folder       = get_folder("Notifications")
core_banking       = get_folder("Core Banking")   # already has sub-folders
fx_folder          = get_folder("FX & Currency")
kyc_folder         = get_folder("KYC")
bills_folder       = get_folder("Bills")
tickpay_folder     = get_folder("TickPay (BNPL)")
panther_folder     = get_folder("Panther AI")
lifex_folder       = get_folder("LifeX")
blockhub_folder    = get_folder("BlockHub")

# Main API health request
main_health_req    = get_folder("Health Check")["item"][0]

# BlockHub health request (inside BlockHub > Health)
bh_health_folder   = None
for sub in blockhub_folder["item"]:
    if sub["name"] == "Health":
        bh_health_req = copy.deepcopy(sub["item"][0])
        bh_health_req["name"] = "BlockHub Health"
        break

# Remove the nested Health sub-folder from BlockHub (we're lifting it up)
blockhub_folder["item"] = [s for s in blockhub_folder["item"] if s["name"] != "Health"]

# ── Banking sub-folders ────────────────────────────────────────────────────────

# Rename Home folder
home_folder["name"] = "Home / Dashboard"

# Extract Core Banking sub-folders
accounts_sub   = get_sub("Core Banking", "Accounts")
wallet_sub     = get_sub("Core Banking", "Wallet")
cards_sub      = get_sub("Core Banking", "Cards")
transfers_sub  = get_sub("Core Banking", "Transfers")
txn_sub        = get_sub("Core Banking", "Transactions")
deposits_sub   = get_sub("Core Banking", "Deposits (ACH)")

banking_folder = folder("Banking", [
    home_folder,
    accounts_sub,
    wallet_sub,
    cards_sub,
    transfers_sub,
    txn_sub,
    deposits_sub,
    bills_folder,
    fx_folder,
    kyc_folder,
])

# ── Panther AI — split into sub-folders ───────────────────────────────────────

def req_named(items, *names):
    return [r for r in items if r["name"] in names]

ai_items = panther_folder["item"]

kevin_reqs   = req_named(ai_items, "Kevin Chat")
alert_reqs   = req_named(ai_items, "List Alerts", "Generate Alerts", "Dismiss Alert")
level_reqs   = req_named(ai_items, "Get User Level", "Set User Level", "Submit Level Quiz")
bnpl_reqs    = req_named(ai_items, "TickPay Affordability Score", "Marketplace Search")
voice_reqs   = req_named(ai_items, "Voice Transcribe (multipart/form-data)", "Voice Synthesize")

panther_restructured = folder("Panther AI", [
    folder("Kevin Chat",    kevin_reqs),
    folder("AI Alerts",     alert_reqs),
    folder("User Level",    level_reqs),
    folder("BNPL Scoring",  bnpl_reqs),
    folder("Voice",         voice_reqs),
])

# ── Rename TickPay for clarity ────────────────────────────────────────────────
tickpay_folder["name"] = "TickPay / BNPL"

# ── BlockHub — rename sub-folders for clarity ─────────────────────────────────
rename_map = {
    "Crypto — Market":    "Crypto / Market Prices",
    "Crypto — Portfolio": "Crypto / Portfolio",
    "Crypto — Trading":   "Crypto / Trading",
    "NFT — Browse":       "NFT / Browse",
    "NFT — Minting":      "NFT / Minting",
    "NFT — Marketplace":  "NFT / Marketplace",
    "NFT — Portfolio":    "NFT / Portfolio",
}
for sub in blockhub_folder["item"]:
    if sub["name"] in rename_map:
        sub["name"] = rename_map[sub["name"]]

# ── Assemble final collection ──────────────────────────────────────────────────

new_items = [
    folder("Health", [main_health_req, bh_health_req]),
    auth_folder,
    banking_folder,
    tickpay_folder,
    lifex_folder,
    panther_restructured,
    notif_folder,
    blockhub_folder,
]

col["item"] = new_items

col["info"]["description"] = (
    "Chronos API — Complete collection (all endpoints).\n\n"
    "Main API:  http://chronos.us-east-1.elasticbeanstalk.com\n"
    "BlockHub:  http://blockhub-env.us-east-1.elasticbeanstalk.com\n\n"
    "HOW TO USE\n"
    "1. Open the Health folder and hit both health checks to confirm both services are up.\n"
    "2. Run Auth > Register (or Login) — token is auto-saved to {{token}}.\n"
    "3. All protected requests use {{token}} automatically.\n"
    "4. BlockHub shares the same token — no separate login.\n"
    "5. IDs returned by requests (accountId, walletId, nftId, etc.) are auto-saved as collection variables.\n\n"
    "FOLDERS\n"
    "  Health       — liveness checks (Main API + BlockHub)\n"
    "  Auth         — register, login, forgot/reset password\n"
    "  Banking      — accounts, wallets, cards, transfers, transactions, deposits, bills, FX, KYC\n"
    "  TickPay/BNPL — buy-now-pay-later accounts, purchases, repayments\n"
    "  LifeX        — 11 personal development modules\n"
    "  Panther AI   — Kevin chat, alerts, voice, scoring\n"
    "  Notifications — in-app notification management\n"
    "  BlockHub     — crypto trading + NFT minting/marketplace"
)

with open(path, "w", encoding="utf-8") as f:
    json.dump(col, f, indent=2, ensure_ascii=False)

print("Done! New structure:")
for top in col["item"]:
    subs = top.get("item", [])
    print(f"  [{top['name']}] — {len(subs)} items")
    for s in subs:
        sub_items = s.get("item", [])
        if sub_items:
            print(f"      [{s['name']}] — {len(sub_items)} requests")
        else:
            print(f"      - {s['name']}")

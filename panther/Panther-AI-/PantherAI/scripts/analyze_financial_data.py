#!/usr/bin/env python3
"""
scripts/analyze_financial_data.py
===================================
Standalone CLI for the financial-advisor engine (services/financial_advisor).
Runs one or more people's raw financial data (income, transactions, debts)
through the same analysis used by the /api/financial-advisor/analyze endpoint,
without needing the FastAPI server running.

Usage:
    # Analyze every *.json file in a directory (one person per file):
    python scripts/analyze_financial_data.py --dir scripts/sample_data

    # Analyze specific files:
    python scripts/analyze_financial_data.py --files person_a.json person_b.json

Each input JSON file matches PersonFinancialInput (see
routers/financial_advisor/models.py):
    {
      "name": "...", "location": "...", "monthly_income": 0,
      "filing_status": "single" | "married_joint",
      "transactions": [{"merchant": "...", "amount": 0, "frequency": "monthly", ...}],
      "debts": [{"name": "...", "type": "...", "balance": 0, "monthly_payment": 0, "interest_rate": 0}]
    }

Writes one Markdown report per person to --out-dir (default: ./reports) and
prints a one-line summary per person to stdout. Input files are never
modified; output reports are local files only (not committed / not logged).
"""

from __future__ import annotations

import argparse
import json
import os
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

from services.financial_advisor.analyzer import analyze_person  # noqa: E402


def _load_person(path: Path) -> dict:
    with open(path, "r", encoding="utf-8") as f:
        return json.load(f)


def _render_markdown(report: dict) -> str:
    lines = [f"# Financial Advice Report — {report.get('name') or 'Unnamed'}", ""]
    s = report["summary"]
    lines.append(f"**Monthly income:** ${report['monthly_income']:,.2f}")
    lines.append(f"**Total monthly expenses:** ${s['total_monthly_expenses']:,.2f}")
    lines.append(f"**Total monthly debt payments:** ${s['total_monthly_debt_payments']:,.2f}")
    lines.append(f"**Monthly leftover:** ${s['monthly_leftover']:,.2f}")
    lines.append(f"**Savings rate:** {s['savings_rate_pct']:.1f}%")
    lines.append("")

    lines.append("## Expense breakdown (monthly)")
    for row in report["expenses"]["by_subcategory"]:
        lines.append(f"- {row['subcategory_name']} ({row['category_name']}): ${row['monthly_total']:,.2f}")
    lines.append("")

    gym = report["gym_analysis"]
    lines.append("## Gym / fitness")
    if gym["has_gym_membership"]:
        for m in gym["memberships"]:
            lines.append(f"- {m['merchant']}: ${m['monthly_cost']:,.2f}/mo — {m['note']}")
    else:
        lines.append("- No gym/fitness spending detected.")
    lines.append("")

    supp = report["supplement_analysis"]
    lines.append("## Supplements")
    if supp["has_supplement_spending"]:
        lines.append(
            f"- ${supp['total_monthly_cost']:,.2f}/mo ({supp['pct_of_monthly_income']:.1f}% of income) "
            f"— {'material, flagged' if supp['is_material'] else 'below materiality threshold, not flagged'}"
        )
    else:
        lines.append("- No supplement spending detected.")
    lines.append("")

    liab = report["liabilities"]
    lines.append("## Liabilities")
    lines.append(f"- Total balance: ${liab['total_balance']:,.2f}")
    lines.append(f"- Total monthly payments: ${liab['total_monthly_payments']:,.2f}")
    lines.append(f"- DTI ratio: {liab['dti_ratio'] * 100:.1f}% ({liab['dti_status']})")
    if liab["payoff_priority_order"]:
        lines.append(f"- Payoff priority (highest rate first): {', '.join(liab['payoff_priority_order'])}")
    lines.append("")

    tax = report["tax_estimate"]
    lines.append("## Tax estimate (rough, non-authoritative)")
    lines.append(
        f"- Estimated annual tax: ${tax['estimated_annual_tax']:,.2f} "
        f"(effective rate {tax['effective_tax_rate_pct']:.1f}%, marginal {tax['marginal_tax_rate_pct']:.0f}%)"
    )
    lines.append(f"- {tax['disclaimer']}")
    lines.append("")

    crypto = report["crypto_analysis"]
    lines.append("## Crypto")
    if crypto["has_crypto_activity"]:
        lines.append(f"- Total fees paid: ${crypto['total_fees_paid']:,.2f}")
        lines.append(f"- Total realized P&L (estimate): ${crypto['total_realized_pnl']:,.2f}")
        if crypto["portfolio_market_value"] is not None:
            lines.append(f"- Current portfolio market value (estimate): ${crypto['portfolio_market_value']:,.2f}")
        for h in crypto["holdings"]:
            lines.append(
                f"  - {h['asset']}: {h['remaining_quantity']} held, avg cost ${h['avg_cost_basis']:,.2f}, "
                f"realized P&L ${h['realized_pnl_estimate']:,.2f}"
            )
        for flag in crypto["flags"]:
            lines.append(f"- ⚠ {flag['message']}")
    else:
        lines.append("- No crypto activity detected.")
    lines.append("")

    nft = report["nft_analysis"]
    lines.append("## NFTs")
    if nft["has_nft_activity"]:
        lines.append(f"- Total spent (acquisitions + gas): ${nft['total_spent']:,.2f}")
        lines.append(f"- Total gas fees: ${nft['total_gas_fees']:,.2f}")
        lines.append(f"- Net cash flow: ${nft['net_cash_flow']:,.2f}")
        for c in nft["collections"]:
            lines.append(
                f"  - {c['collection']}: held {c['held_count']}, acquisition cost ${c['acquisition_cost']:,.2f}, "
                f"net cash flow ${c['net_cash_flow']:,.2f}"
            )
        for flag in nft["flags"]:
            lines.append(f"- ⚠ {flag['message']}")
    else:
        lines.append("- No NFT activity detected.")
    lines.append("")

    lines.append("## Tailored advice")
    for a in report["advice"]:
        lines.append(f"- **[{a['category']}]** {a['advice']}")

    return "\n".join(lines)


def main() -> None:
    parser = argparse.ArgumentParser(description="Run the financial-advisor engine over person JSON files.")
    group = parser.add_mutually_exclusive_group(required=True)
    group.add_argument("--dir", help="Directory containing one *.json file per person.")
    group.add_argument("--files", nargs="+", help="Explicit list of JSON files to analyze.")
    parser.add_argument("--out-dir", default="reports", help="Directory to write Markdown reports to.")
    args = parser.parse_args()

    if args.dir:
        paths = sorted(Path(args.dir).glob("*.json"))
    else:
        paths = [Path(p) for p in args.files]

    if not paths:
        print("No input files found.", file=sys.stderr)
        sys.exit(1)

    out_dir = Path(args.out_dir)
    out_dir.mkdir(parents=True, exist_ok=True)

    for path in paths:
        person = _load_person(path)
        report = analyze_person(person)

        name = report.get("name") or path.stem
        out_path = out_dir / f"{path.stem}_report.md"
        out_path.write_text(_render_markdown(report), encoding="utf-8")

        s = report["summary"]
        print(
            f"{name}: income=${report['monthly_income']:,.2f} "
            f"leftover=${s['monthly_leftover']:,.2f} "
            f"savings_rate={s['savings_rate_pct']:.1f}% "
            f"-> {out_path}"
        )


if __name__ == "__main__":
    main()

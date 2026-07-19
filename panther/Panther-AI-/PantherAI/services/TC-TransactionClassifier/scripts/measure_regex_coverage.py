"""
Measure Regex Hit Rate
======================
Runs TC_RegexDictionary patterns against panther_ground_truth_v3.parquet
to calculate the exact coverage percentage (baseline metric for Tier 1).

Output:
- Overall hit rate %
- Hit rate by subcategory
- Match/mismatch analysis
"""

import re
import sys
import pandas as pd
from pathlib import Path
from collections import defaultdict
from datetime import datetime

# Add parent directory to path for imports
sys.path.insert(0, str(Path(__file__).parent.parent))
from TC_RegexDictionary import MERCHANT_DICTIONARY, KEYWORD_RULES


def classify_with_regex(description: str, category: str = None) -> tuple[str, str]:
    """
    Attempt to classify a transaction using regex patterns.

    Returns:
        (subcategory, match_type) or (None, None) if no match
        match_type: 'merchant' or 'keyword'
    """
    if not description or not isinstance(description, str):
        return None, None

    desc_upper = description.upper().strip()

    # Step 1: Try MERCHANT_DICTIONARY (exact patterns)
    for pattern, subcat in MERCHANT_DICTIONARY.items():
        try:
            # Check if pattern contains regex characters
            if (
                pattern.startswith('r"')
                or "\\b" in pattern
                or pattern.startswith(r"\b")
            ):
                # It's a regex pattern
                if re.search(pattern, desc_upper, re.IGNORECASE):
                    return subcat, "merchant"
            else:
                # Plain text match (case-insensitive)
                if pattern.upper() in desc_upper:
                    return subcat, "merchant"
        except re.error:
            # Invalid regex, try as literal
            if pattern.upper() in desc_upper:
                return subcat, "merchant"

    # Step 2: Try KEYWORD_RULES (category-based fallback)
    for cat, subcats in KEYWORD_RULES.items():
        for subcat, patterns in subcats.items():
            for pattern in patterns:
                try:
                    if re.search(pattern, desc_upper, re.IGNORECASE):
                        return subcat, "keyword"
                except re.error:
                    continue

    return None, None


def measure_coverage(df: pd.DataFrame) -> dict:
    """
    Measure regex coverage across the dataset.

    Returns dict with:
    - total_records
    - matched_records
    - hit_rate
    - by_subcategory stats
    - by_match_type stats
    """
    results = {
        "total": len(df),
        "matched": 0,
        "matched_correct": 0,  # Regex match == ground truth
        "matched_incorrect": 0,  # Regex match != ground truth
        "unmatched": 0,
        "by_subcategory": defaultdict(lambda: {"total": 0, "matched": 0, "correct": 0}),
        "by_match_type": {"merchant": 0, "keyword": 0},
        "mismatches": [],  # Sample of misclassifications
    }

    print(f"\n🔍 Analyzing {len(df):,} transactions...")
    print("=" * 60)

    for idx, row in df.iterrows():
        desc = row.get("description", row.get("Description", ""))
        true_subcat = row.get("subcategory", row.get("Subcategory", ""))

        # Track by subcategory
        results["by_subcategory"][true_subcat]["total"] += 1

        # Classify
        pred_subcat, match_type = classify_with_regex(desc)

        if pred_subcat:
            results["matched"] += 1
            results["by_subcategory"][true_subcat]["matched"] += 1
            results["by_match_type"][match_type] += 1

            if pred_subcat == true_subcat:
                results["matched_correct"] += 1
                results["by_subcategory"][true_subcat]["correct"] += 1
            else:
                results["matched_incorrect"] += 1
                # Collect sample mismatches (limit to 100)
                if len(results["mismatches"]) < 100:
                    results["mismatches"].append(
                        {
                            "description": desc[:80],
                            "true": true_subcat,
                            "predicted": pred_subcat,
                            "match_type": match_type,
                        }
                    )
        else:
            results["unmatched"] += 1

        # Progress indicator
        if (idx + 1) % 100000 == 0:
            print(f"  Processed {idx + 1:,} records...")

    return results


def generate_report(results: dict, output_path: Path):
    """Generate detailed coverage report."""

    hit_rate = (
        (results["matched"] / results["total"]) * 100 if results["total"] > 0 else 0
    )
    accuracy = (
        (results["matched_correct"] / results["matched"]) * 100
        if results["matched"] > 0
        else 0
    )

    report = []
    report.append("# Regex Hit Rate Report")
    report.append(f"\n**Generated**: {datetime.now().strftime('%Y-%m-%d %H:%M')}")
    report.append("\n---\n")

    # Overall metrics
    report.append("## 📊 Overall Metrics\n")
    report.append("| Metric | Value |")
    report.append("|--------|-------|")
    report.append(f"| Total Records | {results['total']:,} |")
    report.append(f"| Matched by Regex | {results['matched']:,} |")
    report.append(f"| Unmatched | {results['unmatched']:,} |")
    report.append(f"| **Hit Rate** | **{hit_rate:.2f}%** |")
    report.append(f"| Correct Matches | {results['matched_correct']:,} |")
    report.append(f"| Incorrect Matches | {results['matched_incorrect']:,} |")
    report.append(f"| **Accuracy (when matched)** | **{accuracy:.2f}%** |")

    # Match type breakdown
    report.append("\n## 🔧 Match Type Breakdown\n")
    report.append("| Type | Count | % of Matches |")
    report.append("|------|-------|--------------|")
    for mtype, count in results["by_match_type"].items():
        pct = (count / results["matched"]) * 100 if results["matched"] > 0 else 0
        report.append(f"| {mtype.title()} | {count:,} | {pct:.1f}% |")

    # Per-subcategory breakdown
    report.append("\n## 📋 Coverage by Subcategory\n")
    report.append("| Subcategory | Total | Matched | Hit Rate | Accuracy |")
    report.append("|-------------|-------|---------|----------|----------|")

    sorted_subcats = sorted(
        results["by_subcategory"].items(), key=lambda x: x[1]["total"], reverse=True
    )

    for subcat, stats in sorted_subcats:
        total = stats["total"]
        matched = stats["matched"]
        correct = stats["correct"]
        hr = (matched / total) * 100 if total > 0 else 0
        acc = (correct / matched) * 100 if matched > 0 else 0

        # Emoji indicator
        emoji = "🟢" if hr >= 80 else ("🟡" if hr >= 50 else "🔴")
        report.append(
            f"| {emoji} {subcat} | {total:,} | {matched:,} | {hr:.1f}% | {acc:.1f}% |"
        )

    # Misclassification samples
    if results["mismatches"]:
        report.append("\n## ⚠️ Sample Misclassifications (first 20)\n")
        report.append("| Description | True | Predicted | Type |")
        report.append("|-------------|------|-----------|------|")
        for m in results["mismatches"][:20]:
            desc = m["description"].replace("|", "\\|")
            report.append(
                f"| {desc} | {m['true']} | {m['predicted']} | {m['match_type']} |"
            )

    # Action items
    report.append("\n## 🎯 Next Steps\n")
    report.append("- **Target Hit Rate**: >80%")
    if hit_rate < 80:
        report.append(
            f"- **Gap**: {80 - hit_rate:.1f}% ({int((80 - hit_rate) * results['total'] / 100):,} transactions)"
        )
    report.append("- Focus on subcategories with <50% hit rate (🔴)")
    report.append("- Review misclassifications to improve pattern precision")

    # Write report
    report_text = "\n".join(report)
    output_path.write_text(report_text)
    print(f"\n📄 Report saved to: {output_path}")

    return report_text


def main():
    # Paths
    project_root = Path(__file__).parent.parent.parent.parent
    dataset_path = (
        project_root / "datasets" / "processed" / "panther_ground_truth_v3.parquet"
    )
    report_path = (
        project_root
        / "docs"
        / "PantherAI"
        / "TransactionClassifier"
        / "regex_coverage_report.md"
    )

    print("=" * 60)
    print("🎯 REGEX HIT RATE MEASUREMENT")
    print("=" * 60)

    # Load dataset
    print(f"\n📂 Loading dataset: {dataset_path}")
    if not dataset_path.exists():
        print(f"❌ Dataset not found: {dataset_path}")
        return

    df = pd.read_parquet(dataset_path)
    print(f"✅ Loaded {len(df):,} records")
    print(f"   Columns: {list(df.columns)}")

    # Check column names
    desc_col = "description" if "description" in df.columns else "Description"
    subcat_col = "subcategory" if "subcategory" in df.columns else "Subcategory"
    print(f"   Using: {desc_col}, {subcat_col}")

    # Measure coverage
    results = measure_coverage(df)

    # Print summary
    hit_rate = (results["matched"] / results["total"]) * 100
    accuracy = (
        (results["matched_correct"] / results["matched"]) * 100
        if results["matched"] > 0
        else 0
    )

    print("\n" + "=" * 60)
    print("📊 SUMMARY")
    print("=" * 60)
    print(f"   Total Records:     {results['total']:,}")
    print(f"   Regex Matches:     {results['matched']:,}")
    print(f"   🎯 HIT RATE:       {hit_rate:.2f}%")
    print(f"   ✅ Accuracy:       {accuracy:.2f}%")
    print("=" * 60)

    # Generate report
    generate_report(results, report_path)


if __name__ == "__main__":
    main()

"""
Analyze Class Distribution
==========================
Generates stats per subcategory to identify which classes need:
- Undersampling (>50K records)
- Oversampling (<10K records)

Output: class_distribution_report.md
"""

import pandas as pd
import numpy as np
from pathlib import Path
from datetime import datetime


def analyze_distribution(df: pd.DataFrame) -> dict:
    """Analyze class distribution and identify imbalances."""

    subcat_col = "subcategory" if "subcategory" in df.columns else "Subcategory"

    # Count per subcategory
    counts = df[subcat_col].value_counts().to_dict()
    total = len(df)

    # Calculate stats
    values = list(counts.values())
    mean_count = np.mean(values)
    median_count = np.median(values)
    std_count = np.std(values)
    max_count = max(values)
    min_count = min(values)
    imbalance_ratio = max_count / min_count if min_count > 0 else float("inf")

    # Categorize classes
    undersample = {k: v for k, v in counts.items() if v > 50000}
    oversample = {k: v for k, v in counts.items() if v < 10000}
    balanced = {k: v for k, v in counts.items() if 10000 <= v <= 50000}

    return {
        "total_records": total,
        "num_classes": len(counts),
        "counts": counts,
        "mean": mean_count,
        "median": median_count,
        "std": std_count,
        "max": max_count,
        "min": min_count,
        "imbalance_ratio": imbalance_ratio,
        "undersample": undersample,
        "oversample": oversample,
        "balanced": balanced,
    }


def generate_report(stats: dict, output_path: Path):
    """Generate class distribution report."""

    report = []
    report.append("# Class Distribution Analysis")
    report.append(f"\n**Generated**: {datetime.now().strftime('%Y-%m-%d %H:%M')}")
    report.append("\n---\n")

    # Summary stats
    report.append("## 📊 Summary Statistics\n")
    report.append("| Metric | Value |")
    report.append("|--------|-------|")
    report.append(f"| Total Records | {stats['total_records']:,} |")
    report.append(f"| Number of Classes | {stats['num_classes']} |")
    report.append(f"| Mean per Class | {stats['mean']:,.0f} |")
    report.append(f"| Median per Class | {stats['median']:,.0f} |")
    report.append(f"| Std Deviation | {stats['std']:,.0f} |")
    report.append(f"| Largest Class | {stats['max']:,} |")
    report.append(f"| Smallest Class | {stats['min']:,} |")
    report.append(f"| **Imbalance Ratio** | **{stats['imbalance_ratio']:.1f}:1** |")

    # Classes to undersample
    report.append("\n## 🔻 Classes to Undersample (>50K)\n")
    if stats["undersample"]:
        report.append("| Subcategory | Count | Action |")
        report.append("|-------------|-------|--------|")
        for subcat, count in sorted(stats["undersample"].items(), key=lambda x: -x[1]):
            target = 30000
            reduction = count - target
            report.append(
                f"| `{subcat}` | {count:,} | Reduce by {reduction:,} → ~30K |"
            )
        total_reduction = sum(stats["undersample"].values()) - (
            30000 * len(stats["undersample"])
        )
        report.append(f"\n**Total records to remove**: ~{total_reduction:,}")
    else:
        report.append("*No classes above 50K threshold.*")

    # Classes to oversample
    report.append("\n## 🔺 Classes to Oversample (<10K)\n")
    if stats["oversample"]:
        report.append("| Subcategory | Count | Action |")
        report.append("|-------------|-------|--------|")
        for subcat, count in sorted(stats["oversample"].items(), key=lambda x: x[1]):
            target = 15000
            increase = target - count
            report.append(f"| `{subcat}` | {count:,} | Add ~{increase:,} → ~15K |")
        total_increase = (15000 * len(stats["oversample"])) - sum(
            stats["oversample"].values()
        )
        report.append(f"\n**Total synthetic records needed**: ~{total_increase:,}")
    else:
        report.append("*No classes below 10K threshold.*")

    # Balanced classes
    report.append("\n## ✅ Balanced Classes (10K-50K)\n")
    if stats["balanced"]:
        report.append("| Subcategory | Count |")
        report.append("|-------------|-------|")
        for subcat, count in sorted(stats["balanced"].items(), key=lambda x: -x[1]):
            report.append(f"| `{subcat}` | {count:,} |")
    else:
        report.append("*No classes in balanced range.*")

    # Full distribution
    report.append("\n## 📋 Full Distribution (Sorted by Count)\n")
    report.append("| # | Subcategory | Count | % of Total | Status |")
    report.append("|---|-------------|-------|------------|--------|")
    for i, (subcat, count) in enumerate(
        sorted(stats["counts"].items(), key=lambda x: -x[1]), 1
    ):
        pct = (count / stats["total_records"]) * 100
        if count > 50000:
            status = "🔻 Undersample"
        elif count < 10000:
            status = "🔺 Oversample"
        else:
            status = "✅ OK"
        report.append(f"| {i} | `{subcat}` | {count:,} | {pct:.1f}% | {status} |")

    # Recommendations
    report.append("\n## 🎯 Recommendations\n")
    report.append("### Balancing Strategy")
    report.append(
        f"1. **Undersample**: {len(stats['undersample'])} classes → reduce to ~30K each"
    )
    report.append(
        f"2. **Oversample**: {len(stats['oversample'])} classes → increase to ~15K each"
    )
    report.append(
        f"3. **Keep as-is**: {len(stats['balanced'])} classes already balanced"
    )

    # Estimated final size
    undersample_final = len(stats["undersample"]) * 30000
    oversample_final = len(stats["oversample"]) * 15000
    balanced_final = sum(stats["balanced"].values())
    estimated_total = undersample_final + oversample_final + balanced_final

    report.append("\n### Estimated Balanced Dataset Size")
    report.append(f"- Undersampled classes: ~{undersample_final:,}")
    report.append(f"- Oversampled classes: ~{oversample_final:,}")
    report.append(f"- Balanced classes: ~{balanced_final:,}")
    report.append(f"- **Total**: ~{estimated_total:,} records")
    report.append(f"- **New Imbalance Ratio**: ~{30000/15000:.1f}:1 (target <3:1 ✅)")

    # Write report
    report_text = "\n".join(report)
    output_path.write_text(report_text)
    print(f"\n📄 Report saved to: {output_path}")

    return report_text


import argparse


def main():
    # Paths
    project_root = Path(__file__).parent.parent.parent.parent
    default_input = (
        project_root / "datasets" / "processed" / "panther_ground_truth_v3.parquet"
    )
    default_output = (
        project_root
        / "docs"
        / "PantherAI"
        / "TransactionClassifier"
        / "class_distribution_report.md"
    )

    parser = argparse.ArgumentParser(description="Analyze class distribution")
    parser.add_argument(
        "--input", type=Path, default=default_input, help="Path to input parquet file"
    )
    parser.add_argument(
        "--output",
        type=Path,
        default=default_output,
        help="Path to output report markdown file",
    )
    args = parser.parse_args()

    dataset_path = args.input
    report_path = args.output

    print("=" * 60)
    print("📊 CLASS DISTRIBUTION ANALYSIS")
    print("=" * 60)

    # Load dataset
    print(f"\n📂 Loading dataset: {dataset_path}")
    df = pd.read_parquet(dataset_path)
    print(f"✅ Loaded {len(df):,} records")

    # Analyze
    stats = analyze_distribution(df)

    # Print summary
    print("\n" + "=" * 60)
    print("📊 SUMMARY")
    print("=" * 60)
    print(f"   Total Classes:        {stats['num_classes']}")
    print(f"   Imbalance Ratio:      {stats['imbalance_ratio']:.1f}:1")
    print(f"   Classes to Undersample: {len(stats['undersample'])}")
    print(f"   Classes to Oversample:  {len(stats['oversample'])}")
    print(f"   Classes OK:             {len(stats['balanced'])}")
    print("=" * 60)

    # Generate report
    generate_report(stats, report_path)


if __name__ == "__main__":
    main()

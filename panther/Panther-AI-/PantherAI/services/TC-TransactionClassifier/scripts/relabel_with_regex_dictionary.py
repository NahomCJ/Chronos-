import pandas as pd
import sys
import os
import re

# Add package root to path
sys.path.insert(0, str(os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))))

try:
    from classifier.regex_dictionary import MERCHANT_DICTIONARY, KEYWORD_RULES
    from classifier.taxonomy import TAXONOMY
except ImportError as e:
    print(f"Error importing classifier package: {e}")
    sys.exit(1)


def load_taxonomy():
    """Returns the loaded TAXONOMY dictionary"""
    return TAXONOMY


def build_taxonomy_map():
    """Maps subcategory_id -> category_id"""
    taxonomy_data = load_taxonomy()
    tax_map = {}
    for category in taxonomy_data["taxonomy"]:
        cat_id = category["id"]
        for sub in category["subcategories"]:
            tax_map[sub["id"]] = cat_id
    return tax_map


def classify_transaction(description, merchant_dict, keyword_rules, tax_map):
    """
    Classifies a single transaction using the priority logic:
    1. Merchant Dictionary (Order preserved)
    2. Keyword Rules
    """
    if not isinstance(description, str):
        return None, None

    description_upper = description.upper()

    # 1. MERCHANT_DICTIONARY (High Priority, Specific Patterns)
    # Iterate in order as defined in the file
    for pattern, sub_id in merchant_dict.items():
        try:
            # We treat patterns as regexes.
            # Note: Ideally, literal strings should be escaped if they contain regex specials,
            # but we assume the dictionary is maintained with this awareness or mostly literals.
            if re.search(pattern, description_upper):
                cat_id = tax_map.get(sub_id)
                return sub_id, cat_id
        except re.error:
            # Fallback for invalid regexes, though they should be valid
            if pattern in description_upper:
                cat_id = tax_map.get(sub_id)
                return sub_id, cat_id

    # 2. KEYWORD_RULES (Medium Priority, Categorized Generic Rules)
    for cat_name, sub_rules in keyword_rules.items():
        for sub_id, patterns in sub_rules.items():
            for pattern in patterns:
                try:
                    if re.search(pattern, description_upper):
                        cat_id = tax_map.get(sub_id)
                        return sub_id, cat_id
                except re.error:
                    pass

    return None, None


def main():
    import argparse

    parser = argparse.ArgumentParser(
        description="Relabel transactions using Regex Dictionary"
    )
    parser.add_argument(
        "--input",
        type=str,
        default="datasets/raw/mitulshah_transaction_categorization/0000.parquet",
        help="Path to input file (.parquet or .csv)",
    )
    parser.add_argument(
        "--output",
        type=str,
        default="datasets/processed/panther_ground_truth.parquet",
        help="Path to output file (.parquet)",
    )

    args = parser.parse_args()

    # Check input
    if not os.path.exists(args.input):
        print(f"Error: Input file not found: {args.input}")
        return

    print(f"Loading data from {args.input}...")
    try:
        if args.input.endswith(".csv"):
            df = pd.read_csv(args.input)
        else:
            df = pd.read_parquet(args.input)

        print(f"Columns found: {list(df.columns)}")

    except Exception as e:
        print(f"Error reading file: {e}")
        return

    # Build Map
    tax_map = build_taxonomy_map()

    # Process
    total = len(df)
    print(f"Processing {total} transactions...")

    # Initialize columns
    df["panther_category_id"] = None
    df["panther_subcategory_id"] = None

    # Ensure description is string and upper for matching
    print("Normalizing descriptions...")
    desc_series = df["transaction_description"].astype(str).str.upper()

    # We need to track which rows are already classified to respect priority
    # Vectorized approach:
    # Iterate patterns. For each pattern, find matches in unclassified rows.
    # Since we need to update potentially many rows, and we have many patterns (700+),
    # pure vectorization (700 passes) might calculate matches on already classified rows if we don't filter.
    # But we can use a boolean mask `unclassified_mask`.

    unclassified_mask = pd.Series(True, index=df.index)
    matches_found = 0

    print("Applying MERCHANT_DICTIONARY rules...")
    # 1. MERCHANT_DICTIONARY (High Priority)
    for pattern, sub_id in MERCHANT_DICTIONARY.items():
        if not unclassified_mask.any():
            break

        try:
            # Check if pattern is a regex (contains special chars) or literal
            # Heuristic: simple alphabetic/space usually literal.
            # But the dictionary is mixed.
            # safe assumption: use regex=True if it looks like regex, else False (faster)

            # Use regex=True for correct behavior as per dictionary intent (some are regexes)
            # To speed up, we only apply to unclassified

            # Note: str.contains on the whole series is robust but slow if repeated 700 times.
            # Optimization:
            # If pattern is literal, use simple search.
            # Most entries are simple strings.

            # Simple heuristic for regex chars: \ [ ] ( ) ? * + ^ $
            is_regex = bool(re.search(r"[\\\[\]\(\)\?\*\+\^\$]", pattern))

            # Find matches in the subset of unclassified?
            # subsetting df is expensive if copied.
            # desc_series[unclassified_mask].str.contains(...)

            current_matches = desc_series[unclassified_mask].str.contains(
                pattern, regex=is_regex, case=False, na=False
            )

            if current_matches.any():
                # valid_indices are the indices in the original df where match is True
                # current_matches index is a subset.
                matched_indices = current_matches[current_matches].index

                cat_id = tax_map.get(sub_id)
                df.loc[matched_indices, "panther_subcategory_id"] = sub_id
                df.loc[matched_indices, "panther_category_id"] = cat_id

                unclassified_mask.loc[matched_indices] = False
                matches_found += len(matched_indices)

        except Exception:
            # Continue on regex error
            pass

    print(f"Matches after Dictionary: {matches_found}")

    print("Applying KEYWORD_RULES...")
    # 2. KEYWORD_RULES
    for cat_name, sub_rules in KEYWORD_RULES.items():
        for sub_id, patterns in sub_rules.items():
            for pattern in patterns:
                if not unclassified_mask.any():
                    break

                try:
                    current_matches = desc_series[unclassified_mask].str.contains(
                        pattern, regex=True, case=False, na=False
                    )
                    if current_matches.any():
                        matched_indices = current_matches[current_matches].index

                        cat_id = tax_map.get(sub_id)
                        df.loc[matched_indices, "panther_subcategory_id"] = sub_id
                        df.loc[matched_indices, "panther_category_id"] = cat_id

                        unclassified_mask.loc[matched_indices] = False
                        matches_found += len(matched_indices)
                except:
                    pass

    # Filter reliable only
    ground_truth_df = df[df["panther_subcategory_id"].notna()].copy()
    match_count = len(ground_truth_df)

    # Report
    print("\n" + "=" * 50)
    print(" GROUND TRUTH GENERATION REPORT")
    print("=" * 50)
    print(f"Total Transactions: {total}")
    print(f"Reliable Matches:   {match_count}")
    print(f"Hit Rate:           {match_count/total if total > 0 else 0:.2%}")
    print("-" * 50)

    if match_count > 0:
        print("\nTop 10 Categories:")
        print(ground_truth_df["panther_category_id"].value_counts().head(10))

        print("\nTop 10 Subcategories:")
        print(ground_truth_df["panther_subcategory_id"].value_counts().head(10))

        # Save
        print(f"\nSaving reliable dataset to {args.output}...")
        os.makedirs(os.path.dirname(args.output), exist_ok=True)
        ground_truth_df.to_parquet(args.output)
        print(f"Success. Saved {match_count} records.")
    else:
        print("No matches found. Check your dictionary patterns or input data.")


if __name__ == "__main__":
    main()

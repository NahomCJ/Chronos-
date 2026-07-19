import os
import sys
import pandas as pd
from tqdm import tqdm

# Add TC-TransactionClassifier directory to path
tc_path = os.path.join(os.getcwd(), "PantherAI", "TC-TransactionClassifier")
if tc_path not in sys.path:
    sys.path.append(tc_path)

from tier1_regex import RegexClassifier


def verify_hit_rate(parquet_path, sample_size=10000):
    print(f"Loading ground truth sample from {parquet_path}...")
    df = pd.read_parquet(parquet_path)
    if sample_size and sample_size < len(df):
        df = df.sample(sample_size, random_state=42)

    print("Initializing RegexClassifier with production dictionary...")
    classifier = RegexClassifier()

    print(f"Verifying {len(df)} transactions...")
    matches = 0
    mismatches = []

    for _, row in tqdm(df.iterrows(), total=len(df)):
        desc = row["description"]
        expected_sub = row["subcategory"]

        result = classifier.classify(desc)

        if result and result[0] == expected_sub:
            matches += 1
        else:
            actual_sub = result[0] if result else "None"
            mismatches.append(
                {"description": desc, "expected": expected_sub, "actual": actual_sub}
            )

    hit_rate = (matches / len(df)) * 100
    print("\nVerification Results:")
    print(f"Total Verified: {len(df)}")
    print(f"Matches:        {matches}")
    print(f"Hit Rate:       {hit_rate:.2f}%")

    if mismatches:
        print("\nFirst 5 Mismatches:")
        for m in mismatches[:5]:
            print(
                f"DESC: {m['description']} | EXPECTED: {m['expected']} | ACTUAL: {m['actual']}"
            )
    else:
        print("\nSUCCESS: 100% Hit Rate achieved!")


if __name__ == "__main__":
    dataset_path = "datasets/processed/panther_ground_truth_v3.parquet"
    if not os.path.exists(dataset_path):
        print(f"Error: Dataset not found at {dataset_path}")
        sys.exit(1)

    verify_hit_rate(dataset_path)

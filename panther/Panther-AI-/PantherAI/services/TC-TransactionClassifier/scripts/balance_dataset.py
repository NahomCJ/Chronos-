"""
Balance Dataset Script
======================
Undersamples large classes (>50K) to ~30K.
Oversamples small classes (<15K) to ~15K.
Uses synthetic generation where possible (via generate_synthetic_transactions.py),
otherwise uses Random Oversampling (ROS).
"""

import pandas as pd
from pathlib import Path
import sys
import importlib.util

# Paths
ROOT_DIR = Path(__file__).parent.parent
DATA_DIR = ROOT_DIR / "datasets" / "processed"
INPUT_FILE = DATA_DIR / "panther_ground_truth_v3.parquet"
OUTPUT_FILE = DATA_DIR / "panther_ground_truth_v3_balanced.parquet"

# Thresholds
UNDERSAMPLE_THRESHOLD = 50000
UNDERSAMPLE_TARGET = 30000
OVERSAMPLE_THRESHOLD = 15000
OVERSAMPLE_TARGET = 15000

# Import synthetic generator
SYNTH_SCRIPT_PATH = Path(__file__).parent / "generate_synthetic_transactions.py"
spec = importlib.util.spec_from_file_location(
    "generate_synthetic_transactions", SYNTH_SCRIPT_PATH
)
gen_synth = importlib.util.module_from_spec(spec)
sys.modules["generate_synthetic_transactions"] = gen_synth
spec.loader.exec_module(gen_synth)


def balance_dataset():
    if not INPUT_FILE.exists():
        print(f"❌ Input file not found: {INPUT_FILE}")
        return

    print(f"Loading {INPUT_FILE}...")
    df = pd.read_parquet(INPUT_FILE)
    print(f"Original records: {len(df):,}")

    balanced_dfs = []

    # Get class counts
    counts = df["subcategory"].value_counts()

    # Classes to process
    undersampled_count = 0
    oversampled_count = 0
    balanced_count = 0

    for subcat, count in counts.items():
        subcat_df = df[df["subcategory"] == subcat]

        if count > UNDERSAMPLE_THRESHOLD:
            # Undersample
            print(f"🔻 Undersampling {subcat}: {count:,} -> {UNDERSAMPLE_TARGET:,}")
            sampled_df = subcat_df.sample(n=UNDERSAMPLE_TARGET, random_state=42)
            balanced_dfs.append(sampled_df)
            undersampled_count += 1

        elif count < OVERSAMPLE_THRESHOLD:
            # Oversample
            needed = OVERSAMPLE_TARGET - count
            print(
                f"🔺 Oversampling {subcat}: {count:,} -> {OVERSAMPLE_TARGET:,} (Need +{needed:,})"
            )

            # 1. Use existing data
            balanced_dfs.append(subcat_df)

            # 2. Check if we can generate synthetic data
            if subcat in gen_synth.MERCHANT_SEEDS:
                print(f"   ✨ Generating synthetic data for {subcat}")

                # Create a temporary output path for the generator
                temp_output_path = DATA_DIR.parent / "temp" / f"temp_{subcat}.parquet"
                temp_output_path.parent.mkdir(parents=True, exist_ok=True)

                try:
                    # Generate
                    synth_df = gen_synth.generate_synthetic_dataset(
                        {subcat: needed}, temp_output_path
                    )
                    balanced_dfs.append(synth_df)
                except Exception as e:
                    print(f"   ⚠️ Failed to generate synthetic data for {subcat}: {e}")
                    print(f"   🔄 Falling back to ROS for {subcat}")
                    ros_df = subcat_df.sample(n=needed, replace=True, random_state=42)
                    ros_df = ros_df.copy()
                    ros_df["source"] = "oversampled_ros"
                    balanced_dfs.append(ros_df)
                finally:
                    # Cleanup temp file
                    if temp_output_path.exists():
                        temp_output_path.unlink()

            else:
                # Random Oversampling (ROS)
                print(f"   🔄 Random oversampling for {subcat}")
                ros_df = subcat_df.sample(n=needed, replace=True, random_state=42)
                ros_df = ros_df.copy()
                ros_df["source"] = "oversampled_ros"
                balanced_dfs.append(ros_df)

            oversampled_count += 1

        else:
            # Keep as is
            # print(f"✅ Keeping {subcat}: {count:,}")
            balanced_dfs.append(subcat_df)
            balanced_count += 1

    # Combine
    final_df = pd.concat(balanced_dfs, ignore_index=True)
    print("\n📊 Summary:")
    print(f"  Undersampled: {undersampled_count} classes")
    print(f"  Oversampled:  {oversampled_count} classes")
    print(f"  Kept as-is:   {balanced_count} classes")
    print(f"  Original Size: {len(df):,}")
    print(f"  Balanced Size: {len(final_df):,}")

    # Shuffle
    final_df = final_df.sample(frac=1, random_state=42).reset_index(drop=True)

    # Save
    final_df.to_parquet(OUTPUT_FILE)
    print(f"\n✅ Saved balanced dataset to: {OUTPUT_FILE}")

    # Clean up empty temp dir
    temp_dir = DATA_DIR.parent / "temp"
    if temp_dir.exists() and not any(temp_dir.iterdir()):
        temp_dir.rmdir()


if __name__ == "__main__":
    balance_dataset()

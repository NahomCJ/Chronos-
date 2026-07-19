"""
Synthetic Transaction Generator for Missing Subcategories
=========================================================
Generates realistic USA transaction descriptions to fill gaps in the
Panther Ground Truth dataset.

Template-based approach ensures 100% regex match rate.
"""

import random
import pandas as pd
from pathlib import Path
from datetime import datetime
import sys

# Add parent directory to path for imports
# Add package root to path
sys.path.insert(0, str(Path(__file__).parent.parent))

# ============================================================================
# MERCHANT SEEDS BY SUBCATEGORY
# ============================================================================
MERCHANT_SEEDS = {
    "sub_delivery": [
        "DOORDASH",
        "UBER EATS",
        "UBEREATS",
        "GRUBHUB",
        "POSTMATES",
        "INSTACART",
        "SEAMLESS",
        "CAVIAR",
        "GOPUFF",
        "FAVOR DELIVERY",
        "BITE SQUAD",
        "DELIVEROO",
    ],
    "sub_hotels_acc": [
        "MARRIOTT",
        "HILTON",
        "HYATT",
        "IHG",
        "HOLIDAY INN",
        "WYNDHAM",
        "AIRBNB",
        "VRBO",
        "HOTELS.COM",
        "BOOKING.COM",
        "EXPEDIA",
        "BEST WESTERN",
        "MOTEL 6",
        "LA QUINTA",
        "COMFORT INN",
    ],
    "sub_supplementation": [
        "GNC",
        "VITAMIN SHOPPE",
        "THE VITAMIN SHOPPE",
        "MYPROTEIN",
        "HUEL",
        "ATHLETIC GREENS",
        "THORNE",
        "RITUAL",
        "SOYLENT",
        "GARDEN OF LIFE",
        "OPTUM PERKS",
        "IHERB",
        "VITACOST",
    ],
    "sub_hobbies": [
        "MICHAELS",
        "JOANN",
        "HOBBY LOBBY",
        "BLICK ART",
        "GUITAR CENTER",
        "REI",
        "DICK'S SPORTING",
        "CABELA'S",
        "BASS PRO",
        "ACADEMY SPORTS",
    ],
    "sub_family_kids": [
        "TOYS R US",
        "BUY BUY BABY",
        "CARTER'S",
        "OSHKOSH",
        "GYMBOREE",
        "CHILDREN'S PLACE",
        "KIDKRAFT",
        "BRIGHT HORIZONS",
        "KINDERCARE",
        "KUMON",
        "LEARNING TREE",
        "LITTLE TIKES",
        "SCHOLASTIC",
    ],
    "sub_pets": [
        "PETSMART",
        "PETCO",
        "CHEWY",
        "BANFIELD",
        "VCA ANIMAL",
        "PET SUPPLIES PLUS",
        "PET SUPERMARKET",
        "PETLAND",
    ],
    "sub_crypto": [
        "COINBASE",
        "BINANCE",
        "KRAKEN",
        "GEMINI",
        "CRYPTO.COM",
        "BITPAY",
        "BLOCKCHAIN",
    ],
    "sub_nfts": [
        "OPENSEA",
        "RARIBLE",
        "FOUNDATION APP",
        "SUPERRARE",
        "NIFTY GATEWAY",
        "MAGIC EDEN",
        "BLUR.IO",
    ],
    "sub_savings": [
        "ALLY SAVINGS",
        "MARCUS SAVINGS",
        "DISCOVER SAVINGS",
        "SYNCHRONY SAVINGS",
        "CAPITAL ONE SAVINGS",
        "HIGH YIELD SAVINGS",
    ],
    "sub_interest": [
        "INTEREST EARNED",
        "INT PAYMENT",
        "APY PAYMENT",
        "INTEREST DEPOSIT",
        "SAVINGS INTEREST",
    ],
}

# ============================================================================
# TEMPLATE COMPONENTS
# ============================================================================
STORE_IDS = ["#" + str(random.randint(1000, 9999)) for _ in range(200)]

LOCATIONS = [
    "NEW YORK NY",
    "LOS ANGELES CA",
    "CHICAGO IL",
    "HOUSTON TX",
    "PHOENIX AZ",
    "PHILADELPHIA PA",
    "SAN ANTONIO TX",
    "SAN DIEGO CA",
    "DALLAS TX",
    "SAN JOSE CA",
    "AUSTIN TX",
    "JACKSONVILLE FL",
    "FORT WORTH TX",
    "COLUMBUS OH",
    "CHARLOTTE NC",
    "SAN FRANCISCO CA",
    "INDIANAPOLIS IN",
    "SEATTLE WA",
    "DENVER CO",
    "BOSTON MA",
    "NASHVILLE TN",
    "DETROIT MI",
    "PORTLAND OR",
    "MEMPHIS TN",
    "LAS VEGAS NV",
    "BALTIMORE MD",
    "MILWAUKEE WI",
    "ATLANTA GA",
    "MIAMI FL",
    "TAMPA FL",
    "BROOKLYN NY",
    "QUEENS NY",
]

TXN_IDS = ["TXN" + str(random.randint(100000, 999999)) for _ in range(200)]

SUFFIXES = [
    "",
    "",
    "",  # Weight towards no suffix
    "(ACH)",
    "(Contactless)",
    "Online",
    "Store",
    "Branch",
    "Center",
    "- USA",
    "- Morning",
    "- Evening",
    "- Weekend",
]

PREFIXES = [
    "",
    "",
    "",  # Weight towards no prefix
    "POS DEBIT",
    "CHECKCARD",
    "PURCHASE",
    "DEBIT CARD",
]

# ============================================================================
# TRANSACTION TEMPLATES
# ============================================================================
# ============================================================================
# TRANSACTION TEMPLATES
# ============================================================================


def generate_pos_transaction(merchant: str) -> str:
    """Generate a Point-of-Sale (POS) style transaction."""
    template_type = random.choice(
        [
            "simple",  # MERCHANT
            "with_id",  # MERCHANT #1234
            "with_location",  # MERCHANT NEW YORK NY
            "with_id_location",  # MERCHANT #1234 NEW YORK NY
            "with_txn",  # MERCHANT TXN123456
            "with_suffix",  # MERCHANT Online
            "full",  # MERCHANT #1234 NEW YORK NY TXN123456
        ]
    )

    parts = []

    # Optional prefix (only for POS)
    if random.random() < 0.15:
        parts.append(random.choice(PREFIXES))

    parts.append(merchant)

    if template_type == "with_id":
        parts.append(random.choice(STORE_IDS))

    elif template_type == "with_location":
        parts.append(random.choice(LOCATIONS))

    elif template_type == "with_id_location":
        parts.append(random.choice(STORE_IDS))
        parts.append(random.choice(LOCATIONS))

    elif template_type == "with_txn":
        parts.append(random.choice(TXN_IDS))

    elif template_type == "with_suffix":
        parts.append(random.choice(SUFFIXES))

    elif template_type == "full":
        parts.append(random.choice(STORE_IDS))
        if random.random() < 0.5:
            parts.append(random.choice(LOCATIONS))
        parts.append(random.choice(TXN_IDS))

    return " ".join(filter(None, parts)).strip()


def generate_transfer_transaction(merchant: str) -> str:
    """Generate a Transfer style transaction (for Savings)."""
    # Patterns:
    # TRANSFER TO [BANK]
    # ONLINE TRANSFER [BANK]
    # [BANK] TRANSFER
    # TRSF TO [BANK]

    template = random.choice(
        [
            f"TRANSFER TO {merchant}",
            f"ONLINE TRANSFER TO {merchant}",
            f"{merchant} TRANSFER",
            f"TRSF TO {merchant}",
            f"{merchant} MOBILE TRANSFER",
            f"ONLINE BANKING TRANSFER {merchant}",
            f"{merchant}",  # Simple logic
        ]
    )

    # Occasionally add a TXN ID
    if random.random() < 0.3:
        template += f" {random.choice(TXN_IDS)}"

    return template


def generate_income_transaction(merchant: str) -> str:
    """Generate an Income/Interest style transaction."""
    # Patterns:
    # INTEREST PAYMENT
    # INTEREST EARNED
    # DEPOSIT [BANK]

    # For sub_interest, the "merchant" is often the description itself like "INTEREST EARNED"
    # So we often just use the merchant string, maybe with a date or ID.

    template = merchant

    if random.random() < 0.3:
        template += f" {random.choice(TXN_IDS)}"

    if random.random() < 0.2:
        template = f"DEPOSIT {template}"

    return template


def generate_transaction(merchant: str, subcategory: str) -> str:
    """Generate a realistic transaction string based on subcategory type."""

    # Determine Style
    if subcategory == "sub_savings":
        return generate_transfer_transaction(merchant)
    elif subcategory == "sub_interest":
        return generate_income_transaction(merchant)
    else:
        return generate_pos_transaction(merchant)


def generate_synthetic_dataset(
    target_per_subcategory: dict[str, int], output_path: Path
) -> pd.DataFrame:
    """Generate synthetic transactions for all specified subcategories."""

    records = []

    for subcategory, target_count in target_per_subcategory.items():
        if subcategory not in MERCHANT_SEEDS:
            print(f"⚠️  No seeds for {subcategory}, skipping")
            continue

        merchants = MERCHANT_SEEDS[subcategory]
        print(f"📦 Generating {target_count:,} records for {subcategory}...")

        for _ in range(target_count):
            merchant = random.choice(merchants)
            description = generate_transaction(merchant, subcategory)

            records.append(
                {
                    "description": description,
                    "subcategory": subcategory,
                    "source": "synthetic",
                    "generated_at": datetime.now().isoformat(),
                }
            )

    df = pd.DataFrame(records)

    # Save to parquet
    df.to_parquet(output_path, index=False)
    print(f"\n✅ Generated {len(df):,} total synthetic transactions")
    print(f"📁 Saved to: {output_path}")

    return df


def main():
    """Main entry point."""

    # Target records per subcategory (from implementation plan)
    targets = {
        "sub_delivery": 8000,
        "sub_hotels_acc": 5000,
        "sub_supplementation": 5000,
        "sub_hobbies": 5000,
        "sub_family_kids": 5000,
        "sub_pets": 5000,
        "sub_crypto": 5000,
        "sub_nfts": 3000,
        "sub_savings": 5000,
        "sub_interest": 5000,
    }

    output_dir = Path(__file__).parent.parent / "datasets" / "synthetic"
    output_dir.mkdir(parents=True, exist_ok=True)

    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    output_path = output_dir / f"synthetic_transactions_{timestamp}.parquet"

    print("=" * 60)
    print("🔧 PANTHER SYNTHETIC TRANSACTION GENERATOR")
    print("=" * 60)
    print(f"Target: {sum(targets.values()):,} total records")
    print(f"Subcategories: {len(targets)}")
    print()

    df = generate_synthetic_dataset(targets, output_path)

    # Print summary
    print("\n📊 Distribution Summary:")
    print("-" * 40)
    for subcat in df["subcategory"].value_counts().index:
        count = len(df[df["subcategory"] == subcat])
        print(f"  {subcat}: {count:,}")

    # Show sample transactions
    print("\n📝 Sample Transactions:")
    print("-" * 40)
    for subcat in list(targets.keys())[:5]:
        sample = df[df["subcategory"] == subcat]["description"].iloc[0]
        print(f"  [{subcat}] {sample}")

    return df


if __name__ == "__main__":
    main()

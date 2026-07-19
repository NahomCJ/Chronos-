"""
MitulShah Dataset Cleaner & Splitter
=====================================
Script para procesar el dataset de mitulshah:
1. Eliminar duplicados por transaction_description
2. Guardar el dataset limpio
3. Crear un dataset por cada categoría de mitulshah

Autor: Panther AI Team
Fecha: 2026-02-01
"""

import pandas as pd
from pathlib import Path
from datetime import datetime

# ============================================
# CONFIGURACIÓN
# ============================================
BASE_DIR = Path("/Users/martin/My Drive/Kalós/martinhijarx/AI Projects/CHRONOS")
RAW_DATASET_PATH = (
    BASE_DIR / "datasets/raw/mitulshah_transaction_categorization/0000.parquet"
)
CLEANED_DIR = BASE_DIR / "datasets/cleaned/mitulshah"
BY_CATEGORY_DIR = CLEANED_DIR / "by_category"

# ============================================
# FUNCIONES
# ============================================


def load_dataset():
    """Carga el dataset original de mitulshah."""
    print("=" * 60)
    print("🐆 PANTHER DATASET CLEANER - MitulShah")
    print("=" * 60)
    print(f"\n📂 Cargando dataset desde: {RAW_DATASET_PATH}")

    df = pd.read_parquet(RAW_DATASET_PATH)
    print(f"✅ Dataset cargado: {len(df):,} filas")
    print(f"📊 Columnas: {df.columns.tolist()}")
    return df


def analyze_duplicates(df):
    """Analiza duplicados en el dataset."""
    print("\n" + "-" * 60)
    print("📈 ANÁLISIS DE DUPLICADOS")
    print("-" * 60)

    total = len(df)
    unique = df["transaction_description"].nunique()
    duplicates = total - unique

    print(f"   Total filas: {total:,}")
    print(f"   Descripciones únicas: {unique:,}")
    print(f"   Duplicados a eliminar: {duplicates:,} ({duplicates/total*100:.2f}%)")

    return duplicates


def remove_duplicates(df):
    """Elimina duplicados manteniendo la primera ocurrencia."""
    print("\n" + "-" * 60)
    print("🧹 ELIMINANDO DUPLICADOS")
    print("-" * 60)

    original_count = len(df)

    # Eliminar duplicados basados en transaction_description
    # Mantenemos la primera ocurrencia
    df_clean = df.drop_duplicates(
        subset=["transaction_description"], keep="first"
    ).reset_index(drop=True)

    removed = original_count - len(df_clean)
    print(f"   Filas originales: {original_count:,}")
    print(f"   Filas después de limpieza: {len(df_clean):,}")
    print(f"   Duplicados eliminados: {removed:,}")

    return df_clean


def save_cleaned_dataset(df):
    """Guarda el dataset limpio."""
    print("\n" + "-" * 60)
    print("💾 GUARDANDO DATASET LIMPIO")
    print("-" * 60)

    # Crear directorios si no existen
    CLEANED_DIR.mkdir(parents=True, exist_ok=True)

    # Guardar en formato parquet (eficiente)
    parquet_path = CLEANED_DIR / "mitulshah_cleaned.parquet"
    df.to_parquet(parquet_path, index=False)
    print(f"   📦 Parquet: {parquet_path}")

    # También guardar en CSV para referencia
    csv_path = CLEANED_DIR / "mitulshah_cleaned.csv"
    df.to_csv(csv_path, index=False)
    print(f"   📄 CSV: {csv_path}")

    # Guardar estadísticas
    stats = {
        "total_records": len(df),
        "unique_descriptions": df["transaction_description"].nunique(),
        "categories": df["category"].value_counts().to_dict(),
        "countries": df["country"].value_counts().to_dict(),
        "currencies": df["currency"].value_counts().to_dict(),
        "cleaned_date": datetime.now().isoformat(),
    }

    stats_path = CLEANED_DIR / "stats.json"
    import json

    with open(stats_path, "w") as f:
        json.dump(stats, f, indent=2)
    print(f"   📊 Stats: {stats_path}")

    return parquet_path


def split_by_category(df):
    """Divide el dataset por categoría de mitulshah."""
    print("\n" + "-" * 60)
    print("📂 DIVIDIENDO POR CATEGORÍA")
    print("-" * 60)

    # Crear directorio
    BY_CATEGORY_DIR.mkdir(parents=True, exist_ok=True)

    categories = df["category"].unique()
    print(f"   Categorías encontradas: {len(categories)}")

    category_files = {}

    for category in sorted(categories):
        # Filtrar por categoría
        df_cat = df[df["category"] == category].reset_index(drop=True)

        # Crear nombre de archivo seguro
        safe_name = category.lower().replace(" ", "_").replace("&", "and")

        # Guardar parquet
        parquet_path = BY_CATEGORY_DIR / f"{safe_name}.parquet"
        df_cat.to_parquet(parquet_path, index=False)

        # Guardar CSV
        csv_path = BY_CATEGORY_DIR / f"{safe_name}.csv"
        df_cat.to_csv(csv_path, index=False)

        category_files[category] = {
            "records": len(df_cat),
            "parquet": str(parquet_path),
            "csv": str(csv_path),
        }

        print(f"   ✅ {category}: {len(df_cat):,} filas")

    # Guardar índice de categorías
    index_path = BY_CATEGORY_DIR / "category_index.json"
    import json

    with open(index_path, "w") as f:
        json.dump(category_files, f, indent=2)
    print(f"\n   📋 Índice guardado: {index_path}")

    return category_files


def print_summary(df, category_files):
    """Imprime resumen final."""
    print("\n" + "=" * 60)
    print("🎯 RESUMEN FINAL")
    print("=" * 60)

    print(f"\n📦 Dataset limpio total: {len(df):,} filas únicas")
    print("\n📂 Archivos por categoría:")

    for cat, info in sorted(category_files.items()):
        print(f"   • {cat}: {info['records']:,} filas")

    print("\n📁 Ubicación de archivos:")
    print(f"   • Dataset limpio: {CLEANED_DIR}")
    print(f"   • Por categoría: {BY_CATEGORY_DIR}")

    print("\n" + "=" * 60)
    print("✅ PROCESO COMPLETADO")
    print("=" * 60)


# ============================================
# EJECUCIÓN PRINCIPAL
# ============================================

if __name__ == "__main__":
    # 1. Cargar dataset
    df = load_dataset()

    # 2. Analizar duplicados
    analyze_duplicates(df)

    # 3. Eliminar duplicados
    df_clean = remove_duplicates(df)

    # 4. Guardar dataset limpio
    save_cleaned_dataset(df_clean)

    # 5. Dividir por categoría
    category_files = split_by_category(df_clean)

    # 6. Resumen final
    print_summary(df_clean, category_files)

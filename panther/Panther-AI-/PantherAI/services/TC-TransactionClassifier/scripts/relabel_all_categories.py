"""
🐆 PANTHER - Relabeling ALL Categories with Gemma3:4b
======================================================
Procesa TODAS las categorías de MitulShah y las relabela a nuestra taxonomía.

Autor: Panther AI Team
Fecha: 2026-02-01
"""

import pandas as pd
import json
import requests
import time
from pathlib import Path
from concurrent.futures import ThreadPoolExecutor, as_completed
from datetime import datetime
import re

# ============================================
# CONFIGURACIÓN
# ============================================
BASE_DIR = Path("/Users/martin/My Drive/Kalós/martinhijarx/AI Projects/CHRONOS")
DATA_DIR = BASE_DIR / "datasets/cleaned/mitulshah/by_category"
OUTPUT_DIR = BASE_DIR / "datasets/relabeled/mitulshah"
TAXONOMY_FILE = BASE_DIR / "PantherAI/TC-TransactionClassifier/TC_taxonomy.py"
MAPPING_FILE = (
    BASE_DIR
    / "PantherAI/TC-TransactionClassifier/Mapping_OurTaxonomy_with_mitulshah.py"
)

OLLAMA_URL = "http://localhost:11434/api/generate"
MODEL = "gemma3:4b"
MAX_WORKERS = 4
BATCH_SIZE = 5
SAMPLE_SIZE = 1000

# ============================================
# CARGA DE TAXONOMÍA Y MAPPING
# ============================================


def load_taxonomy():
    """Carga nuestra taxonomía con descripciones de subcategorías."""
    with open(TAXONOMY_FILE, "r") as f:
        taxonomy = json.load(f)

    # Crear diccionario subcategory_id -> info
    subcats = {}
    for cat in taxonomy["taxonomy"]:
        for sub in cat["subcategories"]:
            subcats[sub["id"]] = {
                "name": sub["name"],
                "description": sub["description"],
                "category_id": cat["id"],
                "category_name": cat["name"],
            }
    return subcats


def load_mapping():
    """Carga el mapping MitulShah -> nuestras subcategorías."""
    with open(MAPPING_FILE, "r") as f:
        mapping = json.load(f)

    # Crear diccionario mitulshah_category -> nuestras subcategorías
    category_map = {}
    for cat in mapping["categories"]:
        # Normalizar nombre (ej: "Food & Dining" -> "food_and_dining")
        file_name = cat["name"].lower().replace(" ", "_").replace("&", "and")
        category_map[file_name] = {
            "id": cat["id"],
            "name": cat["name"],
            "our_category": cat.get("our_category", "Uncategorized"),
            "subcategories": cat.get("our_subcategories_inside", []),
        }
    return category_map


# ============================================
# FUNCIONES CORE
# ============================================


def create_prompt(transactions: list[str], subcategories: dict) -> str:
    """Crea el prompt para Gemma con las transacciones y subcategorías permitidas."""

    subcats_text = "\n".join(
        [f"- {sub_id}: {info['description']}" for sub_id, info in subcategories.items()]
    )

    trans_text = "\n".join([f'{i+1}. "{t}"' for i, t in enumerate(transactions)])

    prompt = f"""You are a transaction classifier. Classify each transaction into ONE of these subcategories:

{subcats_text}

Transactions to classify:
{trans_text}

Respond ONLY with a valid JSON array. Each element must have "index" (1-{len(transactions)}) and "subcategory_id". Example:
[{{"index": 1, "subcategory_id": "sub_example"}}, {{"index": 2, "subcategory_id": "sub_other"}}]

JSON response:"""

    return prompt


def call_gemma(prompt: str, retries: int = 3) -> str:
    """Llama a Gemma3:4b via Ollama API con reintentos."""

    payload = {
        "model": MODEL,
        "prompt": prompt,
        "stream": False,
        "options": {"temperature": 0.1, "num_predict": 256},
    }

    for attempt in range(retries):
        try:
            response = requests.post(OLLAMA_URL, json=payload, timeout=60)
            response.raise_for_status()
            return response.json().get("response", "")
        except Exception as e:
            if attempt < retries - 1:
                time.sleep(1)
            else:
                raise e

    return ""


def parse_response(
    response: str,
    transactions: list[str],
    valid_subcats: list[str],
    default_subcat: str,
) -> list[dict]:
    """Parsea la respuesta JSON de Gemma."""

    results = []
    assigned = set()

    try:
        json_match = re.search(r"\[.*\]", response, re.DOTALL)
        if json_match:
            parsed = json.loads(json_match.group())

            for item in parsed:
                idx = item.get("index", 0) - 1
                sub_id = item.get("subcategory_id", default_subcat)

                # Validar subcategory_id
                if sub_id not in valid_subcats:
                    sub_id = default_subcat

                if 0 <= idx < len(transactions) and idx not in assigned:
                    results.append(
                        {
                            "transaction_description": transactions[idx],
                            "subcategory_id": sub_id,
                        }
                    )
                    assigned.add(idx)
    except (json.JSONDecodeError, KeyError, IndexError):
        pass

    # Fallback para transacciones no asignadas
    for i, t in enumerate(transactions):
        if i not in assigned:
            results.append(
                {"transaction_description": t, "subcategory_id": default_subcat}
            )

    return results


def process_batch(batch_data: tuple) -> dict:
    """Procesa un lote de transacciones."""

    batch_id, transactions, subcategories, valid_subcats, default_subcat = batch_data
    start_time = time.time()

    try:
        prompt = create_prompt(transactions, subcategories)
        response = call_gemma(prompt)
        results = parse_response(response, transactions, valid_subcats, default_subcat)

        return {
            "batch_id": batch_id,
            "success": True,
            "results": results,
            "elapsed": time.time() - start_time,
        }
    except Exception as e:
        return {
            "batch_id": batch_id,
            "success": False,
            "error": str(e),
            "results": [
                {"transaction_description": t, "subcategory_id": default_subcat}
                for t in transactions
            ],
            "elapsed": time.time() - start_time,
        }


def process_category(category_file: str, taxonomy: dict, mapping: dict) -> pd.DataFrame:
    """Procesa una categoría completa."""

    category_key = category_file.replace(".csv", "")

    if category_key not in mapping:
        print(f"   ⚠️ No mapping found for {category_key}")
        return None

    cat_info = mapping[category_key]
    subcat_ids = cat_info["subcategories"]

    if not subcat_ids:
        print(f"   ⚠️ No subcategories for {category_key}")
        return None

    # Obtener info de subcategorías
    subcategories = {sid: taxonomy[sid] for sid in subcat_ids if sid in taxonomy}

    if not subcategories:
        print(f"   ⚠️ No valid subcategories for {category_key}")
        return None

    default_subcat = subcat_ids[0]

    print(f"\n{'='*70}")
    print(f"📂 {cat_info['name']}")
    print(f"{'='*70}")
    print(f"   Subcategorías: {', '.join(subcat_ids)}")

    # Cargar datos
    df = pd.read_csv(DATA_DIR / category_file)
    print(f"   Total: {len(df):,} | Sample: {min(SAMPLE_SIZE, len(df)):,}")

    # Muestrear
    sample_size = min(SAMPLE_SIZE, len(df))
    df_sample = df.sample(n=sample_size, random_state=42).reset_index(drop=True)
    transactions = df_sample["transaction_description"].tolist()

    # Crear batches
    batches = []
    for i in range(0, len(transactions), BATCH_SIZE):
        batch_trans = transactions[i : i + BATCH_SIZE]
        batches.append(
            (len(batches), batch_trans, subcategories, subcat_ids, default_subcat)
        )

    print(f"   Batches: {len(batches)}")

    # Procesar en paralelo
    all_results = []
    errors = 0
    start_time = time.time()

    with ThreadPoolExecutor(max_workers=MAX_WORKERS) as executor:
        futures = {executor.submit(process_batch, batch): batch[0] for batch in batches}

        completed = 0
        for future in as_completed(futures):
            result = future.result()
            completed += 1
            all_results.extend(result["results"])

            if not result["success"]:
                errors += 1

            # Progress cada 20%
            if completed % max(1, len(batches) // 5) == 0 or completed == len(batches):
                pct = completed / len(batches) * 100
                print(f"   Progress: {completed}/{len(batches)} ({pct:.0f}%)")

    elapsed = time.time() - start_time

    # Crear DataFrame
    df_results = pd.DataFrame(all_results)
    df_results["original_category"] = cat_info["name"]
    df_results["our_category"] = cat_info["our_category"]

    # Añadir nombres de subcategorías
    df_results["subcategory_name"] = df_results["subcategory_id"].map(
        lambda x: taxonomy.get(x, {}).get("name", "Unknown")
    )

    # Reordenar
    df_results = df_results[
        [
            "transaction_description",
            "original_category",
            "our_category",
            "subcategory_id",
            "subcategory_name",
        ]
    ]

    # Stats
    print(
        f"\n   ✅ Procesado: {len(df_results):,} tx en {elapsed:.1f}s ({len(df_results)/elapsed:.1f} tx/s)"
    )
    print("   Distribución:")
    for sub_id, count in df_results["subcategory_id"].value_counts().items():
        pct = count / len(df_results) * 100
        print(f"      • {sub_id}: {count} ({pct:.1f}%)")

    return df_results


# ============================================
# MAIN
# ============================================


def main():
    print("=" * 70)
    print("🐆 PANTHER RELABELER - ALL CATEGORIES")
    print("=" * 70)
    print(f"   Model: {MODEL} | Workers: {MAX_WORKERS} | Batch: {BATCH_SIZE}")

    # Cargar taxonomía y mapping
    print("\n📚 Cargando taxonomía y mapping...")
    taxonomy = load_taxonomy()
    mapping = load_mapping()
    print(f"   Taxonomía: {len(taxonomy)} subcategorías")
    print(f"   Mapping: {len(mapping)} categorías")

    # Listar archivos de categorías
    category_files = sorted([f.name for f in DATA_DIR.glob("*.csv")])
    print(f"\n📁 Categorías a procesar: {len(category_files)}")

    # Procesar cada categoría
    all_dfs = []
    start_total = time.time()

    for category_file in category_files:
        df_result = process_category(category_file, taxonomy, mapping)
        if df_result is not None:
            all_dfs.append(df_result)

            # Guardar individualmente
            timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
            category_name = category_file.replace(".csv", "")
            output_path = OUTPUT_DIR / f"{category_name}_relabeled_{timestamp}.csv"
            df_result.to_csv(output_path, index=False)

    # Combinar todos
    if all_dfs:
        df_all = pd.concat(all_dfs, ignore_index=True)

        # Guardar combinado
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        combined_path = OUTPUT_DIR / f"ALL_CATEGORIES_relabeled_{timestamp}.csv"
        df_all.to_csv(combined_path, index=False)

        parquet_path = OUTPUT_DIR / f"ALL_CATEGORIES_relabeled_{timestamp}.parquet"
        df_all.to_parquet(parquet_path, index=False)

        elapsed_total = time.time() - start_total

        print("\n" + "=" * 70)
        print("🎯 RESUMEN FINAL")
        print("=" * 70)
        print(f"   Total procesado: {len(df_all):,} transacciones")
        print(f"   Tiempo total: {elapsed_total/60:.1f} minutos")
        print(f"   Archivo combinado: {combined_path.name}")

        print("\n   Distribución por categoría original:")
        for cat, count in df_all["original_category"].value_counts().items():
            print(f"      • {cat}: {count}")

        print("\n   Top 10 subcategorías asignadas:")
        for sub_id, count in df_all["subcategory_id"].value_counts().head(10).items():
            pct = count / len(df_all) * 100
            print(f"      • {sub_id}: {count} ({pct:.1f}%)")

    print("\n" + "=" * 70)
    print("✅ RELABELING DE TODAS LAS CATEGORÍAS COMPLETADO")
    print("=" * 70)


if __name__ == "__main__":
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    main()

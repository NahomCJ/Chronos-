import os
import re
import torch
import pandas as pd
from datasets import Dataset
from transformers import (
    DistilBertTokenizerFast,
    DistilBertForSequenceClassification,
    Trainer,
    TrainingArguments,
)
from sklearn.model_selection import train_test_split
from sklearn.metrics import (
    accuracy_score,
    precision_recall_fscore_support,
    confusion_matrix,
)

# Constants
DATASET_PATH = "datasets/processed/panther_ground_truth_v3_balanced.parquet"
MODEL_PATH = "PantherAI/TC-TransactionClassifier/models/distilbert_v1_colab"
AUDIT_DIR = "PantherAI/TC-TransactionClassifier/audit"
MAX_LENGTH = 64
BATCH_SIZE = 128


def normalize_text(text):
    text = str(text).upper()
    text = re.sub(r"#\S+", "", text)
    text = re.sub(r"TXN\S+", "", text)
    text = re.sub(r"\d+", " ", text)
    text = re.sub(r"\s+", " ", text).strip()
    return text


def compute_metrics(pred):
    labels = pred.label_ids
    preds = pred.predictions.argmax(-1)
    precision, recall, f1, _ = precision_recall_fscore_support(
        labels, preds, average="weighted", zero_division=0
    )
    acc = accuracy_score(labels, preds)
    return {"accuracy": acc, "f1": f1, "precision": precision, "recall": recall}


def main():
    print(f"Loading dataset from {DATASET_PATH}...")
    df = pd.read_parquet(DATASET_PATH)

    print("Normalizing text...")
    df["clean_description"] = df["description"].apply(normalize_text)

    # Create labels (same sequence as training)
    labels_list = sorted(df["subcategory"].unique().tolist())
    label2id = {label: i for i, label in enumerate(labels_list)}
    id2label = {i: label for i, label in enumerate(labels_list)}
    num_labels = len(labels_list)

    df["label"] = df["subcategory"].map(label2id)

    # Use the same seed as training for the split
    print("Splitting to isolate the test set (same 80/10/10 split)...")
    train_df, temp_df = train_test_split(
        df, test_size=0.2, random_state=42, stratify=df["label"]
    )
    val_df, test_df = train_test_split(
        temp_df, test_size=0.5, random_state=42, stratify=temp_df["label"]
    )

    print(f"Test size: {len(test_df)}")

    # Convert to HF Dataset
    test_dataset = Dataset.from_pandas(test_df[["clean_description", "label"]])

    # Tokenization
    print("Tokenizing...")
    tokenizer = DistilBertTokenizerFast.from_pretrained(MODEL_PATH)

    def tokenize_function(examples):
        return tokenizer(
            examples["clean_description"],
            padding="max_length",
            truncation=True,
            max_length=MAX_LENGTH,
        )

    test_dataset = test_dataset.map(tokenize_function, batched=True)
    test_dataset.set_format(
        type="torch", columns=["input_ids", "attention_mask", "label"]
    )

    # Load Model
    print("Loading model...")
    model = DistilBertForSequenceClassification.from_pretrained(MODEL_PATH)

    # Initializing Trainer just for eval
    training_args = TrainingArguments(
        output_dir="./temp_eval",
        per_device_eval_batch_size=BATCH_SIZE,
        report_to="none",
    )

    trainer = Trainer(model=model, args=training_args, compute_metrics=compute_metrics)

    # Evaluate
    print("Running evaluation...")
    results = trainer.evaluate(test_dataset)
    print("\n" + "=" * 30)
    print("OVERALL PERFORMANCE:")
    print(f"Accuracy:  {results['eval_accuracy']:.4f}")
    print(f"F1 Score:  {results['eval_f1']:.4f}")
    print(f"Precision: {results['eval_precision']:.4f}")
    print(f"Recall:    {results['eval_recall']:.4f}")
    print("=" * 30)

    # Detailed report
    print("Generating predictions for detailed analysis...")
    predictions = trainer.predict(test_dataset)
    y_true = predictions.label_ids
    y_pred = predictions.predictions.argmax(-1)

    # Per-class metrics
    p, r, f, s = precision_recall_fscore_support(
        y_true, y_pred, average=None, labels=range(num_labels)
    )

    class_report = pd.DataFrame(
        {"subcategory": labels_list, "precision": p, "recall": r, "f1": f, "support": s}
    ).sort_values("f1", ascending=False)

    os.makedirs(AUDIT_DIR, exist_ok=True)
    class_report.to_csv(f"{AUDIT_DIR}/per_class_metrics.csv", index=False)
    print(f"Saved per-class metrics to {AUDIT_DIR}/per_class_metrics.csv")

    # Identify failures
    test_df["pred_label"] = [id2label[i] for i in y_pred]
    test_df["pred_prob"] = (
        torch.nn.functional.softmax(torch.tensor(predictions.predictions), dim=-1)
        .max(dim=1)
        .values.numpy()
    )

    failures = test_df[test_df["subcategory"] != test_df["pred_label"]].copy()
    failures[
        ["description", "clean_description", "subcategory", "pred_label", "pred_prob"]
    ].to_csv(f"{AUDIT_DIR}/failure_cases_v1.csv", index=False)
    print(f"Saved {len(failures)} failures to {AUDIT_DIR}/failure_cases_v1.csv")

    # Confusion Matrix (Text summary of biggest confusions)
    cm = confusion_matrix(y_true, y_pred)
    # Find indices where model is most confused (excluding diagonal)
    confusions = []
    for i in range(num_labels):
        for j in range(num_labels):
            if i != j and cm[i, j] > 10:  # Only significant confusions
                confusions.append((labels_list[i], labels_list[j], cm[i, j]))

    confusions = sorted(confusions, key=lambda x: x[2], reverse=True)
    print("\nBIGGEST CONFUSIONS (True -> Pred):")
    for t, p, count in confusions[:10]:
        print(f"{t:25} -> {p:25} | Count: {count}")


if __name__ == "__main__":
    main()

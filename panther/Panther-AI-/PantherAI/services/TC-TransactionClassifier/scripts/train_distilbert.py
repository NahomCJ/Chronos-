import os
import re
import torch
import torch.nn as nn
import torch.nn.functional as F
import numpy as np
import pandas as pd
from datasets import Dataset
from transformers import (
    DistilBertTokenizerFast,
    DistilBertForSequenceClassification,
    Trainer,
    TrainingArguments,
    EarlyStoppingCallback,
)
from sklearn.model_selection import train_test_split
from sklearn.metrics import accuracy_score, precision_recall_fscore_support
from sklearn.utils.class_weight import compute_class_weight

# Constants
DATASET_PATH = "datasets/processed/panther_ground_truth_v3_balanced.parquet"
MODEL_NAME = "distilbert-base-uncased"
OUTPUT_DIR = "PantherAI/TC-TransactionClassifier/models/distilbert_v1"
LOG_DIR = f"{OUTPUT_DIR}/logs"
AUDIT_DIR = "PantherAI/TC-TransactionClassifier/audit"
MAX_LENGTH = 64
BATCH_SIZE = 32
EPOCHS = 5


def normalize_text(text):
    """
    Aggressive text normalization to strip PII and transient IDs using regex.
    """
    text = str(text).upper()
    # Remove hashtags followed by non-whitespace (e.g., #1234, #Store5)
    text = re.sub(r"#\S+", "", text)
    # Remove TXN followed by non-whitespace
    text = re.sub(r"TXN\S+", "", text)
    # Replace sequences of digits with a single space
    text = re.sub(r"\d+", " ", text)
    # Replace multiple spaces with single space and strip
    text = re.sub(r"\s+", " ", text).strip()
    return text


class FocalLoss(nn.Module):
    """
    Focal Loss implementation for hard-to-classify examples.
    FL(pt) = -alpha_t * (1 - pt)^gamma * log(pt)
    """

    def __init__(self, alpha=None, gamma=2.0):
        super(FocalLoss, self).__init__()
        self.alpha = alpha
        self.gamma = gamma

    def forward(self, inputs, targets):
        # inputs: logits, targets: labels
        ce_loss = F.cross_entropy(inputs, targets, reduction="none", weight=self.alpha)
        pt = torch.exp(-ce_loss)
        focal_loss = ((1 - pt) ** self.gamma) * ce_loss
        return focal_loss.mean()


def compute_metrics(pred):
    labels = pred.label_ids
    preds = pred.predictions.argmax(-1)
    precision, recall, f1, _ = precision_recall_fscore_support(
        labels, preds, average="weighted", zero_division=0
    )
    acc = accuracy_score(labels, preds)
    return {"accuracy": acc, "f1": f1, "precision": precision, "recall": recall}


class CustomTrainer(Trainer):
    def __init__(self, class_weights, *args, **kwargs):
        super().__init__(*args, **kwargs)
        # Ensure weights are a tensor
        if class_weights is not None:
            self.class_weights = torch.tensor(class_weights, dtype=torch.float32)
        else:
            self.class_weights = None
        self.focal_loss = FocalLoss(alpha=self.class_weights, gamma=2.0)

    def compute_loss(
        self, model, inputs, return_outputs=False, num_items_in_batch=None
    ):
        labels = inputs.get("labels")
        outputs = model(**inputs)
        logits = outputs.get("logits")

        # Move weights to the same device as logits if needed
        if (
            self.class_weights is not None
            and self.class_weights.device != logits.device
        ):
            self.class_weights = self.class_weights.to(logits.device)
            self.focal_loss.alpha = self.class_weights

        loss = self.focal_loss(
            logits.view(-1, self.model.config.num_labels), labels.view(-1)
        )
        return (loss, outputs) if return_outputs else loss


def main(debug=False):
    print(f"Loading dataset from {DATASET_PATH}...")
    try:
        df = pd.read_parquet(DATASET_PATH)
    except FileNotFoundError:
        print(f"Error: File not found at {DATASET_PATH}")
        return

    # Helper to check original column presence
    if "description" not in df.columns:
        print("Error: 'description' column missing.")
        return

    if debug:
        print("DEBUG MODE: Subsampling dataset for speed...")
        df = df.sample(n=1000, random_state=42)

    print("Normalizing text...")
    df["clean_description"] = df["description"].apply(normalize_text)

    # Create labels
    labels = sorted(df["subcategory"].unique().tolist())
    label2id = {label: i for i, label in enumerate(labels)}
    id2label = {i: label for i, label in enumerate(labels)}
    num_labels = len(labels)
    print(f"Found {num_labels} classes.")

    df["label"] = df["subcategory"].map(label2id)

    # Split
    print("Splitting dataset 80/10/10...")
    stratify_col = None if debug else df["label"]
    train_df, temp_df = train_test_split(
        df, test_size=0.2, random_state=42, stratify=stratify_col
    )

    stratify_col_temp = None if debug else temp_df["label"]
    val_df, test_df = train_test_split(
        temp_df, test_size=0.5, random_state=42, stratify=stratify_col_temp
    )

    # Save test_df for error analysis later
    test_df_analysis = test_df.copy()

    print(f"Train size: {len(train_df)}")
    print(f"Val size: {len(val_df)}")
    print(f"Test size: {len(test_df)}")

    # Compute class weights
    print("Computing class weights...")
    class_weights = compute_class_weight(
        class_weight="balanced",
        classes=np.unique(train_df["label"]),
        y=train_df["label"],
    )

    # Convert to HF Dataset - USING CLEAN DESCRIPTION
    train_dataset = Dataset.from_pandas(train_df[["clean_description", "label"]])
    val_dataset = Dataset.from_pandas(val_df[["clean_description", "label"]])
    test_dataset = Dataset.from_pandas(test_df[["clean_description", "label"]])

    # Tokenization
    print("Tokenizing...")
    tokenizer = DistilBertTokenizerFast.from_pretrained(MODEL_NAME)

    def tokenize_function(examples):
        return tokenizer(
            examples["clean_description"],
            padding="max_length",
            truncation=True,
            max_length=MAX_LENGTH,
        )

    train_dataset = train_dataset.map(tokenize_function, batched=True)
    val_dataset = val_dataset.map(tokenize_function, batched=True)
    test_dataset = test_dataset.map(tokenize_function, batched=True)

    # Set format
    train_dataset.set_format(
        type="torch", columns=["input_ids", "attention_mask", "label"]
    )
    val_dataset.set_format(
        type="torch", columns=["input_ids", "attention_mask", "label"]
    )
    test_dataset.set_format(
        type="torch", columns=["input_ids", "attention_mask", "label"]
    )

    # Model
    print("Initializing model...")
    model = DistilBertForSequenceClassification.from_pretrained(
        MODEL_NAME, num_labels=num_labels, id2label=id2label, label2id=label2id
    )

    # Training Args
    training_args = TrainingArguments(
        output_dir=OUTPUT_DIR,
        num_train_epochs=EPOCHS if not debug else 1,
        max_steps=10 if debug else -1,
        per_device_train_batch_size=BATCH_SIZE,
        per_device_eval_batch_size=BATCH_SIZE * 2,
        warmup_steps=500,
        weight_decay=0.01,
        logging_dir=LOG_DIR,
        logging_steps=100,
        eval_strategy="steps",
        eval_steps=500,
        save_strategy="steps",
        save_steps=500,
        load_best_model_at_end=True,
        metric_for_best_model="accuracy",
        label_smoothing_factor=0.1,  # Added label smoothing
        report_to="none",
    )

    print(f"Device found: {training_args.device}")

    trainer = CustomTrainer(
        class_weights=class_weights,
        model=model,
        args=training_args,
        train_dataset=train_dataset,
        eval_dataset=val_dataset,
        compute_metrics=compute_metrics,
        callbacks=[EarlyStoppingCallback(early_stopping_patience=3)],
    )

    # Train
    print("Starting training...")
    trainer.train()

    # Evaluate
    print("Evaluating on test set ( metrics)...")
    test_results = trainer.evaluate(test_dataset)
    print(f"Test Results: {test_results}")

    # --- ERROR ANALYSIS ---
    print("Running detailed error analysis on test set...")

    # Get predictions
    raw_pred, _, _ = trainer.predict(test_dataset)
    # Apply softmax to get probabilities
    probs = torch.nn.functional.softmax(torch.tensor(raw_pred), dim=-1)

    # Get best class and confidence
    max_probs, preds = torch.max(probs, dim=1)

    # Add to analysis dataframe
    test_df_analysis["normalized_text"] = test_df_analysis[
        "clean_description"
    ]  # Already has it, but good to be explicit
    test_df_analysis["true_label_id"] = test_df_analysis["label"]
    test_df_analysis["pred_label_id"] = preds.numpy()
    test_df_analysis["confidence"] = max_probs.numpy()

    # Map IDs back to labels
    test_df_analysis["true_label"] = test_df_analysis["true_label_id"].map(id2label)
    test_df_analysis["pred_label"] = test_df_analysis["pred_label_id"].map(id2label)

    # Filter for failures
    failures = test_df_analysis[
        test_df_analysis["true_label_id"] != test_df_analysis["pred_label_id"]
    ].copy()

    # Select columns
    output_cols = [
        "description",
        "normalized_text",
        "true_label",
        "pred_label",
        "confidence",
    ]
    failures_out = failures[output_cols]

    # Save
    os.makedirs(AUDIT_DIR, exist_ok=True)
    failure_path = f"{AUDIT_DIR}/failure_cases.csv"
    failures_out.to_csv(failure_path, index=False)
    print(f"Saved {len(failures_out)} failure cases to {failure_path}")

    # Save model
    print(f"Saving model to {OUTPUT_DIR}...")
    trainer.save_model(OUTPUT_DIR)
    tokenizer.save_pretrained(OUTPUT_DIR)

    print("Done!")

    print("Done!")


if __name__ == "__main__":
    import argparse

    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--debug",
        action="store_true",
        help="Run a short 10-step training for debugging",
    )
    args = parser.parse_args()

    # Patch main to use args or refactor.
    # Since main() doesn't take args, I'll modify main to accept them or just set global vars.
    # Refactoring main to take args is cleaner.
    main(debug=args.debug)

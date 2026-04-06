"""
generate_embeddings.py
======================
One-time script to generate sentence embeddings for all tools.
Run this locally before deploying.

Usage:
    pip install sentence-transformers pandas pyarrow
    python generate_embeddings.py

Output:
    ../data/embeddings.rds  (via rpy2)
    ../data/embeddings.pkl  (Python pickle as backup)
"""

import os
import pickle
import pandas as pd
import numpy as np
from sentence_transformers import SentenceTransformer

# ---- Config ------------------------------------------------
CSV_PATH = "../data/tools.csv"
OUTPUT_PKL = "../data/embeddings.pkl"
MODEL_NAME = "all-MiniLM-L6-v2"  # Fast, good quality, 384-dim

# ---- Load data ---------------------------------------------
print(f"Loading tools from {CSV_PATH}...")
df = pd.read_csv(CSV_PATH)

# Build rich text for embedding — combine multiple fields
def build_embedding_text(row):
    parts = [
        str(row.get("name", "")),
        str(row.get("short_description", "")),
        str(row.get("biological_domain", "")),
        str(row.get("ai_technique", "")),
        str(row.get("tags", "")),
    ]
    return " | ".join([p for p in parts if p and p != "nan"])

df["embed_text"] = df.apply(build_embedding_text, axis=1)

print(f"Loaded {len(df)} tools")

# ---- Generate embeddings -----------------------------------
print(f"Loading model: {MODEL_NAME}...")
model = SentenceTransformer(MODEL_NAME)

print("Generating embeddings...")
embeddings = model.encode(
    df["embed_text"].tolist(),
    batch_size=32,
    show_progress_bar=True,
    normalize_embeddings=True  # Pre-normalize for faster cosine sim
)

print(f"Embeddings shape: {embeddings.shape}")

# ---- Save --------------------------------------------------
# Save as pickle for Python use
output = {
    "ids": df["id"].tolist() if "id" in df.columns else list(range(len(df))),
    "names": df["name"].tolist(),
    "matrix": embeddings,
    "model": MODEL_NAME,
    "dim": embeddings.shape[1]
}

with open(OUTPUT_PKL, "wb") as f:
    pickle.dump(output, f)

print(f"Saved embeddings to {OUTPUT_PKL}")

# ---- Convert to R-readable format -------------------------
# Save matrix as CSV so R can load without reticulate if needed
emb_df = pd.DataFrame(embeddings)
emb_df.insert(0, "tool_id", output["ids"])
emb_df.to_csv("../data/embeddings_matrix.csv", index=False)
print("Also saved embeddings_matrix.csv for R fallback")

print("\n✅ Done! Now run in R:")
print('  emb <- readr::read_csv("data/embeddings_matrix.csv")')
print('  # Or use reticulate for live query embedding')

# Architecture Overview — BioAI Navigator

## System Design

```
┌─────────────────────────────────────────────┐
│                  User Browser               │
└────────────────────┬────────────────────────┘
                     │ HTTP
┌────────────────────▼────────────────────────┐
│           R Shiny Application               │
│                                             │
│  ┌──────────┐  ┌────────────┐  ┌─────────┐ │
│  │ Directory│  │Description │  │ Compare │ │
│  │  Module  │  │   Module   │  │ Module  │ │
│  └────┬─────┘  └─────┬──────┘  └────┬────┘ │
│       │              │              │       │
│  ┌────▼──────────────▼──────────────▼────┐ │
│  │           Server Logic                │ │
│  │   utils_search.R  utils_semantic.R    │ │
│  │   utils_data.R    modules_ratings.R   │ │
│  └────────────────┬──────────────────────┘ │
└───────────────────┼─────────────────────────┘
                    │
        ┌───────────┴───────────┐
        │                       │
┌───────▼────────┐   ┌──────────▼──────────┐
│  Google Sheets │   │  embeddings.rds      │
│  (live data)   │   │  (pre-computed)      │
│  - tools       │   │  sentence-transformers│
│  - ratings     │   │  all-MiniLM-L6-v2   │
│  - submissions │   └─────────────────────┘
└────────────────┘
```

## Semantic Search Flow

1. **One-time**: Python script reads tool descriptions → generates embeddings using `sentence-transformers` (all-MiniLM-L6-v2) → saves as `embeddings.rds`
2. **Runtime**: User types query → R computes cosine similarity between query embedding and stored embeddings → returns ranked results
3. **Fallback**: If embeddings unavailable, falls back to keyword search via `stringr`

## Module Structure

Each tab is a self-contained Shiny module (UI + server) for maintainability and reusability.

## Data Flow

Google Sheets → `googlesheets4::read_sheet()` → reactive data frame → modules

Ratings/submissions → Google Sheets append via `googlesheets4::sheet_append()`

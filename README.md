# BioAI Navigator 🧬

> A community-driven directory of AI tools for biological research.

BioAI Navigator is a production-quality R Shiny web application that helps researchers discover, compare, and evaluate AI-powered tools across genomics, proteomics, drug discovery, microscopy, and more.

Think of it as **Product Hunt for AI tools in biology**.

---

## 🔗 Live App
[bioai-navigator.shinyapps.io](#) *(link after deployment)*

---

## ✨ Features

- 🔍 **Semantic Search** — embedding-based search beyond keywords
- 🗂️ **Directory** — 60+ curated AI biology tools with rich metadata
- 📄 **Tool Profiles** — full descriptions, screenshots, links, publications
- ⚖️ **Tool Comparison** — side-by-side comparison of 2–3 tools
- ⭐ **Ratings & Comments** — community feedback on each tool
- ➕ **Submit a Tool** — community-maintained submissions

---

## 🛠️ Tech Stack

| Layer | Technology |
|-------|-----------|
| Framework | R Shiny + bslib |
| Data | Google Sheets API via `googlesheets4` |
| Tables | `reactable` |
| Semantic Search | Python `sentence-transformers` → `.rds` embeddings |
| Deployment | shinyapps.io |

---

## 📁 Repository Structure

```
bioai-navigator/
├── app.R                  # Entry point
├── R/
│   ├── ui.R               # Main UI layout
│   ├── server.R           # Main server logic
│   ├── modules_directory.R    # Directory tab module
│   ├── modules_description.R  # Tool profile module
│   ├── modules_compare.R      # Comparison module
│   ├── modules_submit.R       # Submit a tool module
│   ├── modules_ratings.R      # Ratings & comments module
│   ├── utils_data.R           # Data loading (Google Sheets)
│   ├── utils_search.R         # Keyword + semantic search
│   └── utils_semantic.R       # Cosine similarity logic
├── data/
│   └── tools.csv          # Fallback local dataset
├── scripts/
│   ├── generate_embeddings.py # One-time Python embedding script
│   └── seed_data.R            # Data seeding helpers
├── www/
│   └── css/custom.css     # Custom styling
├── docs/
│   ├── product_description.md
│   ├── architecture.md
│   └── data_schema.md
└── README.md
```

---

## 🚀 Getting Started

### Prerequisites
- R >= 4.2
- Python >= 3.9 (for embedding generation only)

### Installation

```r
# Install renv and restore packages
install.packages("renv")
renv::restore()
```

### Running locally

```r
shiny::runApp()
```

### Generating semantic embeddings (one-time)

```bash
cd scripts
pip install sentence-transformers pandas
python generate_embeddings.py
```

---

## 📊 Data Schema

See `docs/data_schema.md` for full field definitions.

---

## 👥 Contributors

Built by the HackBio Dev Team as part of the BioAI Navigator capstone project.

---

## 📄 License

MIT

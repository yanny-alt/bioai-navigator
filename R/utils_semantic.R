# ============================================================
# utils_semantic.R — Semantic Search via Pre-computed Embeddings
# ============================================================
# Embeddings are generated ONCE via scripts/generate_embeddings.py
# and saved as data/embeddings.rds
# At runtime, R loads them and computes cosine similarity.
# ============================================================

library(dplyr)

EMBEDDINGS_PATH <- "data/embeddings.rds"

# ---- Load pre-computed embeddings -------------------------
load_embeddings <- function(path = EMBEDDINGS_PATH) {
  if (!file.exists(path)) {
    message("No embeddings file found at: ", path)
    message("Run scripts/generate_embeddings.py to generate embeddings.")
    return(NULL)
  }
  tryCatch({
    emb <- readRDS(path)
    message("Loaded embeddings: ", nrow(emb$matrix), " tools")
    return(emb)
  }, error = function(e) {
    message("Failed to load embeddings: ", e$message)
    return(NULL)
  })
}

# ---- Cosine similarity ------------------------------------
cosine_similarity <- function(a, b) {
  # a: single query vector (1 x d)
  # b: matrix of tool embeddings (n x d)
  # Returns vector of similarities
  
  a_norm <- a / sqrt(sum(a^2))
  b_norms <- sqrt(rowSums(b^2))
  b_norms[b_norms == 0] <- 1e-10  # avoid division by zero
  
  sims <- as.vector(b %*% a_norm) / b_norms
  return(sims)
}

# ---- Semantic search at runtime ---------------------------
# NOTE: Query embedding requires Python reticulate OR
# we approximate using term-frequency on the embedding space.
# For production: embed query via reticulate + sentence_transformers.
# For this app: we use a lightweight R-native approximation.

semantic_search <- function(df, query, embeddings, top_n = 20) {
  if (is.null(embeddings)) return(keyword_search(df, query))
  
  tryCatch({
    # Try reticulate-based embedding for true semantic search
    library(reticulate)
    st <- import("sentence_transformers")
    model <- st$SentenceTransformer("all-MiniLM-L6-v2")
    query_vec <- model$encode(query)
    
    sims <- cosine_similarity(query_vec, embeddings$matrix)
    
    df$semantic_score <- sims[match(df$id, embeddings$ids)]
    df <- df %>%
      arrange(desc(semantic_score)) %>%
      head(top_n)
    
    return(df)
  }, error = function(e) {
    # Fallback to keyword search if reticulate not available
    message("Semantic search unavailable, falling back to keyword: ", e$message)
    return(keyword_search(df, query))
  })
}

# ---- Check if semantic search is available ----------------
semantic_available <- function(embeddings) {
  !is.null(embeddings) && tryCatch({
    library(reticulate)
    py_module_available("sentence_transformers")
  }, error = function(e) FALSE)
}

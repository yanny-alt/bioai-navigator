# ============================================================
# utils_search.R — Keyword Search & Filtering Logic
# ============================================================

library(dplyr)
library(stringr)

# ---- Keyword Search ----------------------------------------
# Searches across name, description, domain, technique, tags
keyword_search <- function(df, query) {
  if (is.null(query) || trimws(query) == "") return(df)
  
  query <- tolower(trimws(query))
  
  df %>%
    filter(
      str_detect(tolower(name),              query) |
      str_detect(tolower(short_description), query) |
      str_detect(tolower(biological_domain), query) |
      str_detect(tolower(ai_technique),      query) |
      str_detect(tolower(tags),              query)
    )
}

# ---- Filter Tools ------------------------------------------
filter_tools <- function(df,
                         domain    = NULL,
                         technique = NULL,
                         data_type = NULL,
                         license   = NULL,
                         year_min  = NULL,
                         year_max  = NULL) {
  
  if (!is.null(domain)    && domain    != "All") df <- df %>% filter(biological_domain == domain)
  if (!is.null(technique) && technique != "All") df <- df %>% filter(ai_technique == technique)
  if (!is.null(data_type) && data_type != "All") df <- df %>% filter(data_type == data_type)
  if (!is.null(license)   && license   != "All") {
    if (license == "Open-source") {
      df <- df %>% filter(str_detect(tolower(license), "open"))
    } else {
      df <- df %>% filter(!str_detect(tolower(license), "open"))
    }
  }
  if (!is.null(year_min) && !is.na(year_min)) df <- df %>% filter(year_released >= year_min)
  if (!is.null(year_max) && !is.na(year_max)) df <- df %>% filter(year_released <= year_max)
  
  df
}

# ---- Combined search + filter ------------------------------
search_and_filter <- function(df, query = NULL,
                               domain = NULL, technique = NULL,
                               data_type = NULL, license = NULL,
                               year_min = NULL, year_max = NULL,
                               use_semantic = FALSE,
                               embeddings = NULL) {
  
  # If semantic search is available and query exists, use it
  if (use_semantic && !is.null(embeddings) && !is.null(query) && trimws(query) != "") {
    df <- semantic_search(df, query, embeddings, top_n = nrow(df))
  } else {
    df <- keyword_search(df, query)
  }
  
  # Apply filters on top of search
  df <- filter_tools(df, domain, technique, data_type, license, year_min, year_max)
  
  df
}

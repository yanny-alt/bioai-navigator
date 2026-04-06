# ============================================================
# utils_data.R — Data Loading & Google Sheets Integration
# ============================================================

library(googlesheets4)
library(dplyr)
library(readr)

# ---- Configuration ----------------------------------------
# Set your Google Sheet ID here after creating the sheet
SHEET_ID <- Sys.getenv("BIOAI_SHEET_ID", unset = NA)
TOOLS_SHEET     <- "tools"
RATINGS_SHEET   <- "ratings"
SUBMISSIONS_SHEET <- "submissions"

# ---- Load Tools -------------------------------------------
load_tools <- function(use_local_fallback = TRUE) {
  if (!is.na(SHEET_ID)) {
    tryCatch({
      message("Loading tools from Google Sheets...")
      gs4_deauth()  # Public sheet — no auth needed
      df <- read_sheet(SHEET_ID, sheet = TOOLS_SHEET)
      df <- clean_tools(df)
      return(df)
    }, error = function(e) {
      message("Google Sheets failed, falling back to local CSV: ", e$message)
    })
  }
  
  if (use_local_fallback) {
    message("Loading tools from local CSV...")
    df <- read_csv("data/tools.csv", show_col_types = FALSE)
    df <- clean_tools(df)
    return(df)
  }
  
  stop("No data source available. Set BIOAI_SHEET_ID or provide data/tools.csv")
}

# ---- Clean & Standardize ----------------------------------
clean_tools <- function(df) {
  # Standardize column names
  names(df) <- tolower(gsub(" ", "_", names(df)))
  
  # Ensure required columns exist
  required_cols <- c("name", "short_description", "biological_domain",
                     "ai_technique", "data_type", "link", "year_released")
  
  missing <- setdiff(required_cols, names(df))
  if (length(missing) > 0) {
    warning("Missing columns: ", paste(missing, collapse = ", "))
  }
  
  # Add id if not present
  if (!"id" %in% names(df)) df$id <- seq_len(nrow(df))
  
  # Clean year
  if ("year_released" %in% names(df)) {
    df$year_released <- suppressWarnings(as.integer(df$year_released))
  }
  
  # Clean tags — ensure string
  if ("tags" %in% names(df)) {
    df$tags <- as.character(df$tags)
    df$tags[is.na(df$tags)] <- ""
  }
  
  # Remove duplicates by name
  df <- df %>% distinct(name, .keep_all = TRUE)
  
  return(df)
}

# ---- Load Ratings -----------------------------------------
load_ratings <- function() {
  if (!is.na(SHEET_ID)) {
    tryCatch({
      gs4_deauth()
      return(read_sheet(SHEET_ID, sheet = RATINGS_SHEET))
    }, error = function(e) {
      message("Could not load ratings: ", e$message)
    })
  }
  # Return empty df if unavailable
  tibble(tool_id = integer(), rating = integer(),
         comment = character(), timestamp = character())
}

# ---- Submit Rating ----------------------------------------
submit_rating <- function(tool_id, rating, comment) {
  if (is.na(SHEET_ID)) {
    message("No sheet configured — rating not saved")
    return(invisible(FALSE))
  }
  tryCatch({
    gs4_auth()
    new_row <- tibble(
      tool_id   = tool_id,
      rating    = rating,
      comment   = comment,
      timestamp = as.character(Sys.time()),
      session_id = paste0("anon_", sample(1e6, 1))
    )
    sheet_append(SHEET_ID, new_row, sheet = RATINGS_SHEET)
    return(invisible(TRUE))
  }, error = function(e) {
    message("Failed to submit rating: ", e$message)
    return(invisible(FALSE))
  })
}

# ---- Submit Tool ------------------------------------------
submit_tool <- function(tool_name, link, description, category) {
  if (is.na(SHEET_ID)) {
    message("No sheet configured — submission not saved")
    return(invisible(FALSE))
  }
  tryCatch({
    gs4_auth()
    new_row <- tibble(
      tool_name    = tool_name,
      link         = link,
      description  = description,
      category     = category,
      submitted_at = as.character(Sys.time()),
      status       = "pending"
    )
    sheet_append(SHEET_ID, new_row, sheet = SUBMISSIONS_SHEET)
    return(invisible(TRUE))
  }, error = function(e) {
    message("Failed to submit tool: ", e$message)
    return(invisible(FALSE))
  })
}

# ---- Get unique filter values -----------------------------
get_domains    <- function(df) sort(unique(na.omit(df$biological_domain)))
get_techniques <- function(df) sort(unique(na.omit(df$ai_technique)))
get_data_types <- function(df) sort(unique(na.omit(df$data_type)))
get_years      <- function(df) sort(unique(na.omit(df$year_released)))

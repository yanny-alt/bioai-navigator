# seed_data.R
# Run this once to push your local CSV to Google Sheets
# Usage: source("scripts/seed_data.R")

library(googlesheets4)
library(readr)

# Authenticate (will open browser)
gs4_auth()

# Create a new Google Sheet
ss <- gs4_create("BioAI Navigator Data",
  sheets = c("tools", "ratings", "submissions"))

# Push tools CSV
tools <- read_csv("data/tools.csv")
write_sheet(tools, ss, sheet = "tools")

# Create empty ratings sheet with correct headers
ratings_template <- tibble(
  tool_id = integer(), rating = integer(),
  comment = character(), timestamp = character(), session_id = character()
)
write_sheet(ratings_template, ss, sheet = "ratings")

# Create empty submissions sheet
submissions_template <- tibble(
  tool_name = character(), link = character(),
  description = character(), category = character(),
  submitted_at = character(), status = character()
)
write_sheet(submissions_template, ss, sheet = "submissions")

cat("Sheet ID:", ss$spreadsheet_id, "\n")
cat("Set this in your .env or Sys.setenv():\n")
cat(paste0('Sys.setenv(BIOAI_SHEET_ID = "', ss$spreadsheet_id, '")\n'))

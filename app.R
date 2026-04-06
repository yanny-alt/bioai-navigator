# ============================================================
# BioAI Navigator — Entry Point
# ============================================================
# Run this file to launch the app: shiny::runApp()
# ============================================================

library(shiny)

# Source all modules and utilities
source("R/utils_data.R")
source("R/utils_search.R")
source("R/utils_semantic.R")
source("R/modules_directory.R")
source("R/modules_description.R")
source("R/modules_compare.R")
source("R/modules_submit.R")
source("R/modules_ratings.R")
source("R/ui.R")
source("R/server.R")

shinyApp(ui = ui, server = server)

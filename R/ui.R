# ============================================================
# ui.R — Main UI Layout
# ============================================================

library(shiny)
library(bslib)
library(bsicons)

ui <- page_navbar(
  title = tags$span(
    bs_icon("compass"), " BioAI Navigator"
  ),
  theme = bs_theme(
    version = 5,
    bootswatch = "flatly",
    primary = "#1a1a2e",
    secondary = "#16213e",
    success = "#0f3460",
    info    = "#533483",
    base_font  = font_google("DM Sans"),
    heading_font = font_google("Space Grotesk"),
    code_font  = font_google("JetBrains Mono"),
    "navbar-bg" = "#1a1a2e"
  ),
  bg = "#1a1a2e",
  inverse = TRUE,
  
  # ---- Tab: Directory ---------------------------------------
  nav_panel(
    title = tags$span(bs_icon("grid-3x3-gap"), " Directory"),
    value = "directory",
    directoryUI("dir")
  ),
  
  # ---- Tab: Tool Profile ------------------------------------
  nav_panel(
    title = tags$span(bs_icon("file-text"), " Description"),
    value = "description",
    descriptionUI("desc")
  ),
  
  # ---- Tab: Compare -----------------------------------------
  nav_panel(
    title = tags$span(bs_icon("arrow-left-right"), " Compare"),
    value = "compare",
    compareUI("cmp")
  ),
  
  # ---- Tab: Submit ------------------------------------------
  nav_panel(
    title = tags$span(bs_icon("plus-circle"), " Submit a Tool"),
    value = "submit",
    submitUI("sub")
  ),
  
  # ---- Tab: About -------------------------------------------
  nav_panel(
    title = tags$span(bs_icon("info-circle"), " About"),
    value = "about",
    fluidRow(
      column(8, offset = 2,
        br(),
        h2("About BioAI Navigator"),
        p("A community-driven directory of AI tools for biological research."),
        p("Built by the HackBio Dev Team."),
        hr(),
        h4("Tech Stack"),
        tags$ul(
          tags$li("R Shiny + bslib"),
          tags$li("Google Sheets API (googlesheets4)"),
          tags$li("Semantic search via sentence-transformers"),
          tags$li("reactable for interactive tables")
        ),
        hr(),
        h4("Contribute"),
        p("Use the ", tags$b("Submit a Tool"), " tab to add new tools to the directory.")
      )
    )
  ),
  
  # ---- Spacer + GitHub link ---------------------------------
  nav_spacer(),
  nav_item(
    tags$a(
      bs_icon("github"), " GitHub",
      href = "https://github.com/YOUR_USERNAME/bioai-navigator",
      target = "_blank",
      class = "nav-link"
    )
  ),
  
  # ---- Custom CSS -------------------------------------------
  includeCSS("www/css/custom.css")
)

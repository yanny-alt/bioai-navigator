# ============================================================
# server.R — Main Server Logic
# ============================================================

library(shiny)

server <- function(input, output, session) {
  
  # ---- Load data once at startup ---------------------------
  tools_data <- reactive({
    load_tools()
  })
  
  ratings_data <- reactiveVal(load_ratings())
  
  embeddings <- reactive({
    load_embeddings()
  })
  
  # ---- Shared selected tool (passed between modules) -------
  selected_tool <- reactiveVal(NULL)
  
  # ---- Wire up modules -------------------------------------
  
  # Directory module — returns selected tool id
  dir_selected <- directoryServer(
    id         = "dir",
    tools      = tools_data,
    embeddings = embeddings
  )
  
  # When user clicks a tool in directory → switch to description tab
  observeEvent(dir_selected(), {
    req(dir_selected())
    selected_tool(dir_selected())
    nav_select("navbar", selected = "description")
  }, ignoreNULL = TRUE)
  
  # Description module
  descriptionServer(
    id           = "desc",
    tools        = tools_data,
    selected_id  = selected_tool,
    ratings_data = ratings_data
  )
  
  # Compare module
  compareServer(
    id    = "cmp",
    tools = tools_data
  )
  
  # Submit module
  submitServer(id = "sub")
  
}

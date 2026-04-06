# ============================================================
# modules_compare.R — Side-by-side Tool Comparison
# ============================================================

library(shiny)
library(bslib)
library(bsicons)

# ---- UI ---------------------------------------------------
compareUI <- function(id) {
  ns <- NS(id)
  
  fluidRow(
    column(3,
      br(),
      div(class = "filter-panel card p-3",
        h5(bs_icon("arrow-left-right"), " Select Tools"),
        hr(),
        selectInput(ns("tool1"), "Tool 1", choices = c("Select..." = "")),
        selectInput(ns("tool2"), "Tool 2", choices = c("Select..." = "")),
        selectInput(ns("tool3"), "Tool 3 (optional)", 
                    choices = c("None" = "", "Select..." = "")),
        actionButton(ns("compare_btn"), "Compare",
                     class = "btn btn-primary w-100")
      )
    ),
    column(9,
      br(),
      h4(bs_icon("table"), " Tool Comparison"),
      uiOutput(ns("comparison_table"))
    )
  )
}

# ---- Server -----------------------------------------------
compareServer <- function(id, tools) {
  moduleServer(id, function(input, output, session) {
    
    # Populate dropdowns
    observe({
      df <- tools()
      req(nrow(df) > 0)
      choices <- setNames(df$id, df$name)
      updateSelectInput(session, "tool1", 
                        choices = c("Select..." = "", choices))
      updateSelectInput(session, "tool2", 
                        choices = c("Select..." = "", choices))
      updateSelectInput(session, "tool3", 
                        choices = c("None" = "", choices))
    })
    
    comparison_data <- eventReactive(input$compare_btn, {
      req(input$tool1, input$tool2)
      df <- tools()
      
      ids <- c(input$tool1, input$tool2)
      if (input$tool3 != "") ids <- c(ids, input$tool3)
      ids <- as.integer(ids)
      
      df[df$id %in% ids, ]
    })
    
    output$comparison_table <- renderUI({
      df <- comparison_data()
      req(nrow(df) >= 2)
      
      # Fields to compare
      fields <- list(
        "Biological Domain"  = "biological_domain",
        "AI Technique"       = "ai_technique",
        "Data Type"          = "data_type",
        "Year Released"      = "year_released",
        "License"            = "license",
        "Description"        = "short_description",
        "Authors"            = "authors",
        "Publication"        = "publication",
        "Tags"               = "tags"
      )
      
      # Header row
      header_cols <- c(
        tags$th("Feature", class = "col-3"),
        lapply(seq_len(nrow(df)), function(i)
          tags$th(df$name[i], class = "text-primary"))
      )
      
      # Data rows
      rows <- lapply(names(fields), function(field_label) {
        col_name <- fields[[field_label]]
        is_even  <- which(names(fields) == field_label) %% 2 == 0
        
        row_class <- if (is_even) "table-light" else ""
        
        cells <- lapply(seq_len(nrow(df)), function(i) {
          val <- if (col_name %in% names(df)) as.character(df[[col_name]][i]) else "—"
          if (is.na(val) || val == "" || val == "NA") val <- "—"
          tags$td(val)
        })
        
        tags$tr(class = row_class,
          tags$td(tags$strong(field_label)),
          cells
        )
      })
      
      # Links row
      link_cells <- lapply(seq_len(nrow(df)), function(i) {
        tags$td(
          if (!is.na(df$link[i]) && df$link[i] != "")
            tags$a(href = df$link[i], target = "_blank",
                   class = "btn btn-sm btn-outline-primary",
                   bs_icon("box-arrow-up-right"), " Visit")
        )
      })
      
      div(class = "table-responsive",
        tags$table(class = "table table-bordered align-middle",
          tags$thead(class = "table-dark",
            do.call(tags$tr, header_cols)
          ),
          tags$tbody(
            rows,
            tags$tr(
              tags$td(tags$strong("Link")),
              link_cells
            )
          )
        )
      )
    })
  })
}

# ============================================================
# modules_directory.R — Directory Tab (search + filter + list)
# ============================================================

library(shiny)
library(bslib)
library(bsicons)
library(reactable)
library(dplyr)

# ---- UI ---------------------------------------------------
directoryUI <- function(id) {
  ns <- NS(id)
  
  fluidRow(
    # ---- Sidebar: filters ----------------------------------
    column(3,
      br(),
      div(class = "filter-panel card p-3",
        h5(bs_icon("funnel"), " Filter Tools"),
        hr(),
        
        # Search bar
        div(class = "mb-3",
          textInput(ns("search"), label = "Search",
                    placeholder = "e.g. protein folding, GNN..."),
          checkboxInput(ns("use_semantic"), 
                        label = "Semantic search",
                        value = FALSE)
        ),
        
        # Domain filter
        selectInput(ns("domain"), "Biological Domain",
                    choices = c("All"), selected = "All"),
        
        # AI Technique filter
        selectInput(ns("technique"), "AI Technique",
                    choices = c("All"), selected = "All"),
        
        # Data type filter
        selectInput(ns("data_type"), "Data Type",
                    choices = c("All"), selected = "All"),
        
        # License
        selectInput(ns("license"), "License",
                    choices = c("All", "Open-source", "Proprietary"),
                    selected = "All"),
        
        # Year range
        div(class = "mb-2",
          sliderInput(ns("year_range"), "Year Released",
                      min = 2015, max = 2026,
                      value = c(2015, 2026),
                      step = 1, sep = "")
        ),
        
        actionButton(ns("reset"), "Reset Filters",
                     class = "btn btn-outline-secondary btn-sm w-100")
      )
    ),
    
    # ---- Main: tool cards ----------------------------------
    column(9,
      br(),
      div(class = "d-flex justify-content-between align-items-center mb-3",
        h4(bs_icon("grid"), " Tool Directory"),
        textOutput(ns("result_count")) |> 
          tagAppendAttributes(class = "text-muted small")
      ),
      
      # Tool list
      uiOutput(ns("tool_list"))
    )
  )
}

# ---- Server -----------------------------------------------
directoryServer <- function(id, tools, embeddings) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns
    
    # Populate filter dropdowns once data loads
    observe({
      df <- tools()
      req(nrow(df) > 0)
      
      updateSelectInput(session, "domain",
        choices = c("All", get_domains(df)))
      updateSelectInput(session, "technique",
        choices = c("All", get_techniques(df)))
      updateSelectInput(session, "data_type",
        choices = c("All", get_data_types(df)))
      
      years <- range(na.omit(df$year_released))
      updateSliderInput(session, "year_range",
        min = years[1], max = years[2],
        value = c(years[1], years[2]))
    })
    
    # Reset filters
    observeEvent(input$reset, {
      updateTextInput(session, "search", value = "")
      updateSelectInput(session, "domain",    selected = "All")
      updateSelectInput(session, "technique", selected = "All")
      updateSelectInput(session, "data_type", selected = "All")
      updateSelectInput(session, "license",   selected = "All")
    })
    
    # Filtered + searched data
    filtered_tools <- reactive({
      df <- tools()
      req(nrow(df) > 0)
      
      search_and_filter(
        df         = df,
        query      = input$search,
        domain     = input$domain,
        technique  = input$technique,
        data_type  = input$data_type,
        license    = input$license,
        year_min   = input$year_range[1],
        year_max   = input$year_range[2],
        use_semantic = input$use_semantic,
        embeddings = embeddings()
      )
    })
    
    # Result count
    output$result_count <- renderText({
      n <- nrow(filtered_tools())
      total <- nrow(tools())
      paste0("Showing ", n, " of ", total, " tools")
    })
    
    # ---- Tool cards ----------------------------------------
    selected_id <- reactiveVal(NULL)
    
    output$tool_list <- renderUI({
      df <- filtered_tools()
      
      if (nrow(df) == 0) {
        return(div(class = "text-center text-muted py-5",
          bs_icon("search"), br(), "No tools match your search."
        ))
      }
      
      cards <- lapply(seq_len(nrow(df)), function(i) {
        row <- df[i, ]
        
        div(class = "tool-card card mb-3 p-3",
          div(class = "d-flex justify-content-between align-items-start",
            
            # Checkbox for comparison
            div(class = "me-3 mt-1",
              checkboxInput(ns(paste0("sel_", row$id)), label = NULL, value = FALSE)
            ),
            
            # Tool info
            div(class = "flex-grow-1",
              div(class = "d-flex justify-content-between",
                h5(class = "mb-1 tool-name",
                  actionLink(ns(paste0("view_", row$id)), 
                             label = row$name,
                             class = "text-decoration-none fw-bold")
                ),
                tags$span(class = "badge bg-primary ms-2",
                          row$biological_domain)
              ),
              p(class = "text-muted mb-1 small", row$short_description),
              div(class = "d-flex gap-2 flex-wrap",
                tags$span(class = "badge bg-light text-dark border",
                          bs_icon("cpu"), " ", row$ai_technique),
                if (!is.na(row$year_released))
                  tags$span(class = "badge bg-light text-dark border",
                            bs_icon("calendar"), " ", row$year_released),
                tags$a(href = row$link, target = "_blank",
                       class = "badge bg-light text-dark border text-decoration-none",
                       bs_icon("box-arrow-up-right"), " Visit")
              )
            )
          )
        )
      })
      
      # Register click observers for "view" links
      lapply(seq_len(nrow(df)), function(i) {
        local({
          tool_id <- df$id[i]
          observeEvent(input[[paste0("view_", tool_id)]], {
            selected_id(tool_id)
          }, ignoreInit = TRUE)
        })
      })
      
      tagList(cards)
    })
    
    # Return selected tool id to parent
    return(selected_id)
  })
}

# ============================================================
# modules_description.R — Tool Profile Page
# ============================================================

library(shiny)
library(bslib)
library(bsicons)

# ---- UI ---------------------------------------------------
descriptionUI <- function(id) {
  ns <- NS(id)
  
  fluidRow(
    column(10, offset = 1,
      br(),
      uiOutput(ns("profile_page")),
      br(),
      ratingsUI(ns("ratings"))
    )
  )
}

# ---- Server -----------------------------------------------
descriptionServer <- function(id, tools, selected_id, ratings_data) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns
    
    current_tool <- reactive({
      req(selected_id())
      df <- tools()
      df[df$id == selected_id(), ]
    })
    
    output$profile_page <- renderUI({
      tool <- current_tool()
      
      if (nrow(tool) == 0) {
        return(div(class = "text-center text-muted py-5",
          bs_icon("arrow-left-circle"), br(), br(),
          p("Select a tool from the Directory to view its profile.")
        ))
      }
      
      div(class = "tool-profile card p-4",
        
        # ---- Header ------------------------------------------
        div(class = "d-flex align-items-start mb-4",
          
          # Logo placeholder
          div(class = "tool-logo me-4",
            if (!is.na(tool$logo) && tool$logo != "") {
              tags$img(src = tool$logo, height = "80px",
                       class = "rounded border")
            } else {
              div(class = "logo-placeholder rounded border d-flex align-items-center 
                           justify-content-center",
                  style = "width:80px;height:80px;background:#f8f9fa;",
                  bs_icon("box", size = "2em"))
            }
          ),
          
          div(class = "flex-grow-1",
            h2(class = "mb-1", tool$name),
            p(class = "text-muted mb-2", tool$short_description),
            if (!is.null(tool$authors) && !is.na(tool$authors))
              p(class = "small text-muted", bs_icon("person"), " ", tool$authors),
            div(class = "d-flex gap-2",
              if (!is.na(tool$link) && tool$link != "")
                tags$a(href = tool$link, target = "_blank",
                       class = "btn btn-sm btn-primary",
                       bs_icon("box-arrow-up-right"), " Website"),
              if (!is.null(tool$publication) && !is.na(tool$publication) && tool$publication != "")
                tags$a(href = "#", class = "btn btn-sm btn-outline-secondary",
                       bs_icon("journal-text"), " Publication")
            )
          )
        ),
        
        hr(),
        
        # ---- Metadata grid -----------------------------------
        fluidRow(
          column(3, div(class = "meta-item",
            strong("Domain"), br(),
            tags$span(class = "badge bg-primary", tool$biological_domain)
          )),
          column(3, div(class = "meta-item",
            strong("AI Technique"), br(),
            tags$span(class = "badge bg-secondary", tool$ai_technique)
          )),
          column(3, div(class = "meta-item",
            strong("Data Type"), br(),
            tags$span(class = "badge bg-info text-dark", tool$data_type)
          )),
          column(3, div(class = "meta-item",
            strong("Year"), br(),
            tags$span(class = "badge bg-light text-dark border",
                      tool$year_released)
          ))
        ),
        
        br(),
        
        # ---- Tags --------------------------------------------
        if (!is.null(tool$tags) && !is.na(tool$tags) && tool$tags != "") {
          div(class = "mb-3",
            strong("Tags"), br(),
            tagList(lapply(
              strsplit(tool$tags, ",")[[1]],
              function(tag) tags$span(class = "badge bg-light text-dark border me-1 mt-1",
                                      trimws(tag))
            ))
          )
        },
        
        hr(),
        
        # ---- Description / Review ----------------------------
        if (!is.null(tool$review) && !is.na(tool$review) && tool$review != "") {
          div(class = "mb-4",
            h5("Curator's Review"),
            p(tool$review)
          )
        },
        
        # ---- Screenshots -------------------------------------
        if ((!is.null(tool$screenshot_1) && !is.na(tool$screenshot_1) && tool$screenshot_1 != "") ||
            (!is.null(tool$screenshot_2) && !is.na(tool$screenshot_2) && tool$screenshot_2 != "")) {
          div(class = "mb-3",
            h5("Screenshots"),
            div(class = "d-flex gap-3",
              if (!is.na(tool$screenshot_1) && tool$screenshot_1 != "")
                tags$img(src = tool$screenshot_1, class = "screenshot rounded border",
                         style = "max-width:45%;"),
              if (!is.na(tool$screenshot_2) && tool$screenshot_2 != "")
                tags$img(src = tool$screenshot_2, class = "screenshot rounded border",
                         style = "max-width:45%;")
            )
          )
        }
      )
    })
    
    # Wire up ratings submodule
    ratingsServer("ratings", tool_id = selected_id, ratings_data = ratings_data)
  })
}

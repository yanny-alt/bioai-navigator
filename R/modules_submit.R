# ============================================================
# modules_submit.R — Submit a Tool Form
# ============================================================

library(shiny)
library(bslib)
library(bsicons)

# ---- UI ---------------------------------------------------
submitUI <- function(id) {
  ns <- NS(id)
  
  fluidRow(
    column(8, offset = 2,
      br(),
      div(class = "card p-4",
        h4(bs_icon("plus-circle"), " Submit a New Tool"),
        p(class = "text-muted",
          "Know an AI biology tool that's not listed? Submit it here.
           Our team reviews all submissions before adding them."),
        hr(),
        
        textInput(ns("tool_name"), "Tool Name *",
                  placeholder = "e.g. AlphaFold3"),
        
        textInput(ns("link"), "Website or GitHub Link *",
                  placeholder = "https://..."),
        
        textAreaInput(ns("description"), "Short Description *",
                      placeholder = "What does this tool do? Who is it for?",
                      rows = 4),
        
        selectInput(ns("category"), "Biological Domain *",
                    choices = c(
                      "Select..." = "",
                      "Genomics", "Proteomics", "Protein Structure",
                      "Protein Design", "Drug Discovery", "Microscopy",
                      "Multi-omics", "Literature Mining", "Epigenomics",
                      "Single-cell", "Antibodies", "Other"
                    )),
        
        textInput(ns("technique"), "AI Technique",
                  placeholder = "e.g. Transformer, GNN, Diffusion"),
        
        textInput(ns("publication"), "Associated Publication",
                  placeholder = "Paper title or DOI (optional)"),
        
        hr(),
        
        actionButton(ns("submit"), "Submit Tool",
                     class = "btn btn-primary"),
        
        br(), br(),
        uiOutput(ns("submit_result"))
      )
    )
  )
}

# ---- Server -----------------------------------------------
submitServer <- function(id) {
  moduleServer(id, function(input, output, session) {
    
    observeEvent(input$submit, {
      # Validation
      errors <- c()
      if (trimws(input$tool_name) == "") errors <- c(errors, "Tool Name is required")
      if (trimws(input$link) == "")      errors <- c(errors, "Link is required")
      if (trimws(input$description) == "") errors <- c(errors, "Description is required")
      if (input$category == "")          errors <- c(errors, "Category is required")
      
      if (length(errors) > 0) {
        output$submit_result <- renderUI({
          div(class = "alert alert-danger",
            bs_icon("exclamation-circle"), " ",
            paste(errors, collapse = "; ")
          )
        })
        return()
      }
      
      success <- submit_tool(
        tool_name   = input$tool_name,
        link        = input$link,
        description = input$description,
        category    = input$category
      )
      
      output$submit_result <- renderUI({
        if (isTRUE(success)) {
          div(class = "alert alert-success",
            bs_icon("check-circle"), " ",
            "Thank you! Your submission is under review."
          )
        } else {
          div(class = "alert alert-warning",
            bs_icon("info-circle"), " ",
            "Submission noted locally. Set up Google Sheets to persist."
          )
        }
      })
      
      # Clear form
      updateTextInput(session, "tool_name",    value = "")
      updateTextInput(session, "link",         value = "")
      updateTextAreaInput(session, "description", value = "")
      updateSelectInput(session, "category",   selected = "")
      updateTextInput(session, "technique",    value = "")
      updateTextInput(session, "publication",  value = "")
    })
  })
}

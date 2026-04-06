# ============================================================
# modules_ratings.R — Ratings & Comments Submodule
# ============================================================

library(shiny)
library(bslib)
library(bsicons)
library(dplyr)

# ---- UI ---------------------------------------------------
ratingsUI <- function(id) {
  ns <- NS(id)
  
  div(class = "ratings-section card p-4 mt-3",
    h5(bs_icon("star"), " Community Ratings & Reviews"),
    hr(),
    
    fluidRow(
      # ---- Average rating display
      column(4,
        div(class = "text-center",
          uiOutput(ns("avg_rating")),
          p(class = "text-muted small", textOutput(ns("rating_count")))
        )
      ),
      
      # ---- Rating distribution
      column(8,
        uiOutput(ns("rating_bars"))
      )
    ),
    
    hr(),
    
    # ---- Existing comments
    uiOutput(ns("comments_list")),
    
    hr(),
    
    # ---- Submit rating form
    h6("Leave a Review"),
    div(class = "rating-form",
      div(class = "d-flex align-items-center gap-3 mb-2",
        selectInput(ns("user_rating"), label = NULL,
                    choices = c("⭐⭐⭐⭐⭐ (5)" = 5,
                                "⭐⭐⭐⭐ (4)"   = 4,
                                "⭐⭐⭐ (3)"     = 3,
                                "⭐⭐ (2)"       = 2,
                                "⭐ (1)"         = 1),
                    width = "200px")
      ),
      textAreaInput(ns("user_comment"), label = NULL,
                    placeholder = "Share your experience with this tool...",
                    rows = 3),
      actionButton(ns("submit_rating"), "Submit Review",
                   class = "btn btn-primary btn-sm"),
      br(), br(),
      textOutput(ns("submit_msg"))
    )
  )
}

# ---- Server -----------------------------------------------
ratingsServer <- function(id, tool_id, ratings_data) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns
    
    # Local copy of ratings for this tool
    tool_ratings <- reactive({
      req(tool_id())
      df <- ratings_data()
      if (nrow(df) == 0) return(df)
      df %>% filter(tool_id == tool_id())
    })
    
    # Average rating display
    output$avg_rating <- renderUI({
      df <- tool_ratings()
      if (nrow(df) == 0) {
        return(div(
          h1("—", class = "display-4 fw-bold"),
          p("No ratings yet", class = "text-muted")
        ))
      }
      avg <- round(mean(df$rating, na.rm = TRUE), 1)
      stars <- strrep("⭐", round(avg))
      div(
        h1(avg, class = "display-4 fw-bold text-warning"),
        p(stars, class = "fs-4")
      )
    })
    
    output$rating_count <- renderText({
      n <- nrow(tool_ratings())
      paste0(n, " rating", if (n != 1) "s")
    })
    
    # Rating distribution bars
    output$rating_bars <- renderUI({
      df <- tool_ratings()
      if (nrow(df) == 0) return(NULL)
      
      tagList(lapply(5:1, function(star) {
        count <- sum(df$rating == star, na.rm = TRUE)
        pct   <- if (nrow(df) > 0) round(count / nrow(df) * 100) else 0
        div(class = "d-flex align-items-center gap-2 mb-1",
          span(strrep("⭐", star), class = "small", style = "width:80px"),
          div(class = "progress flex-grow-1", style = "height:12px;",
            div(class = "progress-bar bg-warning",
                style = paste0("width:", pct, "%"))
          ),
          span(count, class = "small text-muted", style = "width:25px")
        )
      }))
    })
    
    # Comments list
    output$comments_list <- renderUI({
      df <- tool_ratings()
      df <- df %>% filter(!is.na(comment) & comment != "")
      
      if (nrow(df) == 0) {
        return(p(class = "text-muted small", "No reviews yet. Be the first!"))
      }
      
      tagList(lapply(seq_len(min(nrow(df), 10)), function(i) {
        row <- df[i, ]
        div(class = "comment-item border-start ps-3 mb-3",
          div(class = "d-flex justify-content-between",
            span(strrep("⭐", row$rating), class = "small"),
            span(class = "text-muted small", row$timestamp)
          ),
          p(class = "mb-0 small", row$comment)
        )
      }))
    })
    
    # Submit rating
    observeEvent(input$submit_rating, {
      req(tool_id(), input$user_rating)
      
      success <- submit_rating(
        tool_id = tool_id(),
        rating  = as.integer(input$user_rating),
        comment = input$user_comment
      )
      
      # Update local reactive
      new_row <- tibble(
        tool_id   = tool_id(),
        rating    = as.integer(input$user_rating),
        comment   = input$user_comment,
        timestamp = as.character(Sys.time())
      )
      ratings_data(bind_rows(ratings_data(), new_row))
      
      output$submit_msg <- renderText("✅ Thank you for your review!")
      updateTextAreaInput(session, "user_comment", value = "")
    })
  })
}

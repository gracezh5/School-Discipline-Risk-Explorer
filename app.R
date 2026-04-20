#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    https://shiny.posit.co/
#
library(shiny)
library(tidyverse)
library(bslib)

your_data <- read_csv("va_cleaned_data.csv")

model <- glm(high_suspension ~ minority + disability + size + type,
             data = your_data,
             family = binomial)

national_avg_susp <- mean(your_data$susp_rate, na.rm = TRUE)
national_median_susp <- median(your_data$susp_rate, na.rm = TRUE)

ui <- fluidPage(
  theme = bs_theme(bootswatch = "flatly"),
  
  titlePanel(
    div(
      h2("School Discipline Risk Explorer", style = "margin-bottom: 4px;"),
      p("Exploring suspension patterns in Virginia public schools | APMA 3150 | Group Members: Zhang, Grace; Sejas Siles, Madison",
        style = "font-size: 13px; color: #6c757d; margin-top: 0;")
    )
  ),
  
  tabsetPanel(
    # ── TAB 1: Prediction ──────────────────────────────────────────────────────
    tabPanel("Prediction",
             br(),
             sidebarLayout(
               sidebarPanel(
                 h5("Configure a School Profile"),
                 hr(),
                 sliderInput("minority", "% Minority Students:",
                             min = 0, max = 100, value = 50, post = "%"),
                 sliderInput("disability", "% Students with Disabilities:",
                             min = 0, max = 100, value = 10, post = "%"),
                 sliderInput("size", "School Size (# students):",
                             min = 100, max = 3000, value = 1000, step = 50),
                 selectInput("type", "School Type:",
                             choices = c("Elementary", "Middle", "High")),
                 hr(),
                 actionButton("predict_btn", "Update Prediction", class = "btn-primary", width = "100%")
               ),
               mainPanel(
                 fluidRow(
                   column(4,
                          div(class = "card text-center p-3",
                              h6("Probability of High Suspension", style = "color: #6c757d;"),
                              uiOutput("prob_display")
                          )
                   ),
                   column(4,
                          div(class = "card text-center p-3",
                              h6("State Average Rate", style = "color: #6c757d;"),
                              h3(paste0(round(national_avg_susp * 100, 1), "%"),
                                 style = "color: #2c3e50; font-weight: 600;"),
                              p("in-school suspensions / enrollment", style = "font-size: 11px; color: #aaa;")
                          )
                   ),
                   column(4,
                          div(class = "card text-center p-3",
                              h6("Percentile Rank", style = "color: #6c757d;"),
                              uiOutput("percentile_display")
                          )
                   )
                 ),
                 br(),
                 plotOutput("prob_plot", height = "320px"),
                 br(),
                 uiOutput("interpretation_text")
               )
             )
    ),
    
    # ── TAB 2: Explore the Data ────────────────────────────────────────────────
    tabPanel("Explore",
             br(),
             sidebarLayout(
               sidebarPanel(
                 h5("Visualization Controls"),
                 hr(),
                 selectInput("x_var", "X-Axis Variable:",
                             choices = c(
                               "% Minority" = "minority",
                               "% Disability" = "disability",
                               "School Size" = "size"
                             )),
                 selectInput("color_var", "Color By:",
                             choices = c(
                               "School Type" = "type",
                               "High Suspension" = "high_suspension_factor"
                             )),
                 checkboxInput("show_smooth", "Show trend line", value = TRUE),
                 hr(),
                 p("Each point is one Virginia school (2021–22).",
                   style = "font-size: 12px; color: #6c757d;")
               ),
               mainPanel(
                 plotOutput("explore_plot", height = "450px"),
                 br(),
                 uiOutput("explore_summary")
               )
             )
    ),
    
    # ── TAB 3: Hypothesis Test ─────────────────────────────────────────────────
    tabPanel("Hypothesis Testing",
             br(),
             fluidRow(
               column(8, offset = 2,
                      div(class = "card p-4",
                          h5("T-test: Do high-minority schools have higher suspension rates?"),
                          hr(),
                          p("We split schools into two groups based on whether their minority enrollment is above or below 50%,
               then compare mean suspension rates between the groups."),
                          br(),
                          fluidRow(
                            column(6,
                                   div(class = "card bg-light p-3 text-center",
                                       h6("Low Minority Schools (< 50%)", style = "color: #6c757d;"),
                                       uiOutput("low_minority_stats")
                                   )
                            ),
                            column(6,
                                   div(class = "card bg-light p-3 text-center",
                                       h6("High Minority Schools (≥ 50%)", style = "color: #6c757d;"),
                                       uiOutput("high_minority_stats")
                                   )
                            )
                          ),
                          br(),
                          uiOutput("ttest_results"),
                          br(),
                          plotOutput("ci_plot", height = "220px")
                      )
               )
             )
    )
  )
)

server <- function(input, output, session) {
  
  # ── Reactive: run prediction ────────────────────────────────────────────────
  prediction <- eventReactive(input$predict_btn, {
    newdata <- data.frame(
      minority   = input$minority,
      disability = input$disability,
      size       = input$size,
      type       = input$type
    )
    prob <- predict(model, newdata, type = "response")
    
    # Percentile: what fraction of VA schools have LOWER predicted prob
    all_probs <- predict(model, your_data, type = "response")
    pctile <- round(mean(all_probs <= prob) * 100, 0)
    
    list(prob = prob, percentile = pctile)
  }, ignoreNULL = FALSE)
  
  # ── Tab 1 outputs ───────────────────────────────────────────────────────────
  output$prob_display <- renderUI({
    prob <- prediction()$prob
    color <- if (prob > 0.66) "#e74c3c" else if (prob > 0.33) "#f39c12" else "#27ae60"
    tagList(
      h3(paste0(round(prob * 100, 1), "%"),
         style = paste0("color: ", color, "; font-weight: 600;")),
      p("probability of high suspension", style = "font-size: 11px; color: #aaa;")
    )
  })
  
  output$percentile_display <- renderUI({
    pctile <- prediction()$percentile
    color <- if (pctile > 80) "#e74c3c" else if (pctile > 50) "#f39c12" else "#27ae60"
    tagList(
      h3(paste0("Top ", 100 - pctile, "%"),
         style = paste0("color: ", color, "; font-weight: 600;")),
      p("among VA schools", style = "font-size: 11px; color: #aaa;")
    )
  })
  
  output$prob_plot <- renderPlot({
    prob <- prediction()$prob
    
    # Build comparison bar chart
    comparison_df <- data.frame(
      label = c("Your School", "State Average\n(above-median schools)", "State Average\n(all schools)"),
      value = c(prob,
                mean(your_data$susp_rate[your_data$high_suspension == 1], na.rm = TRUE),
                national_avg_susp)
    )
    
    bar_colors <- c(
      if (prob > 0.66) "#e74c3c" else if (prob > 0.33) "#f39c12" else "#27ae60",
      "#95a5a6",
      "#bdc3c7"
    )
    
    ggplot(comparison_df, aes(x = label, y = value * 100, fill = label)) +
      geom_col(width = 0.5, show.legend = FALSE) +
      scale_fill_manual(values = bar_colors) +
      geom_hline(yintercept = national_median_susp * 100,
                 linetype = "dashed", color = "#7f8c8d", linewidth = 0.8) +
      annotate("text", x = 2.5, y = national_median_susp * 100 + 0.3,
               label = "State median", size = 3, color = "#7f8c8d") +
      labs(
        title = "Predicted Suspension Rate vs. Virginia Benchmarks",
        x = NULL, y = "Suspension Rate (%)"
      ) +
      theme_minimal(base_size = 13) +
      theme(
        plot.title = element_text(face = "bold", size = 13),
        axis.text.x = element_text(size = 11),
        panel.grid.major.x = element_blank()
      )
  })
  
  output$interpretation_text <- renderUI({
    prob  <- prediction()$prob
    pctile <- prediction()$percentile
    risk_label <- if (prob > 0.66) "HIGH risk" else if (prob > 0.33) "MODERATE risk" else "LOW risk"
    color      <- if (prob > 0.66) "#e74c3c" else if (prob > 0.33) "#f39c12" else "#27ae60"
    
    div(
      style = paste0("border-left: 4px solid ", color, "; padding: 12px 16px; background: #f8f9fa; color: #212529;"),
      HTML(paste0(
        "<b>Interpretation:</b> Based on the selected school profile, the logistic regression model estimates a <b>",
        round(prob * 100, 1), "%</b> probability of being a <span style='color:", color, "; font-weight:600;'>", risk_label, "</span> ",
        "school for in-school suspensions. This school ranks higher than <b>", pctile, "%</b> of Virginia schools in the model."
      ))
    )
  })
  
  # ── Tab 2 outputs ───────────────────────────────────────────────────────────
  explore_data <- reactive({
    your_data %>%
      mutate(high_suspension_factor = factor(high_suspension,
                                             levels = c(0, 1),
                                             labels = c("Low Suspension", "High Suspension")))
  })
  
  output$explore_plot <- renderPlot({
    df   <- explore_data()
    xvar <- input$x_var
    cvar <- input$color_var
    
    x_labels <- c(minority = "% Minority Students",
                  disability = "% Students with Disabilities",
                  size = "School Size (# students)")
    
    p <- ggplot(df, aes_string(x = xvar, y = "susp_rate * 100", color = cvar)) +
      geom_point(alpha = 0.35, size = 1.5) +
      labs(
        title = paste("Suspension Rate vs.", x_labels[xvar]),
        x = x_labels[xvar],
        y = "Suspension Rate (%)",
        color = NULL
      ) +
      theme_minimal(base_size = 13) +
      theme(
        plot.title = element_text(face = "bold"),
        legend.position = "bottom"
      )
    
    if (input$show_smooth) {
      p <- p + geom_smooth(method = "loess", se = TRUE, linewidth = 1.1,
                           aes_string(group = 1), color = "#2c3e50", alpha = 0.15)
    }
    
    if (cvar == "type") {
      p <- p + scale_color_brewer(palette = "Set2")
    } else {
      p <- p + scale_color_manual(values = c("Low Suspension" = "#27ae60",
                                             "High Suspension" = "#e74c3c"))
    }
    p
  })
  
  output$explore_summary <- renderUI({
    df <- explore_data()
    cor_val <- round(cor(df[[input$x_var]], df$susp_rate, use = "complete.obs"), 3)
    div(
      style = "font-size: 13px; color: #6c757d; text-align: center;",
      paste0("Pearson correlation between ", input$x_var, " and suspension rate: r = ", cor_val)
    )
  })
  
  # ── Tab 3 outputs ───────────────────────────────────────────────────────────
  ttest_result <- reactive({
    low  <- your_data$susp_rate[your_data$minority <  50]
    high <- your_data$susp_rate[your_data$minority >= 50]
    t.test(high, low, conf.level = 0.95)
  })
  
  output$low_minority_stats <- renderUI({
    low <- your_data$susp_rate[your_data$minority < 50]
    tagList(
      h4(paste0(round(mean(low, na.rm = TRUE) * 100, 2), "%"),
         style = "color: #2980b9; font-weight: 600;"),
      p(paste0("n = ", sum(!is.na(low)), " schools"), style = "font-size: 12px; color: #aaa;")
    )
  })
  
  output$high_minority_stats <- renderUI({
    high <- your_data$susp_rate[your_data$minority >= 50]
    tagList(
      h4(paste0(round(mean(high, na.rm = TRUE) * 100, 2), "%"),
         style = "color: #e74c3c; font-weight: 600;"),
      p(paste0("n = ", sum(!is.na(high)), " schools"), style = "font-size: 12px; color: #aaa;")
    )
  })
  
  output$ttest_results <- renderUI({
    tt <- ttest_result()
    p_fmt <- if (tt$p.value < 0.001) "p < 0.001" else paste0("p = ", round(tt$p.value, 4))
    ci <- round(tt$conf.int * 100, 3)
    sig <- tt$p.value < 0.05
    
    div(
      style = paste0("border-left: 4px solid ", if (sig) "#e74c3c" else "#27ae60",
                     "; padding: 12px 16px; background: #f8f9fa; color: #212529;"),
      HTML(paste0(
        "<b>Welch Two-Sample T-test</b><br>",
        "t(", round(tt$parameter, 1), ") = ", round(tt$statistic, 3), ", <b>", p_fmt, "</b><br>",
        "95% CI for difference in means: [", ci[1], "%, ", ci[2], "%]<br><br>",
        if (sig) {
          "<span style='color:#e74c3c;'><b>Result:</b> We reject H₀. High-minority schools have a statistically significantly higher suspension rate (α = 0.05).</span>"
        } else {
          "<span style='color:#27ae60;'><b>Result:</b> We fail to reject H₀. No statistically significant difference detected (α = 0.05).</span>"
        }
      ))
    )
  })
  
  output$ci_plot <- renderPlot({
    tt    <- ttest_result()
    low   <- your_data$susp_rate[your_data$minority <  50]
    high  <- your_data$susp_rate[your_data$minority >= 50]
    
    df_ci <- data.frame(
      group = c("Low Minority\n(< 50%)", "High Minority\n(≥ 50%)"),
      mean  = c(mean(low, na.rm = TRUE), mean(high, na.rm = TRUE)) * 100,
      se    = c(sd(low, na.rm = TRUE) / sqrt(sum(!is.na(low))),
                sd(high, na.rm = TRUE) / sqrt(sum(!is.na(high)))) * 100 * 1.96
    )
    
    ggplot(df_ci, aes(x = group, y = mean, color = group)) +
      geom_point(size = 4, show.legend = FALSE) +
      geom_errorbar(aes(ymin = mean - se, ymax = mean + se),
                    width = 0.12, linewidth = 1.1, show.legend = FALSE) +
      scale_color_manual(values = c("#2980b9", "#e74c3c")) +
      labs(
        title = "Mean Suspension Rate with 95% Confidence Intervals",
        x = NULL, y = "Mean Suspension Rate (%)"
      ) +
      theme_minimal(base_size = 13) +
      theme(plot.title = element_text(face = "bold", size = 12),
            panel.grid.major.x = element_blank())
  })
}

shinyApp(ui = ui, server = server)

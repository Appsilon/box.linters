box::use(
  shiny[...],     # nolint: box_universal_imports_linter
)                 # nolint: box_trailing_commas_linter

ui <- fluidPage(

  titlePanel("Old Faithful Geyser Data"),

  sidebarLayout(
    sidebarPanel(
      sliderInput("bins",
                  "Number of bins:",
                  min = 1,
                  max = 50,
                  value = 30)
    ),

    mainPanel(
      plotOutput("distPlot")
    )
  )
)

server <- function(input, output) {

  output$distPlot <- renderPlot({
    x    <- faithful[, 2]
    bins <- seq(min(x), max(x), length.out = input$bins + 1)

    hist(x, breaks = bins, col = "darkgray", border = "white",
         xlab = "Waiting time to next eruption (in mins)",
         main = "Histogram of waiting times")
  })
}

shinyApp(ui = ui, server = server)

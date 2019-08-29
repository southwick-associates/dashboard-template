# shiny app to visualize results

library(shiny)
library(dplyr)
library(ggplot2)
source("functions.R")

indir <- "../out"
infiles <- list.files(indir)                   # for file selection
permissions <- c("hunt", "fish", "all_sports") # for group selection

if (length(infiles) == 0) {
    stop("You need to first generate results: source('code/run.R')", call. = FALSE)
}

# user interface
ui <- fluidPage(sidebarLayout(
    sidebarPanel(
        selectInput(
            "file", "Choose Results File", 
            infiles, selected = infiles[1]
        ),
        selectInput(
            "group", "Choose Permission Group",  
            permissions, selected = permissions[1]
        )
    ),
    mainPanel(
        splitLayout(
            plotOutput("allPlot"), 
            plotOutput("agePlot"),
            cellWidths = c("35%", "65%")
        ),
        splitLayout(
            plotOutput("resPlot"),
            plotOutput("genderPlot")
        ),
        width = 12
    )
))

# data selection & plotting
server <- function(input, output) {
    dataFile <- reactive({
        file.path(indir, input$file) %>%
            read.csv(stringsAsFactors = FALSE) %>%
            mutate_at(vars(segment, category, metric), "tolower") %>%
            mutate(metric = factor(metric, level = c("participants", "recruits", "churn")))
    })
    dataGroup <- reactive({
        filter(dataFile(), group == input$group)
    })
    output$allPlot <- renderPlot({
        plot_segment(dataGroup(), "all", "Overall")
    })
    output$resPlot <- renderPlot({
        plot_segment(dataGroup(), "residency", "By Residency")
    })
    output$genderPlot <- renderPlot({
        plot_segment(dataGroup(), "gender", "By Gender")
    })
    output$agePlot <- renderPlot({
        plot_segment(dataGroup(), "age", "By Age")
    })
}

shinyApp(ui = ui, server = server)

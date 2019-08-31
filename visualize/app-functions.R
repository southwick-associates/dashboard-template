# functions for visualizing results in a shiny app

library(shiny)
library(dplyr)
library(ggplot2)

# make bar plot: value by year (facetted using metric & category)
# - df: data frame with summary results
# - seg: segment to include in plot (e.g., "gender")
plot_segment <- function(df, seg, plot_title = "") {
    filter(df, segment == seg) %>%
        ggplot(aes(year, value, fill = metric)) +
        geom_col() +
        facet_grid(metric ~ category, scales = "free_y") +
        scale_y_continuous(label = scales::comma) +
        scale_fill_brewer(type = "qual", palette = 7) +
        theme(
            axis.title = element_blank(),
            text = element_text(size = 15),
            legend.position = "none"
        ) +
        ggtitle(plot_title)
}

# run the shiny app
# - indir: folder that holds summary results (in csv files)
# - groups: permission groups to visualize
run_visual <- function(indir = "out", groups = c("hunt", "fish", "all_sports")) {
    
    # setup
    infiles <- list.files(indir)
    infiles <- infiles[grep(".csv", infiles)] # only want csv files
    
    if (length(infiles) == 0) {
        stop(
            "The 'indir' folder must contain csv files.", 
            " Have you generated results?\n", 
            "- Try using: source('code/run.R')", call. = FALSE
        )
    }
    
    # define user interface
    ui <- fluidPage(
        mainPanel(
            splitLayout(
                selectInput("file", "Choose Results File", infiles),
                selectInput("group", "Choose Permission Group", groups),
                # prevent clipping: https://github.com/rstudio/shiny/issues/1531
                tags$head(tags$style(HTML(".shiny-split-layout > div {overflow: visible;}")))
            ),
            splitLayout(
                plotOutput("allPlot"), plotOutput("agePlot"), 
                cellWidths = c("35%", "65%")
            ),
            splitLayout(
                plotOutput("resPlot"), plotOutput("genderPlot")
            ),
            width = 12
        )
    )
    
    # define data selection & plotting
    server <- function(input, output) {
        dataFile <- reactive({
            x <- read.csv(
                file.path(indir, input$file), stringsAsFactors = FALSE
            )
            if (!"segment" %in% names(x)) {
                stop("The '", input$file,  "' file doesn't have a segment column.",
                     call. = FALSE)
            }
            x %>%
                mutate_at(vars(segment, category, metric), "tolower") %>%
                mutate(metric = factor(metric, levels = c("participants", "recruits", "churn")))
        })
        dataGroup <- reactive({
            x <- filter(dataFile(), group == input$group)
            if (nrow(x) == 0) {
                stop("The '", input$file, "' file doesn't have any rows for the '",
                     input$group, "' group.", call. = FALSE)
            }
            x
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
    shinyApp(ui, server)
}

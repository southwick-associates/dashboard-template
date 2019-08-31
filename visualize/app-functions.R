# functions for visualizing results in a shiny app

library(shiny)
library(dplyr)
library(ggplot2)

# Plotting Functions ------------------------------------------------------

# make a bar plot: measure by year (facetted using metric & category)
# - df: data frame with summary results
# - measure: variable to be plotted on the y axis
plot_bar <- function(df, plot_title = "", measure = "value") {
    df %>%
        ggplot(aes_string("year", measure, fill = "metric")) +
        geom_col() +
        facet_grid(metric ~ category, scales = "free_y") +
        scale_fill_brewer(type = "qual", palette = 7) +
        theme(
            axis.title = element_blank(),
            text = element_text(size = 15),
            legend.position = "none"
        ) +
        ggtitle(plot_title)
}

# plot value by year for a given segment
# - seg: segment to include in plot (e.g., "gender")
plot_value <- function(df, seg, plot_title = "", measure = "value") {
    filter(df, segment == seg) %>%
        plot_bar(plot_title, measure) +
        scale_y_continuous(label = scales::comma)
}

# plot % change by year for a given segment
plot_pct <- function(df, seg, plot_title = "", measure = "pct_change") {
    x <- filter(df, segment == seg) %>%
        group_by(group, metric, category) %>%
        arrange(year) %>%
        mutate(pct_change = (value - lag(value)) / lag(value)) %>%
        ungroup() %>%
        filter(!is.na(pct_change))
    x %>%
        plot_bar(plot_title, measure) +
        scale_y_continuous(labels = scales::percent) +
        geom_hline(yintercept = 0, color = "gray47")
}

# wrapper function: run either "value" or "pct_change"
plot_segment <- function(df, seg, plot_title = "", measure) {
    if (measure == "value") {
        plot_value(df, seg, plot_title)
    } else {
        plot_pct(df, seg, plot_title)
    }
}

# Shiny App Function ------------------------------------------------------

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
    ui <- fluidPage(mainPanel(
        splitLayout(
            selectInput("file", "Choose Results File", infiles),
            selectInput("group", "Choose Permission Group", groups),
            selectInput("measure", "Choose Measure", c("value", "pct_change")),
            
            # prevent clipping: https://github.com/rstudio/shiny/issues/1531
            tags$head(tags$style(HTML(
                ".shiny-split-layout > div {overflow: visible;}"
            )))
        ),
        splitLayout(
            plotOutput("allPlot"), plotOutput("agePlot"), 
            cellWidths = c("35%", "65%")
        ),
        splitLayout(
            plotOutput("resPlot"), plotOutput("genderPlot")
        ),
        width = 12
    ))
    
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
                mutate(metric = factor(
                    metric, levels = c("participants", "recruits", "churn")
                ))
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
            plot_segment(dataGroup(), "all", "Overall", input$measure)
        })
        output$resPlot <- renderPlot({
            plot_segment(dataGroup(), "residency", "By Residency", input$measure)
        })
        output$genderPlot <- renderPlot({
            plot_segment(dataGroup(), "gender", "By Gender", input$measure)
        })
        output$agePlot <- renderPlot({
            plot_segment(dataGroup(), "age", "By Age", input$measure)
        })
    }
    shinyApp(ui, server)
}

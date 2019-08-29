
# bar plot: value per year for a given segment
# (facetted by metric & category)
plot_segment <- function(tbl, seg, caption = "") {
    filter(tbl, segment == seg) %>%
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
        ggtitle(caption)
}

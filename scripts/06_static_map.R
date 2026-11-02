# Export the static watershed map as a downloadable high-resolution PNG.
# Output goes to downloads/ (committed; copied into the book via project resources).

library(here)
source(here("scripts", "helpers.R"))

watershed <- read_layer(paths$watershed)
streams <- read_layer(paths$streams)

dir.create(here("downloads"), showWarnings = FALSE)
ggplot2::ggsave(
  here("downloads", "buritaca-watershed-map.png"),
  plot_watershed_map(
    watershed, streams,
    title = "Río Buritaca / Río Buritaca watershed",
    subtitle = "Sierra Nevada de Santa Marta, Colombia"
  ),
  width = 6.5, height = 5, dpi = 300
)

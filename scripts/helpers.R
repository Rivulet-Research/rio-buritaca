# Shared helpers used by the book chapters (both languages read the same objects).

library(here)
source(here("scripts", "00_config.R"))

outputs_ready <- function(...) {
  files <- c(...)
  length(files) > 0 && all(file.exists(files))
}

read_layer <- function(path) {
  sf::st_read(path, quiet = TRUE) |> sf::st_transform(4326)
}

read_stats <- function() {
  if (!file.exists(paths$basin_stats)) {
    return(NULL)
  }
  read.csv(paths$basin_stats)
}

# Static map. Title/subtitle are passed in so each language can supply its own.
plot_watershed_map <- function(watershed, streams, title = NULL, subtitle = NULL) {
  library(ggplot2)
  ggplot() +
    geom_sf(data = watershed, fill = "lightblue", alpha = 0.4, color = "darkblue", linewidth = 0.8) +
    geom_sf(data = streams, color = "blue", linewidth = 0.4) +
    ggspatial::annotation_scale(location = "bl", width_hint = 0.2) +
    ggspatial::annotation_north_arrow(
      location = "tl", which_north = "true",
      style = ggspatial::north_arrow_fancy_orienteering
    ) +
    theme_minimal() +
    labs(title = title, subtitle = subtitle)
}

fmt <- function(x, digits = 1) {
  formatC(x, format = "f", digits = digits, big.mark = ",")
}

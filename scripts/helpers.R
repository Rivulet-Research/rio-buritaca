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

# Static map over Esri World Imagery. Tiles are cached in data/tiles so
# rendering works offline after the first run.
plot_watershed_map <- function(watershed, streams, title = NULL, subtitle = NULL) {
  library(ggplot2)
  rosm::register_tile_source(
    esriimagery = "https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/${z}/${y}/${x}.jpg"
  )
  ggplot() +
    ggspatial::annotation_map_tile(
      type = "esriimagery", zoomin = 0, cachedir = file.path(paths$data, "tiles")
    ) +
    geom_sf(data = watershed, fill = "yellow", alpha = 0.3, color = NA) +
    geom_sf(data = watershed, fill = NA, color = "yellow", linewidth = 0.8) +
    geom_sf(data = streams, color = "cyan", linewidth = 0.4) +
    geom_sf(data = town_point("Buritaca", cfg$town_buritaca), shape = 21, fill = "white", color = "black", size = 2.5) +
    geom_sf_label(
      data = town_point("Buritaca", cfg$town_buritaca), aes(label = name),
      hjust = 1.15, size = 3, fontface = "bold", linewidth = 0, fill = "white"
    ) +
    ggspatial::annotation_scale(location = "bl", width_hint = 0.2, text_col = "white", bar_cols = c("black", "white"), line_col = "white") +
    ggspatial::annotation_north_arrow(
      location = "tl", which_north = "true",
      style = ggspatial::north_arrow_fancy_orienteering
    ) +
    theme_minimal() +
    labs(title = title, subtitle = subtitle, x = NULL, y = NULL) +
    patchwork::inset_element(
      plot_inset_map(watershed),
      left = 0.60, bottom = 0.03, right = 0.99, top = 0.42, align_to = "panel"
    )
}

# One-row sf point from a named lon/lat vector.
town_point <- function(name, lonlat) {
  sf::st_as_sf(
    data.frame(name = name, lon = lonlat[["lon"]], lat = lonlat[["lat"]]),
    coords = c("lon", "lat"), crs = 4326
  )
}

# Regional locator map: basin outline plus Santa Marta on OSM tiles.
plot_inset_map <- function(watershed) {
  library(ggplot2)
  region <- sf::st_as_sfc(sf::st_bbox(
    c(xmin = -74.6, xmax = -73.4, ymin = 10.8, ymax = 11.5), crs = 4326
  ))
  santa_marta <- sf::st_as_sf(
    data.frame(name = "Santa Marta", lon = cfg$city_santa_marta[["lon"]], lat = cfg$city_santa_marta[["lat"]]),
    coords = c("lon", "lat"), crs = 4326
  )
  ggplot() +
    # Invisible layer that fixes the extent without coord_sf limits (which break tiles)
    geom_sf(data = region, fill = NA, color = NA) +
    ggspatial::annotation_map_tile(
      type = "osm", zoomin = -1, cachedir = file.path(paths$data, "tiles")
    ) +
    geom_sf(data = watershed, fill = "yellow", alpha = 0.5, color = "yellow", linewidth = 0.4) +
    geom_sf(data = santa_marta, shape = 21, fill = "white", color = "black", size = 2) +
    geom_sf_label(
      data = santa_marta, aes(label = name), nudge_y = 0.08, size = 2.2, fontface = "bold", linewidth = 0, fill = "white"
    ) +
    theme_void() +
    theme(panel.border = element_rect(color = "black", fill = NA, linewidth = 0.8))
}

fmt <- function(x, digits = 1) {
  formatC(x, format = "f", digits = digits, big.mark = ",")
}

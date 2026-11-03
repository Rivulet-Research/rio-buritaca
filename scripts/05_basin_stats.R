# Step 5: basin statistics and hypsometric curve.
# Outputs: data/basin_stats.csv, data/hypsometry.csv
# TODO: Strahler stream order (wbt_strahler_stream_order) and main-channel profile.

library(here)
source(here("scripts", "00_config.R"))
library(terra)
library(sf)

stopifnot(file.exists(paths$watershed), file.exists(paths$streams), file.exists(paths$dem))

watershed <- st_read(paths$watershed, quiet = TRUE)
streams <- st_read(paths$streams, quiet = TRUE)
dem <- rast(paths$dem)

basin <- vect(watershed)
dem_basin <- mask(crop(dem, basin), basin)
slope_deg <- terrain(dem_basin, v = "slope", unit = "degrees")

area_km2 <- as.numeric(st_area(watershed)) / 1e6
stream_km <- sum(as.numeric(st_length(streams))) / 1e3
elev <- values(dem_basin, na.rm = TRUE)[, 1]

stats <- data.frame(
  dem_source = cfg$dem_source,
  area_km2 = area_km2,
  perimeter_km = as.numeric(st_length(st_cast(st_boundary(watershed), "MULTILINESTRING"))) / 1e3,
  elev_min_m = min(elev),
  elev_mean_m = mean(elev),
  elev_max_m = max(elev),
  slope_mean_deg = global(slope_deg, "mean", na.rm = TRUE)[[1]],
  stream_length_km = stream_km,
  drainage_density_km_per_km2 = stream_km / area_km2,
  stream_length_mi = stream_km / 1.609344,
  stream_threshold_km2 = cfg$stream_threshold_km2,
  stream_threshold_cells = round(cfg$stream_threshold_km2 * 1e6 / res(dem)[1]^2),
  dem_cell_size_m = res(dem)[1],
  snap_dist_m = cfg$snap_dist_m
)
write.csv(stats, paths$basin_stats, row.names = FALSE)

# Hypsometric curve: relative area above each elevation
hyps <- data.frame(elevation_m = sort(elev, decreasing = FALSE)) |>
  transform(area_above_frac = rev(seq_along(elevation_m)) / length(elevation_m))
hyps <- hyps[seq(1, nrow(hyps), length.out = min(500, nrow(hyps))), ]
write.csv(hyps, paths$hypsometry, row.names = FALSE)

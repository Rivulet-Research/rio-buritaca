# Step 2: hydrologic conditioning, D8 flow direction and accumulation, stream extraction.
# Requires WhiteboxTools: whitebox::install_whitebox()

library(here)
source(here("scripts", "00_config.R"))
library(terra)
library(whitebox)

stopifnot(file.exists(paths$dem))

cell_size_m <- res(rast(paths$dem))[1]
threshold_cells <- round(cfg$stream_threshold_km2 * 1e6 / cell_size_m^2)
message("Stream threshold: ", threshold_cells, " cells (", cfg$stream_threshold_km2, " km2)")

wbt_breach_depressions_least_cost(
  dem = paths$dem, output = paths$dem_breached, dist = 100, fill = TRUE
)
wbt_d8_pointer(dem = paths$dem_breached, output = paths$d8_pntr)
wbt_d8_flow_accumulation(
  input = paths$d8_pntr, output = paths$d8_accum, out_type = "cells", pntr = TRUE
)
wbt_extract_streams(
  flow_accum = paths$d8_accum, output = paths$streams_raster, threshold = threshold_cells
)

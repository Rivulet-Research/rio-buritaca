# Step 4: convert watershed and stream rasters to clean vector layers.

library(here)
source(here("scripts", "00_config.R"))
library(terra)
library(sf)
library(whitebox)

stopifnot(file.exists(paths$watershed_raster), file.exists(paths$streams_raster))

# Watershed: keep only cells inside the basin, dissolve to one valid polygon
ws_rast <- rast(paths$watershed_raster)
ws_rast[ws_rast <= 0] <- NA
watershed <- as.polygons(ws_rast, dissolve = TRUE) |>
  st_as_sf() |>
  st_union() |>
  st_make_valid() |>
  st_sf(geometry = _)
st_crs(watershed) <- cfg$crs_proj
st_write(watershed, paths$watershed, delete_dsn = TRUE, quiet = TRUE)

# Streams: trace lines along the D8 pointer instead of cell edges
wbt_strahler_stream_order(
  d8_pntr = paths$d8_pntr, streams = paths$streams_raster, output = paths$strahler_raster
)
wbt_raster_streams_to_vector(
  streams = paths$strahler_raster, d8_pntr = paths$d8_pntr, output = paths$streams_vector
)
streams <- st_read(paths$streams_vector, quiet = TRUE)
st_crs(streams) <- cfg$crs_proj
# Strahler order is carried in the STRM_VAL attribute
streams$order <- as.integer(streams$STRM_VAL)
streams <- st_intersection(streams, watershed)
st_write(streams, paths$streams, delete_dsn = TRUE, quiet = TRUE)

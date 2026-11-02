# Central configuration for the Rio Buritaca pipeline.
# Every script and chapter sources this file; change parameters here only.

library(here)

cfg <- list(
  # Projected CRS (UTM zone 18N) used for all hydrologic processing
  crs_proj = "EPSG:32618",

  # DEM extent in lon/lat (xmin, xmax, ymin, ymax). Check that it fully
  # contains the basin; widen it if the watershed touches the edge.
  bbox = c(xmin = -74.1, xmax = -73.6, ymin = 10.9, ymax = 11.3),

  # "copernicus" (GLO-30, primary) or "elevatr" (cross-check)
  dem_source = "copernicus",
  elevatr_zoom = 12,

  # Set DEM cells at or below 0 m to NoData (sea) before hydrologic conditioning
  mask_sea = TRUE,

  # River mouth (pour point), taken from Google Maps
  pour_point = c(lon = -73.76813897233389, lat = 11.263051003083701),

  # Snap distance in map units (metres, UTM). Verify visually.
  snap_dist_m = 500,

  # Minimum upstream area that defines a stream cell (km2). Placeholder:
  # tune in the sensitivity analysis.
  stream_threshold_km2 = 1
)

paths <- list(
  data = here("data"),
  dem = here("data", paste0("dem_", cfg$dem_source, ".tif")),
  dem_breached = here("data", "dem_breached.tif"),
  d8_pntr = here("data", "d8_pointer.tif"),
  d8_accum = here("data", "d8_accum.tif"),
  streams_raster = here("data", "streams_raster.tif"),
  streams_vector = here("data", "streams_raw.shp"),
  pour_point = here("data", "pour_point.shp"),
  pour_point_snapped = here("data", "pour_point_snapped.shp"),
  watershed_raster = here("data", "watershed.tif"),
  watershed = here("data", "buritaca_watershed.gpkg"),
  streams = here("data", "buritaca_streams.gpkg"),
  basin_stats = here("data", "basin_stats.csv"),
  hypsometry = here("data", "hypsometry.csv")
)

dir.create(paths$data, showWarnings = FALSE, recursive = TRUE)

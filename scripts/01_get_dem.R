# Step 1: download the DEM, mosaic, crop, and reproject to the projected CRS.
# Output: data/dem_<source>.tif (path in paths$dem)

library(here)
source(here("scripts", "00_config.R"))
library(terra)
library(sf)

bbox_ll <- ext(cfg$bbox["xmin"], cfg$bbox["xmax"], cfg$bbox["ymin"], cfg$bbox["ymax"])

get_copernicus_dem <- function(bbox_ll) {
  # Public Copernicus GLO-30 tiles on AWS, named by the SW corner of each 1x1 degree tile
  lons <- seq(floor(bbox_ll$xmin), floor(bbox_ll$xmax))
  lats <- seq(floor(bbox_ll$ymin), floor(bbox_ll$ymax))
  tiles <- expand.grid(lon = lons, lat = lats)

  tile_url <- function(lon, lat) {
    id <- sprintf(
      "Copernicus_DSM_COG_10_%s%02d_00_%s%03d_00_DEM",
      ifelse(lat >= 0, "N", "S"), abs(lat),
      ifelse(lon >= 0, "E", "W"), abs(lon)
    )
    sprintf("/vsicurl/https://copernicus-dem-30m.s3.amazonaws.com/%s/%s.tif", id, id)
  }

  rasters <- Map(function(lon, lat) {
    tryCatch(rast(tile_url(lon, lat)), error = function(e) NULL)
  }, tiles$lon, tiles$lat)
  rasters <- Filter(Negate(is.null), rasters)
  if (length(rasters) == 0) stop("No Copernicus tiles could be read.")

  crop(do.call(mosaic, unname(rasters)), bbox_ll)
}

get_elevatr_dem <- function(bbox_ll) {
  library(elevatr)
  bbox_sf <- st_as_sfc(st_bbox(c(
    xmin = bbox_ll$xmin, xmax = bbox_ll$xmax,
    ymin = bbox_ll$ymin, ymax = bbox_ll$ymax
  ), crs = st_crs(4326)))
  rast(get_elev_raster(st_sf(geometry = bbox_sf), z = cfg$elevatr_zoom, clip = "bbox"))
}

dem_ll <- switch(
  cfg$dem_source,
  copernicus = get_copernicus_dem(bbox_ll),
  elevatr = get_elevatr_dem(bbox_ll),
  stop("Unknown dem_source: ", cfg$dem_source)
)

dem_proj <- project(dem_ll, cfg$crs_proj, method = "bilinear")

# Copernicus sets the sea to 0 m; treat it as NoData so flow stops at the coast
if (cfg$mask_sea) dem_proj[dem_proj <= 0] <- NA

writeRaster(dem_proj, paths$dem, overwrite = TRUE)
message("Wrote ", paths$dem)

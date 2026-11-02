# Step 3: snap the pour point to the stream network and delineate the watershed.

library(here)
source(here("scripts", "00_config.R"))
library(sf)
library(whitebox)

stopifnot(file.exists(paths$d8_accum), file.exists(paths$d8_pntr))

pour_point <- st_as_sf(
  data.frame(lon = cfg$pour_point["lon"], lat = cfg$pour_point["lat"]),
  coords = c("lon", "lat"), crs = 4326
) |>
  st_transform(cfg$crs_proj)
st_write(pour_point, paths$pour_point, append = FALSE, quiet = TRUE)

wbt_snap_pour_points(
  pour_pts = paths$pour_point, flow_accum = paths$d8_accum,
  output = paths$pour_point_snapped, snap_dist = cfg$snap_dist_m
)

# Report how far the point moved; large shifts mean the snap needs review
snapped <- st_read(paths$pour_point_snapped, quiet = TRUE)
message("Snap displacement: ", round(as.numeric(st_distance(pour_point, snapped))), " m")

wbt_watershed(
  d8_pntr = paths$d8_pntr, pour_pts = paths$pour_point_snapped,
  output = paths$watershed_raster
)

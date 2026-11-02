# Run the full processing pipeline from the project root, in order.
# Requires: whitebox::install_whitebox(); packages terra, sf, here, and elevatr (only if dem_source = "elevatr").

library(here)
for (s in c("01_get_dem.R", "02_condition_flow.R", "03_delineate.R", "04_vectorize.R", "05_basin_stats.R")) {
  message("--- ", s)
  source(here("scripts", s))
}

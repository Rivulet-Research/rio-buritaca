# Rio Buritaca project memory

## Project
Bilingual (English/Spanish) Quarto book, a single-basin descriptive atlas of the Río Buritaca watershed (Sierra Nevada de Santa Marta, Colombia). Output: HTML (GitHub Pages) and DOCX. No PDF. Repo: https://github.com/Rivulet-Research/rio-buritaca

## Key files
- `other/agent_context.qmd`: the user's instructions and feedback to the assistant. Read it for decisions; never modify it.
- `other/documents/buritaca-project-plan.md`: project plan (v3). Update it when decisions change.
- `_quarto.yml`: book config (HTML + DOCX, `downloads: [docx]`, output in git-ignored `_book/`).
- Chapters: `index.qmd`, `01-study-area.qmd` to `07-discussion.qmd`, `references.qmd`, `references.bib`.
- `scripts/`: `00_config.R` (all parameters), `01_get_dem.R` to `06_static_map.R`, `helpers.R` (map functions `plot_watershed_map`, `plot_inset_map`, `town_point`), `run_all.R`.
- `downloads/buritaca-watershed-map.png`: 300 dpi static map made by `06_static_map.R`; committed, and copied into the book through `resources: downloads/` in `_quarto.yml`.
- `buritaca_watershed_project.zip`: original draft project; kept for reference only.

## Conventions
- Each chapter has a bilingual title and a `panel-tabset` with `## English` and `## Español {lang="es"}` tabs (tabsets become sequential sections in DOCX). Figures and tables sit outside the tabsets with bilingual captions ("English / Español").
- Both languages must get numbers from inline R code reading `data/`, never typed by hand.
- The Spanish text is drafted by the assistant and reviewed by the user.
- Leaflet maps go in `.content-visible when-format="html"` blocks; DOCX uses the static ggplot map.
- Do not use backticks inside inline R strings (they break parsing).
- Use the base pipe `|>`. Computation lives in `scripts/`; chapters only read `data/`. Parameters live only in `scripts/00_config.R`.
- `data/`, `_book/` and `.quarto/` are git-ignored; `_freeze/` is committed.
- `freeze: auto` does not notice changes to `data/` or `scripts/`. After re-running the pipeline or editing helpers, delete `_freeze/` before `quarto render`, or chapters show stale output.
- Edits to `scripts/helpers.R` with multi-line `old_string` fail (likely CRLF line endings); use single-line edits there.

## Decisions
- DEM: Copernicus GLO-30 (30 m) primary, `elevatr` as a cross-check; sea cells (<= 0 m) masked to NoData (`mask_sea`).
- Pour point (Google Maps river mouth): lat 11.263051, lon -73.768139. Snap distance 500 m; stream threshold 1 km² (both are placeholders to tune).
- Maps (chapter 03):
  - Static map: Esri World Imagery tiles (registered with `rosm::register_tile_source`, URL ends in `.jpg`, cached in `data/tiles`). Watershed in light yellow (fill alpha 0.3) with yellow outline, cyan streams, Buritaca town point and label, scale bar, north arrow, and a lower-right OSM inset showing the basin and Santa Marta. The inset extent is fixed with an invisible bbox layer, not `coord_sf` limits.
  - Leaflet map: base-layer toggle between Esri.WorldTopoMap (default) and Esri.WorldImagery, plus a Buritaca marker.
  - Town positions are in `cfg$town_buritaca` (OSM village node, lon -73.77065, lat 11.2492, about 1.5 km south of the river mouth; other gazetteers put it near the mouth) and `cfg$city_santa_marta`. The user has not yet confirmed the Buritaca position.
- Publishing: commit source to `main`, then run `quarto publish gh-pages` in the terminal.

## Status (2026-11-02)
- Pipeline (`source("scripts/run_all.R")`) ran successfully. Basin area is about 299.8 km² (a Banco de la República table gives 305 km²); the snapped pour point is on the main channel about 259 m south of the Google Maps mouth, where the DEM has NoData water cells.
- Packages installed: whitebox (with binary), elevatr, ggspatial, prettymapr.
- ggplot `annotation_map_tile` basemaps do not draw when zoomed with `coord_sf` limits; use leaflet for close-up checks.
- Not yet done: sensitivity analysis (DEM source, threshold, snap distance), Strahler order and main channel profile, validation against reference datasets (HydroSHEDS, MERIT Hydro, IDEAM), study area and discussion text, Spanish review, first `quarto publish gh-pages`.
- Also pending: tile attribution (Esri, OpenStreetMap) in map captions in both languages; the preface still says the analysis has not been run; DOCX not re-checked since the imagery and inset changes; leaflet streams may need a lighter colour on imagery; commit everything (nothing has been committed or pushed yet); update the project plan for changes since v3 (sea mask, maps).

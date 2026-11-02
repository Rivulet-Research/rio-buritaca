# rio-buritaca

Bilingual (English/Spanish) Quarto book describing the Río Buritaca watershed, Sierra Nevada de Santa Marta, Colombia. See `other/documents/buritaca-project-plan.md` for the project plan.

## Run order

1. Install dependencies: `sf`, `terra`, `here`, `ggplot2`, `ggspatial`, `leaflet`, `whitebox` (then `whitebox::install_whitebox()`), and `elevatr` (only for the DEM cross-check).
2. Set parameters in `scripts/00_config.R`.
3. Run `source("scripts/run_all.R")` from the project root. This writes the git-ignored `data/` folder.
4. Render the book: `quarto render` (HTML and DOCX), or `quarto preview`.

The book renders without `data/`, but maps and statistics show a placeholder until the pipeline has run.

## Publishing

From the terminal: `quarto publish gh-pages`.

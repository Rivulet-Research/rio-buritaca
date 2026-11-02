# Río Buritaca Watershed: Project Plan and Quarto Book Outline

Status: draft v3, 2026-11-02. Updated with the answers in `other/agent_context.qmd` and the follow-up decision to use a single bilingual document with HTML and DOCX output (no PDF). Based on review of `buritaca_watershed_project.zip` (a Quarto project with `_quarto.yml`, `buritaca-map.qmd`, `scripts/delineate_buritaca.R`). The code has not yet been run.

## 1. Goals and scope

1.  Delineate the Río Buritaca watershed (Sierra Nevada de Santa Marta, Colombia) reproducibly from open DEM data.
2.  Derive the stream network and basic basin statistics.
3.  Publish the results as a **single-basin descriptive atlas** in one **bilingual (English and Spanish) Quarto book**, as a GitHub Pages website and as a downloadable **DOCX**.

Out of scope for now: land cover, climate, communities, and other extensions. These are listed only as possible future chapters. PDF output is not needed.

## 2. Decisions so far

| Question | Decision |
|----|----|
| Scope | Single-basin descriptive atlas; other details later |
| DEM source | Undecided by user. Recommendation in 2.1 |
| Publishing | Commit source to GitHub; publish the rendered book to GitHub Pages from the terminal with `quarto publish gh-pages` |
| Language | One bilingual document (English and Spanish in the same book) |
| Output formats | HTML (website) and DOCX. No PDF |
| Validation reference | None known. Candidate references in 2.2 |

### 2.1 DEM recommendation

| Option | Resolution | Pros | Cons |
|----|----|----|----|
| Copernicus GLO-30 | 30 m | Generally the best open global DEM at this scale; no account needed when read from the public AWS tiles | Needs tile download and mosaic code (not via `elevatr`) |
| `elevatr` terrain tiles (z 12) | about 38 m at this latitude | One function call; already used in the draft script | Composite of several sources; quality varies by area |
| SRTM 30 m | 30 m | Well known | Older, noisier in steep and vegetated terrain |

Proposal: use Copernicus GLO-30 as the primary DEM and the `elevatr` DEM as a cross-check in the sensitivity chapter. The original script's z 11 (about 75 m) is likely too coarse for steep Sierra Nevada terrain, so at minimum raise it to z 12. The final choice should be confirmed after seeing how the two DEMs compare.

### 2.2 Validation references (unverified; to be checked in Phase 2)

No reference value is known, so validation will compare against independent datasets rather than one number:

-   HydroSHEDS / HydroBASINS and MERIT Hydro basin outlines and drainage networks.
-   Colombian national hydrographic zonation from IDEAM (basin and sub-basin boundaries), if a Buritaca unit is available.
-   OpenStreetMap or national hydrography lines for the mapped river course.
-   Consistency checks: the basin should drain to the river mouth near the Caribbean coast, and its area should be stable across DEM sources and snap distances.

Any published area value we find will be recorded with its source in the methods chapter.

## 3. Known issues to fix (from initial review)

| \# | Issue | Fix |
|----|----|----|
| 1 | `.qmd` and script use `%>%` without loading a pipe provider | Use the base pipe `\|>` |
| 2 | `.qmd` depends on `data/*.gpkg` that don't exist until the script runs | Document run order; add a data-exists check that fails with a clear message |
| 3 | Relative `data/` paths depend on the working directory | Use `here::here()` or a project-root check; create output dirs |
| 4 | Pour point snap distance (150 m) is small and the point is approximate | Verify snapped point against the river mouth; try larger snap distances |
| 5 | Stream threshold of 1000 cells is arbitrary (about 5 km² at z11) | Tune and justify; compare against reference hydrography |
| 6 | `as.polygons()` returns every raster value, including the background | Filter to the watershed value, dissolve, and validate geometry |
| 7 | `as.lines()` on a raster traces cell edges, not stream lines | Use `wbt_raster_streams_to_vector()` with the D8 pointer |
| 8 | DEM resolution is coarse and the download needs internet | Use Copernicus GLO-30 (see 2.1); cache the DEM locally |
| 9 | Generated data may be committed accidentally | Git-ignore `data/` and the render output (see 4) |
| 10 | Zip root layout will mix with the existing repo root files | Unzip deliberately; keep the existing `.Rproj` and README |
| 11 | The leaflet map cannot appear in DOCX | Show it only in HTML; use the static map in DOCX (see 5.2) |
| 12 | Bilingual content was not considered in the draft | Use the single-document layout in section 5 |

## 4. Publishing workflow

### 4.1 GitHub Pages

The command is `quarto publish gh-pages`, run from the project root in the terminal. It renders the project locally, pushes the output to a `gh-pages` branch, and GitHub serves that branch.

One-time setup:

1.  Commit all source files to `main` and push to GitHub.
2.  Run `quarto publish gh-pages` once. It creates the `gh-pages` branch.
3.  In the GitHub repo settings, set Pages to deploy from the `gh-pages` branch.

Each update: commit and push source changes to `main`, then run `quarto publish gh-pages` again.

With one book there is a single project to publish, so the earlier concern about two projects overwriting each other no longer applies.

Consequences for the repo:

-   Rendering happens on your machine, so the git-ignored `data/` is available at render time. No CI is needed, but the site can only be rebuilt from a machine that has run the scripts (or has the data cached).
-   `docs/` does not need to be committed. Use the Quarto book default output folder `_book/` (git-ignored) and drop `output-dir: docs`.
-   Commit `_freeze/` so heavy chunks are not re-executed unnecessarily.

### 4.2 DOCX

-   Render with `quarto render --to docx`, or render all formats with `quarto render`. Quarto produces a single combined DOCX for the whole book.
-   Adding `downloads: [docx]` to the book settings puts a download link in the website sidebar. The DOCX is generated at render time, so it is published together with the site.
-   Optionally provide a `reference-doc` (a Word template) to control fonts, headings and page layout, including a Spanish language style.

## 5. Proposed single bilingual book

One Quarto `type: book` project. Each chapter covers one topic and contains both languages. Computed content (maps, tables, numbers) is produced once and shared.

### 5.1 Layout inside each chapter

Recommended pattern: bilingual chapter and section titles, then the narrative text in a tabset, one tab per language.

``` markdown
# Study area / Área de estudio {#sec-study-area}

::: {.panel-tabset}
## English

The Río Buritaca drains the northern slope of the Sierra Nevada ...

## Español {lang="es"}

El río Buritaca drena la vertiente norte de la Sierra Nevada ...
:::

![Map of the watershed / Mapa de la cuenca](...){#fig-map}
```

How it behaves:

-   **HTML:** readers switch between tabs; each chapter shows one language at a time.
-   **DOCX:** Quarto turns tabsets into sequential headings in non-HTML formats, so the English text is followed by the Spanish text in the same chapter. This should be tested early (Phase 0) because details such as heading levels and numbering in Word can need tweaking.
-   **Shared elements** (figures, tables, cross-references) sit outside the tabsets with bilingual captions, so they appear once and are not duplicated.
-   **Numbers** in both languages come from inline R code, never typed by hand, so the two versions cannot disagree.

Fallback if tabsets do not work well in DOCX: write each chapter as two consecutive sections (English first, Spanish second) using conditional blocks, with no tabs. This is simpler but makes the HTML pages longer.

### 5.2 Format-specific content

-   Interactive leaflet maps go inside `::: {.content-visible when-format="html"}` blocks.
-   A static `ggplot2` map goes inside `::: {.content-visible unless-format="html"}` blocks, so DOCX gets a figure instead of the map widget.
-   Keep figure sizes and `dpi` set explicitly so figures fit a Word page.

### 5.3 Project tree

```
rio-buritaca/
  _quarto.yml
  index.qmd                 # Preface / Prefacio
  01-study-area.qmd         # Study area / Área de estudio
  02-methods.qmd            # Methods / Métodos
  03-watershed-map.qmd      # Watershed map / Mapa de la cuenca
  04-basin-statistics.qmd   # Basin statistics / Estadísticas de la cuenca
  05-stream-network.qmd     # Stream network / Red de drenaje
  06-sensitivity.qmd        # Sensitivity and validation / Sensibilidad y validación
  07-discussion.qmd         # Discussion / Discusión
  references.qmd
  references.bib
  reference.docx            # optional Word template
  scripts/
    00_config.R             # all parameters in one place
    01_get_dem.R
    02_condition_flow.R
    03_delineate.R
    04_vectorize.R
    05_basin_stats.R
    helpers.R               # shared plotting/table code with bilingual labels
  data/                     # generated, git-ignored
  _freeze/                  # committed
  _book/                    # rendered output, git-ignored
  other/
    agent_context.qmd       # user feedback; not edited by agents
    documents/              # planning notes
```

### 5.4 Draft `_quarto.yml`

``` yaml
project:
  type: book

book:
  title: "Río Buritaca Watershed Atlas / Atlas de la Cuenca del Río Buritaca"
  subtitle: "Sierra Nevada de Santa Marta, Colombia"
  repo-url: https://github.com/<user>/rio-buritaca
  downloads: [docx]
  chapters:
    - index.qmd
    - part: "Study design / Diseño del estudio"
      chapters:
        - 01-study-area.qmd
        - 02-methods.qmd
    - part: "Results / Resultados"
      chapters:
        - 03-watershed-map.qmd
        - 04-basin-statistics.qmd
        - 05-stream-network.qmd
    - part: "Assessment / Evaluación"
      chapters:
        - 06-sensitivity.qmd
        - 07-discussion.qmd
    - references.qmd

bibliography: references.bib
lang: en

format:
  html:
    theme: cosmo
  docx:
    number-sections: true
    # reference-doc: reference.docx

execute:
  echo: false
  warning: false
  message: false
  freeze: auto
```

Notes:

-   `lang: en` sets the interface language (search, labels); Spanish passages carry `lang="es"` so spell-checking and hyphenation in Word treat them correctly.
-   Quarto's cross-reference labels ("Figure", "Table") follow the document language, so they will appear in English. Custom labels via `crossref` options can show both, for example "Figure / Figura".
-   The `repo-url` is a placeholder to fill in.

## 6. Phased plan

### Phase 0: Setup and prototype

-   Unzip the project into the repo root; reconcile README and `.gitignore` (ignore `data/`, `_book/`; keep `_freeze/`).
-   Consider `renv` for package versions; list dependencies (`sf`, `terra`, `elevatr`, `whitebox`, `ggplot2`, `ggspatial`, `leaflet`, `here`).
-   Install WhiteboxTools via `whitebox::install_whitebox()`.
-   Prototype one bilingual chapter (tabset, bilingual caption, leaflet vs. static map) and render both HTML and DOCX to confirm the layout in 5.1 and 5.2 works before writing more content.

### Phase 1: Script hardening

-   Split `delineate_buritaca.R` into the numbered steps in `scripts/` that can be rerun independently.
-   Apply fixes 1, 3, 6 and 7 from the issues table.
-   Parameterize bbox, CRS, DEM source, threshold, snap distance, and pour point in `00_config.R`.
-   Add the Copernicus GLO-30 download and mosaic step alongside the `elevatr` option.

### Phase 2: Run and validate

-   Run the pipeline; inspect the DEM, flow accumulation, and snapped pour point.
-   Compare the watershed and streams against the reference datasets in 2.2; record any published area found.
-   Run sensitivity checks on DEM source, stream threshold, and snap distance. Report how much the basin area changes.

### Phase 3: Atlas content

-   Basin statistics: area, perimeter, elevation range, mean slope, hypsometric curve.
-   Stream network: Strahler order, drainage density, main channel length and profile.
-   Write each chapter's English text first, then the Spanish text in the same file.

### Phase 4: Publish

-   Render HTML and DOCX locally; review both, including the Spanish text.
-   Commit to `main`, then run `quarto publish gh-pages`.
-   Add a data and reproducibility note (sources, versions, run order) in both languages.

### Later (not scheduled)

-   Land cover, precipitation and climate, protected areas and indigenous territories, communities.

## 7. Remaining open questions

-   Is the tabset layout acceptable (one language visible at a time in HTML, sequential in DOCX)? The alternative is both languages shown one after the other in HTML too.
-   Confirm the DEM: go with Copernicus GLO-30 plus an `elevatr` cross-check?
-   Who translates and reviews the Spanish text? A draft translation by the assistant would need review by a Spanish speaker, especially for hydrological terminology.
-   Which exact river mouth coordinate should be used as the pour point? The draft's -73.775, 11.265 is only approximate.
-   Is a Word template available (fonts, headings) for the DOCX, or should the default Quarto styling be used?

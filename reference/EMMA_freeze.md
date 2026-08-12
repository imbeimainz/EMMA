# EMMA_freeze

This function records the R environment during analysis runtime and
generates a lockfile that can be used with tools such as `renv`. By
default, all currently loaded namespaces are recorded.

## Usage

``` r
EMMA_freeze(
  project = getwd(),
  file = "renv.lock",
  pkgs = loadedNamespaces(),
  prompt = interactive(),
  force = TRUE
)
```

## Arguments

- project:

  Character string corresponding to the path to the project directory
  where the lockfile should be written. If the directory does not exist,
  it will be created. It defaults to the current working directory

- file:

  Character string referring to the name of the lockfile to generate. It
  defaults to "renv.lock"

- pkgs:

  Character vector of package names to snapshot. It defaults to all
  currently loaded namespaces via
  [`loadedNamespaces()`](https://rdrr.io/r/base/ns-load.html)

- prompt:

  Logical indicating whether to prompt before taking actions. Defaults
  to [`interactive()`](https://rdrr.io/r/base/interactive.html)

- force:

  Logical indicating whether to force creation of the lockfile. Defaults
  to `TRUE`

## Value

Invisibly returns the path to the generated lockfile. The lockfile is
written in JSON format and can be used with
[`renv::restore()`](https://rstudio.github.io/renv/reference/restore.html)
to recreate the package environment

## Details

This function calls
[`renv::snapshot()`](https://rstudio.github.io/renv/reference/snapshot.html)
with the specified packages. The resulting lockfile can later be
restored with
[`renv::restore()`](https://rstudio.github.io/renv/reference/restore.html)
to recreate the same package environment.

By default, the lockfile is created with `force = TRUE`, allowing
snapshot creation even if inconsistencies are detected in the
environment.

## See also

[`snapshot`](https://rstudio.github.io/renv/reference/snapshot.html),
[`restore`](https://rstudio.github.io/renv/reference/restore.html)

## Examples

``` r
# create a lockfile
if (requireNamespace("renv", quietly = TRUE)) {
tmp <- tempfile("emma_env")
dir.create(tmp)

EMMA_freeze(project = tmp)

# inspect generated files
list.files(tmp)

# to restore the environment later
# renv::restore(project = tmp)
}
#> The following package(s) will be updated in the lockfile:
#> 
#> # Bioconductor ---------------------------------------------------------------
#> - EMMA                   [* -> 0.99.5]
#> - GO.db                  [* -> 3.23.1]
#> - org.Hs.eg.db           [* -> 3.23.1]
#> 
#> # Bioconductor 3.24 ----------------------------------------------------------
#> - BiocBaseUtils          [* -> 1.15.1]
#> - BiocFileCache          [* -> 3.3.0]
#> - BiocGenerics           [* -> 0.59.11]
#> - BiocIO                 [* -> 1.23.3]
#> - BiocParallel           [* -> 1.47.0]
#> - BiocVersion            [* -> 3.24.0]
#> - DOSE                   [* -> 4.7.2]
#> - DeeDeeExperiment       [* -> 1.3.0]
#> - GenomeInfoDb           [* -> 1.49.1]
#> - GenomicFeatures        [* -> 1.65.0]
#> - MatrixGenerics         [* -> 1.25.0]
#> - Rhtslib                [* -> 3.9.0]
#> - Rsamtools              [* -> 2.29.0]
#> - S4Arrays               [* -> 1.13.0]
#> - Seqinfo                [* -> 1.3.0]
#> - SparseArray            [* -> 1.13.2]
#> - SummarizedExperiment   [* -> 1.43.0]
#> - UCSC.utils             [* -> 1.9.0]
#> - XVector                [* -> 0.53.0]
#> - biomaRt                [* -> 2.69.0]
#> - enrichplot             [* -> 1.33.0]
#> - geneLenDataBase        [* -> 1.49.0]
#> - ggtree                 [* -> 4.3.0]
#> - goseq                  [* -> 1.65.0]
#> - graph                  [* -> 1.91.0]
#> - mosdef                 [* -> 1.9.0]
#> - qvalue                 [* -> 2.45.0]
#> - rtracklayer            [* -> 1.73.0]
#> - topGO                  [* -> 2.65.0]
#> - treeio                 [* -> 1.37.0]
#> - txdbmaker              [* -> 1.9.0]
#> 
#> # CRAN -----------------------------------------------------------------------
#> - BH                     [* -> 1.90.0-1]
#> - BiasedUrn              [* -> 2.0.12]
#> - BiocManager            [* -> 1.30.27]
#> - DBI                    [* -> 1.3.0]
#> - DT                     [* -> 0.34.0]
#> - MASS                   [* -> 7.3-66]
#> - Matrix                 [* -> 1.7-6]
#> - R6                     [* -> 2.6.1]
#> - RColorBrewer           [* -> 1.1-3]
#> - RCurl                  [* -> 1.98-1.19]
#> - RSQLite                [* -> 3.53.3]
#> - Rcpp                   [* -> 1.1.2]
#> - RcppArmadillo          [* -> 15.4.2-1]
#> - RcppEigen              [* -> 0.3.4.0.2]
#> - S7                     [* -> 0.2.2]
#> - SparseM                [* -> 1.84-2]
#> - XML                    [* -> 3.99-0.23]
#> - abind                  [* -> 1.4-8]
#> - aisdk                  [* -> 1.4.12]
#> - ape                    [* -> 5.8-1]
#> - aplot                  [* -> 0.3.1]
#> - askpass                [* -> 1.2.1]
#> - base64enc              [* -> 0.1-6]
#> - bit                    [* -> 4.6.0]
#> - bit64                  [* -> 4.8.2]
#> - bitops                 [* -> 1.1-0]
#> - blob                   [* -> 1.3.0]
#> - brew                   [* -> 1.0-10]
#> - brio                   [* -> 1.1.5]
#> - bslib                  [* -> 0.12.0]
#> - cachem                 [* -> 1.1.0]
#> - callr                  [* -> 3.8.0]
#> - cli                    [* -> 3.6.6]
#> - clipr                  [* -> 0.8.1]
#> - cluster                [* -> 2.1.8.3]
#> - codetools              [* -> 0.2-20]
#> - commonmark             [* -> 2.0.0]
#> - cpp11                  [* -> 0.5.5]
#> - crayon                 [* -> 1.5.3]
#> - credentials            [* -> 2.0.3]
#> - crosstalk              [* -> 1.2.2]
#> - curl                   [* -> 7.1.0]
#> - data.table             [* -> 1.18.4]
#> - dbplyr                 [* -> 2.6.0]
#> - desc                   [* -> 1.4.3]
#> - devtools               [* -> 2.5.2]
#> - dichromat              [* -> 2.0-1]
#> - diffobj                [* -> 0.3.8]
#> - digest                 [* -> 0.6.39]
#> - downlit                [* -> 0.4.5]
#> - dplyr                  [* -> 1.2.1]
#> - ellipsis               [* -> 0.3.3]
#> - enrichit               [* -> 0.2.1]
#> - evaluate               [* -> 1.0.5]
#> - fansi                  [* -> 1.0.7]
#> - farver                 [* -> 2.1.2]
#> - fastmap                [* -> 1.2.0]
#> - filelock               [* -> 1.0.3]
#> - fontBitstreamVera      [* -> 0.1.1]
#> - fontLiberation         [* -> 0.1.0]
#> - fontawesome            [* -> 0.5.3]
#> - fontquiver             [* -> 0.2.1]
#> - formatR                [* -> 1.14]
#> - fs                     [* -> 2.1.0]
#> - futile.logger          [* -> 1.4.9]
#> - futile.options         [* -> 1.0.1]
#> - gdtools                [* -> 0.5.1]
#> - generics               [* -> 0.1.4]
#> - gert                   [* -> 2.4.0]
#> - ggforce                [* -> 0.5.0]
#> - ggfun                  [* -> 0.2.1]
#> - ggiraph                [* -> 0.9.6]
#> - ggnewscale             [* -> 0.5.2]
#> - ggplot2                [* -> 4.0.3]
#> - ggplotify              [* -> 0.1.3]
#> - ggrepel                [* -> 0.9.8]
#> - ggtangle               [* -> 0.1.2]
#> - gh                     [* -> 1.6.1]
#> - gitcreds               [* -> 0.1.2]
#> - glue                   [* -> 1.8.1]
#> - gprofiler2             [* -> 0.2.4]
#> - gridExtra              [* -> 2.3.1]
#> - gridGraphics           [* -> 0.5-1]
#> - gson                   [* -> 0.2.1]
#> - gtable                 [* -> 0.3.6]
#> - highr                  [* -> 0.12]
#> - hms                    [* -> 1.1.4]
#> - htmltools              [* -> 0.5.9]
#> - htmlwidgets            [* -> 1.6.4]
#> - httpuv                 [* -> 1.6.17]
#> - httr                   [* -> 1.4.8]
#> - httr2                  [* -> 1.3.0]
#> - igraph                 [* -> 2.3.3]
#> - ini                    [* -> 0.3.1]
#> - isoband                [* -> 0.3.0]
#> - jquerylib              [* -> 0.1.4]
#> - jsonlite               [* -> 2.0.0]
#> - knitr                  [* -> 1.51]
#> - labeling               [* -> 0.4.3]
#> - lambda.r               [* -> 1.2.4]
#> - later                  [* -> 1.4.8]
#> - lattice                [* -> 0.22-9]
#> - lazyeval               [* -> 0.2.3]
#> - lifecycle              [* -> 1.0.5]
#> - locfit                 [* -> 1.5-9.12]
#> - magrittr               [* -> 2.0.5]
#> - matrixStats            [* -> 1.5.0]
#> - memoise                [* -> 2.0.1]
#> - mgcv                   [* -> 1.9-4]
#> - mime                   [* -> 0.13]
#> - miniUI                 [* -> 0.1.2]
#> - nlme                   [* -> 3.1-170]
#> - openssl                [* -> 2.4.2]
#> - otel                   [* -> 0.2.0]
#> - pak                    [* -> 0.11.1]
#> - patchwork              [* -> 1.3.2]
#> - pillar                 [* -> 1.11.1]
#> - pkgbuild               [* -> 1.4.8]
#> - pkgconfig              [* -> 2.0.3]
#> - pkgdown                [* -> 2.2.1]
#> - pkgload                [* -> 1.5.3]
#> - plotly                 [* -> 4.12.1]
#> - plyr                   [* -> 1.8.9]
#> - png                    [* -> 0.1-9]
#> - polyclip               [* -> 1.10-7]
#> - praise                 [* -> 1.0.0]
#> - prettyunits            [* -> 1.2.0]
#> - processx               [* -> 3.9.0]
#> - profvis                [* -> 0.4.0]
#> - progress               [* -> 1.2.3]
#> - promises               [* -> 1.5.0]
#> - ps                     [* -> 1.9.3]
#> - purrr                  [* -> 1.2.2]
#> - ragg                   [* -> 1.5.2]
#> - rappdirs               [* -> 0.3.4]
#> - rcmdcheck              [* -> 1.4.0]
#> - rdtools                [* -> 0.1.0]
#> - remotes                [* -> 2.5.0]
#> - renv                   [* -> 1.2.4]
#> - reshape2               [* -> 1.4.5]
#> - restfulr               [* -> 0.0.17]
#> - rjson                  [* -> 0.2.23]
#> - rlang                  [* -> 1.3.0]
#> - rmarkdown              [* -> 2.31]
#> - roxygen2               [* -> 8.1.0]
#> - rprojroot              [* -> 2.1.1]
#> - rstudioapi             [* -> 0.19.0]
#> - rversions              [* -> 3.0.0]
#> - sass                   [* -> 0.4.10]
#> - scales                 [* -> 1.4.0]
#> - scatterpie             [* -> 0.2.6]
#> - sessioninfo            [* -> 1.2.4]
#> - shiny                  [* -> 1.14.0]
#> - snow                   [* -> 0.4-4]
#> - sourcetools            [* -> 0.1.7-2]
#> - statmod                [* -> 1.5.2]
#> - stringi                [* -> 1.8.9]
#> - stringr                [* -> 1.6.0]
#> - sys                    [* -> 3.4.3]
#> - systemfonts            [* -> 1.3.2]
#> - testthat               [* -> 3.3.2]
#> - textshaping            [* -> 1.0.5]
#> - tibble                 [* -> 3.3.1]
#> - tidydr                 [* -> 0.0.6]
#> - tidyr                  [* -> 1.3.2]
#> - tidyselect             [* -> 1.2.1]
#> - tidytree               [* -> 0.4.8]
#> - tinytex                [* -> 0.60]
#> - tweenr                 [* -> 2.0.3]
#> - urlchecker             [* -> 2.0.0]
#> - usethis                [* -> 3.2.1]
#> - utf8                   [* -> 1.2.6]
#> - vctrs                  [* -> 0.7.3]
#> - viridisLite            [* -> 0.4.3]
#> - waldo                  [* -> 0.6.2]
#> - whisker                [* -> 0.4.1]
#> - withr                  [* -> 3.0.3]
#> - writexl                [* -> 2.0.0]
#> - xfun                   [* -> 0.60]
#> - xml2                   [* -> 1.6.0]
#> - xopen                  [* -> 1.0.1]
#> - xtable                 [* -> 1.8-8]
#> - yaml                   [* -> 2.3.12]
#> - yulab.utils            [* -> 0.2.4]
#> - zip                    [* -> 3.0.2]
#> 
#> # https://bioc.r-universe.dev ------------------------------------------------
#> - AnnotationDbi          [* -> 1.75.2]
#> - Biobase                [* -> 2.73.2]
#> - Biostrings             [* -> 2.81.6]
#> - DESeq2                 [* -> 1.53.2]
#> - DelayedArray           [* -> 0.39.4]
#> - GOSemSim               [* -> 2.39.2]
#> - GenomicAlignments      [* -> 1.49.1]
#> - GenomicRanges          [* -> 1.65.1]
#> - IRanges                [* -> 2.47.2]
#> - KEGGREST               [* -> 1.53.6]
#> - S4Vectors              [* -> 0.51.6]
#> - SingleCellExperiment   [* -> 1.35.2]
#> - cigarillo              [* -> 1.3.1]
#> - clusterProfiler        [* -> 4.21.1]
#> - edgeR                  [* -> 4.11.4]
#> - limma                  [* -> 3.69.2]
#> 
#> The version of R recorded in the lockfile will be updated:
#> - R                      [* -> 4.6.1]
#> 
#> - Lockfile written to "/var/folders/5q/v_ms_h9x6mv05dzlf94g48d00000gn/T//RtmpUWbSV3/emma_env11c8a6deaf487/renv.lock".
#> ℹ Environment snapshot saved to: "/var/folders/5q/v_ms_h9x6mv05dzlf94g48d00000gn/T//RtmpUWbSV3/emma_env11c8a6deaf487/renv.lock". 
#> To recreate this environment, use `renv::restore()`.
#> [1] "renv.lock"
```

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
#> The following Bioconductor packages appear to be from a separate Bioconductor release:
#> - EMMA [installed 0.99.4 != latest <NA>]
#> renv may be unable to restore these packages.
#> Bioconductor version: 3.24
#> 
#> The following required packages are not installed:
#> - BiocVersion  [required by AnnotationDbi, Biobase, BiocGenerics, and 7 others]
#> Consider reinstalling these packages before snapshotting the lockfile.
#> 
#> The following package(s) will be updated in the lockfile:
#> 
#> # Bioconductor ---------------------------------------------------------------
#> - EMMA            [* -> 0.99.4]
#> 
#> # Bioconductor 3.24 ----------------------------------------------------------
#> - AnnotationDbi   [* -> 1.75.0]
#> - Biobase         [* -> 2.73.1]
#> - KEGGREST        [* -> 1.53.0]
#> - Seqinfo         [* -> 1.3.0]
#> - XVector         [* -> 0.53.0]
#> 
#> # CRAN -----------------------------------------------------------------------
#> - BiocManager     [* -> 1.30.27]
#> - DBI             [* -> 1.3.0]
#> - R6              [* -> 2.6.1]
#> - RSQLite         [* -> 3.53.1]
#> - askpass         [* -> 1.2.1]
#> - base64enc       [* -> 0.1-6]
#> - bit             [* -> 4.6.0]
#> - bit64           [* -> 4.8.2]
#> - blob            [* -> 1.3.0]
#> - brio            [* -> 1.1.5]
#> - bslib           [* -> 0.11.0]
#> - cachem          [* -> 1.1.0]
#> - callr           [* -> 3.8.0]
#> - cli             [* -> 3.6.6]
#> - cpp11           [* -> 0.5.5]
#> - crayon          [* -> 1.5.3]
#> - curl            [* -> 7.1.0]
#> - desc            [* -> 1.4.3]
#> - digest          [* -> 0.6.39]
#> - downlit         [* -> 0.4.5]
#> - evaluate        [* -> 1.0.5]
#> - fansi           [* -> 1.0.7]
#> - fastmap         [* -> 1.2.0]
#> - fontawesome     [* -> 0.5.3]
#> - fs              [* -> 2.1.0]
#> - generics        [* -> 0.1.4]
#> - glue            [* -> 1.8.1]
#> - highr           [* -> 0.12]
#> - htmltools       [* -> 0.5.9]
#> - htmlwidgets     [* -> 1.6.4]
#> - httr            [* -> 1.4.8]
#> - httr2           [* -> 1.2.2]
#> - jquerylib       [* -> 0.1.4]
#> - jsonlite        [* -> 2.0.0]
#> - knitr           [* -> 1.51]
#> - lifecycle       [* -> 1.0.5]
#> - magrittr        [* -> 2.0.5]
#> - memoise         [* -> 2.0.1]
#> - mime            [* -> 0.13]
#> - nanonext        [* -> 1.9.1]
#> - openssl         [* -> 2.4.2]
#> - otel            [* -> 0.2.0]
#> - pillar          [* -> 1.11.1]
#> - pkgbuild        [* -> 1.4.8]
#> - pkgconfig       [* -> 2.0.3]
#> - png             [* -> 0.1-9]
#> - processx        [* -> 3.9.0]
#> - ps              [* -> 1.9.3]
#> - purrr           [* -> 1.2.2]
#> - ragg            [* -> 1.5.2]
#> - rappdirs        [* -> 0.3.4]
#> - remotes         [* -> 2.5.0]
#> - renv            [* -> 1.2.3]
#> - rlang           [* -> 1.2.0]
#> - rmarkdown       [* -> 2.31]
#> - sass            [* -> 0.4.10]
#> - stringi         [* -> 1.8.7]
#> - sys             [* -> 3.4.3]
#> - systemfonts     [* -> 1.3.2]
#> - textshaping     [* -> 1.0.5]
#> - tibble          [* -> 3.3.1]
#> - tinytex         [* -> 0.59]
#> - utf8            [* -> 1.2.6]
#> - vctrs           [* -> 0.7.3]
#> - whisker         [* -> 0.4.1]
#> - withr           [* -> 3.0.2]
#> - xfun            [* -> 0.58]
#> - xml2            [* -> 1.5.2]
#> - yaml            [* -> 2.3.12]
#> 
#> # GitHub ---------------------------------------------------------------------
#> - pkgdown         [* -> r-lib/pkgdown]
#> 
#> # https://bioc.r-universe.dev ------------------------------------------------
#> - BiocGenerics    [* -> 0.59.7]
#> - Biostrings      [* -> 2.81.3]
#> - IRanges         [* -> 2.47.2]
#> - S4Vectors       [* -> 0.51.3]
#> 
#> The version of R recorded in the lockfile will be updated:
#> - R               [* -> 4.6.0]
#> 
#> - Lockfile written to "/var/folders/8d/778wjbv96mq1760tv6gk374m0000gn/T//RtmpQrrnP3/emma_env4fe7183a9690/renv.lock".
#> ℹ Environment snapshot saved to: "/var/folders/8d/778wjbv96mq1760tv6gk374m0000gn/T//RtmpQrrnP3/emma_env4fe7183a9690/renv.lock". 
#> To recreate this environment, use `renv::restore()`.
#> [1] "renv.lock"
```

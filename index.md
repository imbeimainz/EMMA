# EMMA - Enrichment Methods MAtter

![](inst/www/EMMA-logo.png)

EMMA enables the execution of Functional Enrichment Analyses using a
wide range of existing tools (e.g. `clusterProfiler`, `topGO`,
`gprofiler2` among others) while systematically capturing analysis
parameters and provenance information during runtime, and returning
enrichment results in their standard format alongside structured and
reusable metadata.

## Installation

You can install the release version of `EMMA` from Bioconductor with:

``` r

if (!requireNamespace("BiocManager", quietly = TRUE)) {
  install.packages("BiocManager")}

BiocManager::install("EMMA")
```

And the development version from GitHub with:

``` r

library("remotes")
remotes::install_github("imbeimainz/EMMA",
                        dependencies = TRUE,
                        build_vignettes = TRUE)
```

## Example

``` r

library(EMMA)
# load data
data("de_res_IFNg_vs_naive", package = "EMMA")
data("gene_universe", package = "EMMA")

# run analysis
fea_results <- enrichGO(gene = rownames(de_res_IFNg_vs_naive),
                        universe = gene_universe,
                        keyType = "ENSEMBL",
                        OrgDb = org.Hs.eg.db,
                        ont = "BP") |> 
               EMMA_run()
```

## Usage Overview

You can find the rendered version of the documentation of `EMMA` at the
project website <https://imbeimainz.github.io/EMMA/>

## Development

If you encounter a bug, have usage questions, or want to share ideas and
functionality to make this package better, feel free to file an
[issue](https://github.com/imbeimainz/EMMA/issues).

## Code of Conduct

Please note that the EMMA project is released with a [Contributor Code
of
Conduct](https://contributor-covenant.org/version/3/0/CODE_OF_CONDUCT.html).
By contributing to this project, you agree to abide by its terms.

## License

MIT

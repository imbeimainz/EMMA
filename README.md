# EMMA

EMMA aims to explicitly capture analytical parameters during functional
enrichment analysis runtime, while returning native enrichment results together
with structured metadata.

## Installation

You can install the development version of `EMMA` from GitHub with

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
data("universe", package = "EMMA")

# run analysis
fea_results <- enrichGO(gene = rownames(de_res_IFNg_vs_naive),
                        universe = universe,
                        keyType = "ENSEMBL",
                        OrgDb = org.Hs.eg.db,
                        ont = "BP") |> 
                        EMMA_run()

```

## Development

If you encounter a bug, have usage questions, or want to share ideas and
functionality to make this package better, feel free to file an
[issue](https://github.com/imbeimainz/EMMA/issues).

## Code of Conduct

Please note that the EMMA project is released with a [Contributor Code
of Conduct](https://contributor-covenant.org/version/2/0/CODE_OF_CONDUCT.html).
By contributing to this project, you agree to abide by its terms.

## License

MIT

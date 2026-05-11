# EMMA_explain

This function generates a human-readable description of the FEA, similar
to a Materials and Methods section of a paper, by summarizing the
executed call, the parameters, software context, and reference databases
used.

## Usage

``` r
EMMA_explain(res, get_citation = TRUE)
```

## Arguments

- res:

  A functional enrichment analysis results object as returned by
  [`EMMA_run()`](EMMA_run.md). Its attributes contain `EMMA_record`,
  which contains all provenance information of the performed FEA

- get_citation:

  Logical indicating whether to display the citations of the packages
  used in the FEA. It only prints the citations in an interactive
  session (e.g console). Defaults to `TRUE`

## Value

A character string describing how the FEA was performed using the
recorded metadata

## Examples

``` r
data("fea_res", package = "EMMA")
EMMA_explain(fea_res)
#> ℹ You can always complete your text with additional information from `EMMA_get_record()`!
#> ℹ References:
#> To cite gprofiler2 in publications, please use:
#>   Kolberg L, Raudvere U, Kuzmin I, Vilo J, Peterson H (2020).
#>   “gprofiler2- an R package for gene list functional enrichment
#>   analysis and namespace conversion toolset g:Profiler.”
#>   _F1000Research_, *9 (ELIXIR)*(709). R package version 0.2.4.
#> 
#> A BibTeX entry for LaTeX users is
#> 
#>   @Article{,
#>     title = {gprofiler2-- an R package for gene list functional enrichment analysis and namespace conversion toolset g:Profiler},
#>     journal = {F1000Research},
#>     author = {Liis Kolberg and Uku Raudvere and Ivan Kuzmin and Jaak Vilo and Hedi Peterson},
#>     volume = {9 (ELIXIR)},
#>     number = {709},
#>     year = {2020},
#>     note = {R package version 0.2.4},
#>   }
#> [1] "Functional Enrichment Analysis was performed using the gost() function from the gprofiler2 package (version 0.2.4) with the GO:BP database (version annotations: BioMart\nclasses: releases/2026-01-23). A custom background gene set was provided. Multiple testing correction was performed using the fdr method."
```

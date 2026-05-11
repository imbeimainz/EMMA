# EMMA_show

This function displays a human-readable summary of the `EMMA_record`
attribute attached to a result object produced by
[`EMMA_run()`](EMMA_run.md)

## Usage

``` r
EMMA_show(res)
```

## Arguments

- res:

  A functional enrichment analysis results object as returned by
  [`EMMA_run()`](EMMA_run.md)

## Value

[`base::invisible()`](https://rdrr.io/r/base/invisible.html)

## Examples

``` r
data("fea_res", package = "EMMA")
EMMA_show(fea_res)
#> ℹ Found EMMA record!
#> Number of Pathways:  180 
#> Call:  gprofiler2::gost(query = de_res_IFNg_vs_naive$SYMBOL, organism = "hsapiens",      correction_method = "fdr", custom_bg = universe, sources = "GO:BP")  
#> Wrapper:  FALSE  
#> Package:  gprofiler2 v. 0.2.4  
#> Organism :  hsapiens  
#> Gene set library :  GO:BP  
#> Gene set library version :  annotations: BioMart
#> classes: releases/2026-01-23  
#> 
```

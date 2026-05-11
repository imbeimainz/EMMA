# EMMA_add_custom_metadata

Append or replace the `extra` field in the `EMMA_record` attribute of a
result object returned by [`EMMA_run()`](EMMA_run.md). This allows users
to manually provide additional annotation or contextual information that
could not be captured automatically

## Usage

``` r
EMMA_add_custom_metadata(res, extra = list())
```

## Arguments

- res:

  A functional enrichment analysis results object as returned by
  [`EMMA_run()`](EMMA_run.md)

- extra:

  A named list of user-defined metadata elements to store in the `extra`
  field

## Value

The input result object with updated `EMMA_record` attribute

## Examples

``` r
data("fea_res", package = "EMMA")
fea_res <- EMMA_add_custom_metadata(fea_res, extra =
list(note = "The background gene set list was all expressed genes in the assay"))
```

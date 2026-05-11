# A sample `list` containing Functional Enrichment Analysis results, generated with `gprofiler2`

A sample `list` containing Functional Enrichment Analysis results,
generated with `gprofiler2`

## Format

A `list`

## Value

A sample `list` containing the FEA results `result` and `metadata`. This
results object has the `EMMA_record` attribute.

## Details

This `list` object contains the result table and metadata of the
functional enrichment analysis (FEA) performed on the `macrophage` data,
specifically using the
[`gost()`](https://rdrr.io/pkg/gprofiler2/man/gost.html) function from
the `gprofiler2` package, and wrapped in [`EMMA_run()`](EMMA_run.md)

The code to create said object can be found in the folder
`/inst/scripts` in the EMMA package, the file is called
`create_datasets_examples.R`.

## References

Alasoo, et al. "Shared genetic effects on chromatin and gene expression
indicate a role for enhancer priming in immune response", Nature
Genetics, January 2018 doi: 10.1038/s41588-018-0046-7.

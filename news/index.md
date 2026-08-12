# Changelog

## EMMA 1.0.0

- EMMA is on Bioconductor!
- Fix the unit tests for
  [`gseGO()`](https://rdrr.io/pkg/clusterProfiler/man/gseGO.html) after
  the recent update to `enrichit` v0.2.1 (a dependency of
  `clusterProfiler`)

## EMMA 0.99.4

- Addressed the points raised in the Bioc review.

## EMMA 0.99.0

- Ready for Bioconductor submission!

## EMMA 0.3.0

- Added the initial implementation of
  [`EMMA_freeze()`](../reference/EMMA_freeze.md).
- [`EMMA_explain()`](../reference/EMMA_explain.md) now returns also
  citations of the used packages.
- Renamed `getEMMARecord()` to
  [`EMMA_get_record()`](../reference/EMMA_get_record.md) for
  consistency.
- Resizing toy data to speed up examples.
- Updated the vignette.
- Updating unit tests.

## EMMA 0.2.0

- [`EMMA_run()`](../reference/EMMA_run.md) can accept custom functions
  and wrappers and collect metadata based on which function was used in
  the wrapper.
- Added
  [`EMMA_add_custom_metadata()`](../reference/EMMA_add_custom_metadata.md)
  to give the user manual/easy access to modify `user_metdata` field in
  `EMMA_record`.
- Added a fully runnable vignette.

## EMMA 0.1.0

- [`EMMA_run()`](../reference/EMMA_run.md) captures a function call,
  executes the FEA analysis, and returns the results in their native
  format while attaching structured metadata to the result object as
  attribute.
- [`EMMA_run()`](../reference/EMMA_run.md) can now capture information
  from functions in `mosdef`, `gprofiler2`, and 5 commonly used
  functions from `clusterProfiler`.
- [`EMMA_show()`](../reference/EMMA_show.md) prints the captured
  metadata in a more user-friendly format.
- Added `getEMMARecord()` to fetch all metadata stored in the attributes
  of an object returned by [`EMMA_run()`](../reference/EMMA_run.md).
- Added toy data.
- Added the initial implementation of `EMMA_explain`.

## EMMA 0.0.1

- Added the initial implementation of
  [`EMMA_run()`](../reference/EMMA_run.md) and
  [`EMMA_show()`](../reference/EMMA_show.md).
- Added vignette outlining EMMA usage

## EMMA 0.0.0.9000

- Added a `NEWS.md` file to track changes to the package.

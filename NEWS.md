# EMMA 0.3.0

* Added the initial implementation of `EMMA_freeze()`.
* `EMMA_explain()` now returns also citations of the used packages.
* Renamed `getEMMARecord()` to `EMMA_get_record()` for consistency.
* Resizing toy data to speed up examples.
* Updated the vignette.
* Updating unit tests.

# EMMA 0.2.0

* `EMMA_run()` can accept custom functions and wrappers and collect metadata
based on which function was used in the wrapper.
* Added `EMMA_add_custom_metadata()` to give the user manual/easy access to modify
`user_metdata` field in `EMMA_record`.
* Added a fully runnable vignette.


# EMMA 0.1.0

* `EMMA_run()` captures a function call, executes the FEA analysis, and returns
the results in their native format while attaching structured metadata to the
result object as attribute.
* `EMMA_run()` can now capture information from functions in `mosdef`,
`gprofiler2`, and 5 commonly used functions from `clusterProfiler`.
* `EMMA_show()` prints the captured metadata in a more user-friendly format.
* Added `getEMMARecord()` to fetch all metadata stored in the attributes of an
object returned by `EMMA_run()`.
* Added toy data.
* Added the initial implementation of `EMMA_explain`.


# EMMA 0.0.1

* Added the initial implementation of `EMMA_run()` and `EMMA_show()`.
* Added vignette outlining EMMA usage

# EMMA 0.0.0.9000

* Added a `NEWS.md` file to track changes to the package.

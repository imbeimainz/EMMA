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


# EMMA 0.0.1

* Added the initial implementation of `EMMA_run()` and `EMMA_show()`.
* Added vignette outlining EMMA usage

# EMMA 0.0.0.9000

* Added a `NEWS.md` file to track changes to the package.

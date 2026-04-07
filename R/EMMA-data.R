#' A sample `data.frame` containing Differential Expression Analysis, generated
#' with `DESeq2`
#'
#' @details This `data.frame` object contains the results of a Differential
#' Expression Analysis performed on data from the `macrophage` package, more
#' precisely contrasting the counts from naive macrophage to those associated
#' with IFNg.
#'
#' The code to create said object can be found in the folder `/inst/scripts` in
#' the EMMA package, the file is called `create_datasets_examples.R`.
#'
#' @return A sample `data.frame` object, extracted from `DESeq2` results
#'
#' @format A `data.frame` object
#'
#'
#' @references Alasoo, et al. "Shared genetic effects on chromatin and gene
#' expression indicate a role for enhancer priming in immune response",
#' Nature Genetics, January 2018 doi: 10.1038/s41588-018-0046-7.
#'
#' @name de_res_IFNg_vs_naive
#' @docType data
NULL

#' A sample `character vector` containing the background gene list used to
#' perform FEA on the `macrophage` dataset
#'
#' @details This `character vector` object that contains the assay's `rownames`
#' of the `macrophage` data
#'
#' The code to create said object can be found in the folder `/inst/scripts` in
#' the EMMA package, the file is called `create_datasets_examples.R`.
#'
#' @return A sample `character vector` containing the assay's `rownames`
#' of the `macrophage` data
#'
#' @format A `character vector`
#'
#'
#' @references Alasoo, et al. "Shared genetic effects on chromatin and gene
#' expression indicate a role for enhancer priming in immune response",
#' Nature Genetics, January 2018 doi: 10.1038/s41588-018-0046-7.
#'
#' @name universe
#' @docType data
NULL
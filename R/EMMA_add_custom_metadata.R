#' EMMA_add_custom_metadata
#'
#' Append or replace the `extra` field in the `EMMA_record` attribute
#' of a result object returned by `EMMA_run()`. This allows users to manually
#' provide additional annotation or contextual information that could not be
#' captured automatically
#'
#' @param res A functional enrichment analysis results object as returned by
#' `EMMA_run()`
#' @param extra A named list of user-defined metadata elements to store in
#' the `extra` field
#'
#' @returns The input result object with updated `EMMA_record` attribute
#' @export
#'
#' @examples
#' data("fea_res", package = "EMMA")
#' fea_res <- EMMA_add_custom_metadata(fea_res, extra =
#'   list(note = "The background gene set list was all expressed genes in the assay"))
EMMA_add_custom_metadata <- function(res,
                                     extra = list()) {

  if (!is.list(extra)) {
    stop("`extra` must be a list!")
  }

  if (length(extra) > 0L && is.null(names(extra))) {
    stop("`extra` must be a named list!")
  }
  
  emma_rec <- EMMA_get_record(res = res)
  
  emma_rec$extra <- extra

  # update
  attr(res, "EMMA_record") <- emma_rec

  return(res)
}

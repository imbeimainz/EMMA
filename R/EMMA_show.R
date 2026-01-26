#' EMMA_show
#' 
#' This function prints the EMMA record associated with a functional enrichment
#' analysis object, including the executed call, parameters, and provenance
#' information.
#' @param res A functional enrichment analysis results object as returned by
#' `EMMA_run()`
#'
#' @returns A list of the recorded information
#' @export
#'
#' @examples
#' res <- EMMA_run(enrichGO(gene = rownames(de_res_IFNg_vs_naive), universe = universe, keyType = "ENSEMBL", OrgDb = org.Hs.eg.db, ont = "BP"))
#' EMMA_show(res)
EMMA_show <- function(res){
  if ("EMMA_record" %in% names(attributes(res))) {
    message("Found EMMA record!!")
    emma_rec <- attr(res, "EMMA_record")
    # should think of a better way to show the records
    str(emma_rec)
  }
  
}
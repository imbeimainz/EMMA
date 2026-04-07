#' getEMMARecord
#'
#' @param res Functional Enrichment Analysis results (enrichResult, gseaResult ...)
#'
#' @return list of metadata recorded during FEA runtime
#' @export
#'
#' @examples
#' data("de_res_IFNg_vs_naive", package = "EMMA")
#' data("universe", package = "EMMA")
#' library("clusterProfiler")
#' res <- EMMA_run(enrichGO(gene = rownames(de_res_IFNg_vs_naive),
#' universe = universe, keyType = "ENSEMBL", OrgDb = org.Hs.eg.db::org.Hs.eg.db,
#' ont = "BP"))
#' getEMMARecord(res)
getEMMARecord <- function(res){
  attr(res, "EMMA_record")
}
#' EMMA_run
#' 
#' This function executes any supported functional enrichment analysis function
#' and automatically captures the call, its associated parameters and provenance
#' information when available during runtime as an `EMMA_record` attribute
#' on the returned results object.
#'
#' @param expr A function call that performs functional enrichment analysis.
#' The call is captured and executed by EMMA to record analysis parameters and
#' provenance information. Both bare calls (`enrichGO(...)`) and namespace-qualified
#' calls (`clusterProfiler::enrichGO(...)`) are supported. Any other form
#' (e.g. `do.call`, `get()`) will raise an error
#' @param envir An environment in which to evaluate `expr`
#' @param session Logical, indicating whether to store the output of
#' `sessionInfo()` or not. If `TRUE` (default), the session is stored in the
#' provenance record
#' @param args_form A character string indicating whether to store the evaluated
#' or the unevaluated arguments in the provenance record. It default to `"evaluated"`
#'
#' @returns The result object returned by the enrichment function in `expr`,
#'   unmodified except for an added `EMMA_record` attribute containing the
#'   provenance information. Use `getEMMARecord()` to access it
#' @export
#'
#' @examples
#' data("de_res_IFNg_vs_naive", package = "EMMA")
#' data("universe", package = "EMMA")
#' EMMA_run(clusterProfiler::enrichGO(gene = rownames(de_res_IFNg_vs_naive),
#' universe = universe, keyType = "ENSEMBL", OrgDb = org.Hs.eg.db::org.Hs.eg.db,
#' ont = "BP"))
EMMA_run <- function(expr, envir = parent.frame(), session = TRUE,
                     args_form = c("evaluated", "unevaluated")) {
  args_form <- match.arg(args_form)
  
  # capture call
  call <- substitute(expr)
  
  # param checks
  if (!is.call(call)) {
    stop("`expr` must be a function call, e.g. enrichGO(...)!")
  }
  
  # capture call information
  info_call <- EMMA_capture_call_info(call = call)
   function_name <- info_call$function_name
   package_name <- info_call$package_name

  # capture args (unevaluated)
  arg_list <- info_call$arg_list
  arg_names <- names(arg_list)
  
  # some good practice warning, i.e. when multiple testing correction is skipped
  # or bg geneset not set
  EMMA_warnings(arg_names = arg_names,
                       function_name = function_name)
  
  #capture analysis time
  start_time <- Sys.time()
  message("Running Enrichment Analysis with ", function_name, " ...") 
  
  # capture the value of the arguments
  args <- lapply(arg_list, eval, envir = envir)
  info_call$args <- args 
  
  
  # get the function
  fun <- eval(call[[1]], envir = envir)
  
  ##### run the analysis ####
  results <- do.call(fun, args)
  
  # capture metadata from the used function and arguments
  metadata <- EMMA_get_metadata(
    function_name = function_name,
    package_name = package_name,
    args = args
  )
  
  # record everything in EMMA_record
  EMMA_record <- EMMA_build_record(info_call, args_form, metadata,
                                   start_time, session)
    
  # store the EMMA_record as attribute of the results obj
  attr(results, "EMMA_record") <- EMMA_record

  return(results)
}

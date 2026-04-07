#' EMMA_run
#' 
#' This function executes functional enrichment analysis using existing tools
#' and captures the associated parameters and provenance information for the
#' analysis when available during runtime.
#'
#' @param expr A function call that performs functional enrichment analysis.
#' The call is captured and executed by EMMA to record analysis parameters and
#' provenance information
#' @param envir An environment in which to evaluate `expr`
#' @param session Logical, indicating whether to store sessionInfo or not.
#' It defaults to (`TRUE`) saving the session
#' @param args_form A character string indicating whether to store the evaluated
#' or the unevaluated arguments. It default to store the evaluated arguments
#'
#' @returns Functional enrichment analysis results in the native format
#' returned by the original `expr`
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
  info_call <- .EMMA_capture_call_info(call = call)
  function_name <- info_call$function_name
  package_name <- info_call$package_name
  package_version <- info_call$package_version

  # capture args (unevaluated)
  arg_list <- as.list(call)[-1]
  arg_names <- names(arg_list)
  
  # some good practice warning, i.e. when multiple testing correction is skipped
  # or bg geneset not set
  .EMMA_warnings(arg_names = arg_names,
                       function_name = function_name)
  
  #capture analysis time
  start_time <- Sys.time()
  message("Running Enrichment Analysis with ", function_name, " ...") 
  
  # capture the value of the arguments
  args <- lapply(arg_list, eval, envir = envir)
  
  # get the function
  fun <- eval(call[[1]], envir = envir)
  
  ##### run the analysis ####
  results <- do.call(fun, args)
  
  # capture metadata from the used function and arguments
  metadata <- .EMMA_get_metadata(
    function_name = function_name,
    package_name = package_name,
    args = args
  )
  
  # record everything in EMMA_record
  EMMA_record <- .EMMA_build_record(call, function_name, package_name,
                                    package_version, args,
                                    arg_list, args_form, metadata,
                                    start_time, session)
    
  # store the EMMA_record as attribute of the results obj
  attr(results, "EMMA_record") <- EMMA_record

  return(results)
}

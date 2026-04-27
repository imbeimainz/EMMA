# metadata capture -------------------------------------------------------------
#' This function creates a standardized metadata structure used to store
#' annotation info for FEAs. This ensures a consistent structure across
#' different enrichment methods and packages
#' 
#' @noRd
EMMA_empty_metadata <- function() { 
  list(
    organism = NA_character_,
    gene_set_db = NA_character_,
    gene_set_db_version = NA_character_
)
}


#' This function acts as a dispatcher, routing to package-specific helpers
#' (e.g. for `clusterProfiler`, `gprofiler2` ...) to standardize metadata
#' collection across different enrichment tools
#'
#' @param info_call A list containing captured call information, including
#' at least `function_name`, `package_name`, and the original `call`
#'   
#' @param args A list of evaluated arguments passed to the enrichment function 
#' 
#' @param envir The environment in which the original call was evaluated
#' 
#' @return A list containing annotation metadata(organism, gene set database and 
#' its version), depending on the originating package. It returns an empty
#' metadata structure if no package-specific method is available
#'
#' @noRd
EMMA_get_metadata <- function(call_class,
                              args,
                              envir = parent.frame()) {
  info_call <- call_class$info_call
  function_name <- info_call$function_name
  package_name <- info_call$package_name
  call <- info_call$call
  
  meta <- EMMA_empty_metadata()
  
  if (is.null(package_name) || is.na(package_name) || package_name == "") {
    package_name <- "custom"
  }
  
  meta <- switch(
    package_name,
    clusterProfiler = EMMA_get_clusterprofiler_metadata(function_name, args),
    gprofiler2      = EMMA_get_gprofiler2_metadata(args),
    mosdef          = EMMA_cp_GO_metadata(args$mapping),
    custom          = EMMA_get_custom_metadata(call_class,
                                               args,
                                               envir = parent.frame())
  )
  
  return(meta)
  
}

#' This function retrieves metadata associated with FEAs performed using
#' functions from the `clusterProfiler` package. The specific metadata
#' extraction method is selected based on the enrichment function used
#' 
#' @param function_name A character string specifying the name of the
#' `clusterProfiler` function used to perform FEA
#'
#' @param args A list containing the evaluated arguments passed into the
#' function call to perform FEA 
#' 
#' @return A list containing annotation metadata (organism, gene set database
#' and its version), depending on the underlying database used (e.g. GO vs KEGG)
#'
#' @noRd
EMMA_get_clusterprofiler_metadata <- function(function_name, args) {
  switch(
    function_name,
    enrichGO   = EMMA_cp_GO_metadata(args$OrgDb),
    gseGO = EMMA_cp_GO_metadata(args$OrgDb),
    groupGO = EMMA_cp_GO_metadata(args$OrgDb),
    enrichKEGG = EMMA_cp_KEGG_metadata(args),
    gseKEGG = EMMA_cp_KEGG_metadata(args),
    EMMA_empty_metadata()
    # more to be added
  )
}

#' This function extracts the organism from OrgDb objects
#' 
#' @param orgdb An `OrgDb` object or a single character string giving the name
#' of such an object (e.g. `"org.Hs.eg.db"`)
#' 
#' @return A character string containing the organism name (e.g. `"Homo sapiens"`)
#' and returns `NA_character_` if the organism cannot be determined
#'
#' @noRd
EMMA_get_organism_from_OrgDb <- function(orgdb) {
  
  if (is.null(orgdb)) {
    return(NA_character_)
  }
  
  if (is.character(orgdb) && length(orgdb) == 1) {
    if (!exists(orgdb, mode = "S4")) {
      stop(orgdb,
           " was provided as a string, but no loaded object with that name was found. ", 
           "Please load the corresponding org.*.db library")
    }
    orgdb <- get(orgdb)
  }
  
  md <- AnnotationDbi::metadata(orgdb)
  organism <- md$value[md$name == "ORGANISM"]
  
  if (length(organism) != 1L) {
    return(NA_character_)
  }
  return(organism)
}


#' This function assembles standardized metadata describing GO enrichment
#' analyses performed with `clusterProfiler`. The metadata includes the
#' organism, the geneset database used, and its version when available
#' 
#' @param org An `OrgDb` object or a single character string giving the name of
#' such an object (e.g. `"org.Hs.eg.db"`)
#' 
#' @return A named list containing annotation metadata, mainly the organism, the
#' geneset database and its version
#'
#' @noRd
EMMA_cp_GO_metadata <- function(org) {
  meta <- EMMA_empty_metadata()
  
  meta$organism <- EMMA_get_organism_from_OrgDb(org)
  meta$gene_set_db <- "GO"
  meta$gene_set_db_version <- if (requireNamespace("GO.db", quietly = TRUE)) {
    as.character(utils::packageVersion("GO.db"))
  } else {
    NA_character_
  }
  
  return(meta)
}


### not tested yet since the kegg server is down and the function couldn't work

#' This function assembles standardized metadata describing KEGG enrichment
#' analyses performed with `clusterProfiler`. The metadata includes the
#' organism, the geneset database used. The database version is currently not
#' captured
#' 
#' @param args A list containing the evaluated arguments passed into the
#' function call to perform FEA 
#' 
#' @return A named list containing annotation metadata, mainly the organism, the
#' geneset database and its version
#'
#' @noRd
EMMA_cp_KEGG_metadata <- function(args) {
  meta <- EMMA_empty_metadata()
  
  meta$organism <- args$organism
  meta$gene_set_db <- "KEGG"
  meta$gene_set_db_version <- NA_character_
  
  return(meta)
}


#' This function retrieves metadata associated with FEAs performed using
#' functions from the `gprofiler2` package
#' 
#' @param args A list containing the evaluated arguments passed into the
#' function call to perform FEA
#' 
#' @return A named list containing annotation metadata, mainly the organism, the
#' geneset database and its version
#'
#' @noRd
EMMA_get_gprofiler2_metadata <- function(args) {
  meta <- EMMA_empty_metadata()
  
  version_info <- gprofiler2::get_version_info()
  
  meta$organism <- if (!is.null(args$organism)) args$organism else NA_character_
  
  sources_used <- if (!is.null(args$sources)) {
    args$sources
  } else {
    names(version_info[["sources"]])
  } 
  
  # in case the source is GO, we extract all the dbs ...
  if ("GO" %in% sources_used) {
    sources_used <- unique(c(
      setdiff(sources_used, "GO"),
      "GO:BP", "GO:CC", "GO:MF"
    ))
  }
  
  meta$gene_set_db <- sources_used
  
  meta$gene_set_db_version <- vapply(
    version_info[["sources"]][sources_used], function(x) x[["version"]],
    character(1)
  ) # needs more work when only GO, no need to print 3 times the same version
  # also, differentiate between which version corresponds to which db

  return(meta)
}


#' 
#' @noRd
EMMA_get_custom_metadata <- function(call_class, args,
                                     envir = parent.frame()) {
  
  meta <- EMMA_empty_metadata()
  
  if (call_class$type == "wrapper") {
    # get all known functions used in the wrapper
    wrapped_fun <- unique(call_class$wrapped_original$fun)
    
    go_funs <- c("enrichGO", "gseGO", "groupGO")
    kegg_funs <- c("enrichKEGG", "gseKEGG")
    # dont use EMMA_get_clusterprofiler_metadata cause the switch wont work with
    # more than 1 wrapped fun
    meta_list <- list()
    if (any(wrapped_fun %in% go_funs)) {
      meta_list$GO <- EMMA_cp_GO_metadata(args$OrgDb)
    }
    
    if (any(wrapped_fun %in% kegg_funs)) {
      meta_list$KEGG <- EMMA_cp_KEGG_metadata(args)
    }
    
    if (any(wrapped_fun %in% c("gost"))) {
      meta_list$gprofiler2 <- EMMA_get_gprofiler2_metadata(args)
    }
    
    if (length(meta_list) == 0L) {
      return(meta)
    }
    
    meta$organism <- unique(unlist(lapply(meta_list, `[[`, "organism")))
    meta$gene_set_db <- unique(unlist(lapply(meta_list, `[[`, "gene_set_db")))
    meta$gene_set_db_version <- unique(unlist(lapply(meta_list, `[[`, "gene_set_db_version")))
    
    return(meta)

  }
  
  if (call_class$type == "custom") {
    # if 100% custom
    message("You used a custom function, so `EMMA` wasn't able to record annotation-",
            "related information. Please consider adding the `organism`, `geneset database`",
            " and its `version` manually into the `extra` field in EMMA_record.")
    return(meta)
  }
  
  return(meta)
}



# call info capture -----------------------------------------------------------------

#' This function extracts call related metadata. It handles two call
#' formats: bare function calls (e.g. `fun(...)`) and namespace-qualified
#' calls (e.g. `pkg::fun(...)`)
#'
#' @param call A call object
#' @param envir The environment in which to look up the function when a bare
#' call is used
#'
#' @return A named list
#' @noRd
EMMA_capture_call_info <- function(call, envir = parent.frame()) {
  # param checks
  if (!is.call(call)) {
    stop("`call` must be a function call", call. = FALSE)
  }
  # capture function name
  call_name <- call[[1]]
  # when we only use function name e.g. enrichGO(...)
  if (is.symbol(call_name)) {
    function_name <- as.character(call_name)
    
    fun <- get(function_name, envir = envir, mode = "function")
    
    pkg <- utils::packageName(environment(fun))
    
    package_name <- if (is.null(pkg) || pkg == "" ) NA_character_ else pkg
    
    pkg_version <- if (!is.na(package_name)) {
      as.character(packageVersion(package_name))}
    
    else NA_character_
    
    # capture args (unevaluated)
    arg_list <- as.list(call)[-1]

    return(list(
      call = call,
      function_name = function_name,
      package_name = package_name,
      package_version = pkg_version,
      arg_list = arg_list
    ))
  }
  
  # when we use function name with namespace e.g. clusterProfiler::enrichGO(...)
  if (is.call(call_name) &&
      length(call_name) == 3L &&
      identical(call_name[[1]], as.symbol("::"))) {
    package_name <- as.character(call_name[[2]])
    function_name <- as.character(call_name[[3]])
    pkg_version <- if (!is.na(package_name)) {
      as.character(utils::packageVersion(package_name))
    } else {
      NA_character_
    }
    # capture args (unevaluated)
    arg_list <- as.list(call)[-1]
    
    return(list(
      call = call,
      function_name = function_name,
      package_name = package_name,
      package_version = pkg_version,
      arg_list = arg_list
    ))
  }
  
  stop(
    "Unsupported call format. Use a direct function call like `fun(...)` or `pkg::fun(...)`",
    call. = FALSE)
}


#' This function, used in in `EMMA_walk()`, converts the head of a call into a character
#' string representing the function being called. It supports both bare calls
#' (e.g. `fun`) and namespace-qualified calls (e.g. `pkg::fun`)
#'
#' @param x The head of a call (the function being called)
#' 
#' @return A character string representing the function name
#'
#' @noRd
EMMA_call_name <- function(x) {
  if (is.symbol(x)) {
    return(as.character(x))
  }
  if (
    is.call(x) &&
    identical(x[[1]], as.name("::")) &&
    length(x) == 3
  ) {
    return(paste0(as.character(x[[2]]), "::", as.character(x[[3]])))
  }
  NULL
}


#' This function recursively collects function names/operators from a call. It
#' is used to inspect the body of a wrapper function and to identify whether it
#' calls any known functional enrichment functions (e.g. `enrichGO()`)
#' 
#' @param x A call object
#' 
#' @return A character vector containing the names of all functions and 
#' operators found in `x`, including nested calls
#' 
#' @noRd
EMMA_walk <- function(x) {
  out <- character()
  
  if (is.call(x)) {
    # extract function/operator name
    nm <- EMMA_call_name(x[[1]])
    if (!is.null(nm)) {
      out <- c(out, nm)
    }
    
  }
  if (is.call(x) || is.pairlist(x) || is.expression(x)) {
    #check children/nested elements
    for (i in seq_along(x)) {
      out <- c(out, EMMA_walk(x[[i]]))
    }
  }
  
  return(out)
}


#' This function inspects the body of a function call and determines whether
#' it wraps one or more known FEA functions (e.g. from `clusterProfiler` or
#' any other package). This is used internally by `EMMA_run()` when the top-level
#' call is not itself a known enrichment function, but may be a user-defined
#' wrapper around one
#'
#' @param call An unevaluated call
#' @param envir An environment in which to evaluate `call`
#'
#' @return `NULL` if no known enrichment function is detected in the wrapper body.
#' Otherwise, a list with two components: `pkg`, a character vector of package
#' names, and `fun`, character vector of corresponding function names used in the
#' wrapper
#' 
#' @noRd
EMMA_find_original_wrapped_fun <- function(call, envir = parent.frame()) {
  
  if (!is.call(call)) {
    # do i want it to fail here ?
    return(NULL)
  }
  
  available <- list(
    clusterProfiler = c("enrichGO", "gseGO", "groupGO", "enrichKEGG", "gseKEGG"),
    gprofiler2 = c("gost"),
    goseq = c("goseq"),
    mosdef = c("run_topGO", "run_cluPro", "run_goseq"),
    topGO = c("runTest")
    # will add more later here
  )
  
  # flatten available into full names
  full_targets <- mapply(function(pkg, funs){
    paste0(pkg, "::", funs)}, 
    names(available), #pkg
    available, #funs
    SIMPLIFY = FALSE) |>  unlist(use.names = FALSE)
  
  # get wrapper name
  call_head <- call[[1]]
  
  # get function object, from which we'll extract the body
  # if we have a bare wrapper name
  if (is.symbol(call_head)) {
    fun <- get(as.character(call_head), envir = envir, mode = "function")
  }
  # if the wrapper is namespace qualified function name,
  # extract the fun name to get the body
  else if (is.call(call_head) &&
      length(call_head) == 3L &&
      identical(call_head[[1]], as.symbol("::"))) {
    pkg <- as.character(call_head[[2]])
    fn  <- as.character(call_head[[3]])
    fun <- getExportedValue(pkg, fn)
  } else {
    stop(
      "Only `fun(...)` and `pkg::fun(...)` are supported",
      call. = FALSE
    )
  }
  
  
  found <- EMMA_walk(body(fun)) |> unique()
  
  matched <- unique(c(
    intersect(found, full_targets),
    #remove the pkg name (what s before ::)
    full_targets[sub("^.*::", "", full_targets) %in% found]
  ))
  
  if (length(matched) == 0) {
    return(NULL)
  }
  
  parts <- strsplit(matched, "::", fixed = TRUE)

  return(list(
    pkg = vapply(parts, `[`, character(1), 1),
    fun = vapply(parts, `[`, character(1), 2)
  ))
}


#' decide if top-level function passed to EMMA_run is a known fun or a wrapper
#'
#' @noRd
EMMA_classify_call <- function(call, envir = parent.frame()) {
  # listing all the functions that are not wrappers
  originals <- list(
    clusterProfiler = c("enrichGO", "gseGO", "groupGO", "enrichKEGG", "gseKEGG"),
    gprofiler2 = c("gost"),
    goseq = c("goseq"),
    topGO = c("runTest")
  )
  
  full_originals <- mapply( function(pkg, funs) paste0(pkg, "::", funs),
                            names(originals),
                            originals,
                            SIMPLIFY = FALSE) |> unlist(use.names = FALSE)
  
  # capture call information
  info_call <- EMMA_capture_call_info(call = call, envir = envir)
  function_name <- info_call$function_name
  package_name <- info_call$package_name
  
  top_name <- if (!is.na(package_name) && !is.null(package_name)
                  && package_name != "" && length(package_name) == 1L) {
    paste0(package_name, "::", function_name)
  } else {
    function_name
  }
  
  is_original_top_level <- if (!is.na(package_name) && !is.null(package_name)
                               && package_name != "" && length(package_name) == 1L) {
    paste0(package_name, "::", function_name) %in% full_originals
  } else {
    function_name %in% sub("^.*::", "", full_originals)
  }
  
  wrapped_original <- NULL
  wrapper <- FALSE # default
  
  if (!is_original_top_level) {
    # inspect body of expr function, because this could be a wrapper
    wrapped_original <- EMMA_find_original_wrapped_fun(call = call,
                                                       envir = envir)
    wrapper <- !is.null(wrapped_original)
  }
  
  type <- if (is_original_top_level) {
    "original"
  } else if (wrapper) {
    "wrapper"
  } else {
    "custom"
  }
  
  return(list(
    type = type,
    is_original_top_level = is_original_top_level,
    wrapper = wrapper,
    wrapped_original = wrapped_original,
    info_call = info_call
  ))
  
}


# build EMMA record ------------------------------------------------------------


#' This function assembles the structured provenance record that is stored as
#' an attribute on the FEA results object
#' 
#' @param info_call A list returned by `EMMA_capture_call_info()`
#' @param args_form A character string, either `"evaluated"` or `"unevaluated"`
#' to decide how to store the arguments
#' @param metadata A list returned by `EMMA_get_metadata()`
#' @param start_time A timestamp marking when the enrichment analysis started
#' @param session Logical. If `TRUE`, `sessionInfo()` is captured and stored in
#' the record; if `FALSE` the `session_info` slot is `NULL`
#'  
#' @return A named list of the recorded metadata
#'   
#' @noRd
EMMA_build_record <- function(info_call, args_form, metadata,
                              wrapped_original, wrapper,
                              start_time, session) {
  emma_rec <- list(
                   method = list(
                     call = info_call$call,
                     function_name = info_call$function_name,
                     package_name = info_call$package_name,
                     package_version = info_call$package_version,
                     wrapped_function = if (!is.null(wrapped_original)) 
                       wrapped_original$fun else NULL,
                     wrapped_package = if (!is.null(wrapped_original)) 
                       wrapped_original$pkg else NULL,
                     wrapper = wrapper
                   ),
                   input = list(
                     arguments = if (args_form == "evaluated") info_call$args 
                     else info_call$arg_list
                   ),
                   annotation = list(
                     organism = metadata$organism,
                     gene_set_db = metadata$gene_set_db,
                     gene_set_db_version = metadata$gene_set_db_version
                   ),
                   timestamp = start_time,
                   session_info = if (isTRUE(session)) sessionInfo() else NULL,
                   extra = list(),# free field for extra metadata (added by user)
                   emma_version = as.character(packageVersion(pkg = "EMMA"))
                   )
  
  return(emma_rec)
  
}

# good practice warnings -------------------------------------------------------


#' This function warns about missing good-practice arguments in enrichment calls.
#' A warning is raised if none of the synonyms for a given category appear
#' in `arg_names`
#' 
#' @param arg_names A character vector of argument names as written in the
#' user's call, obtained within `EMMA_run()`
#' @param function_name A character corresponding to the name of the enrichment
#' function called, used only for constructing the warning message
#' 
#' @return `base::invisible()`
#' @noRd
EMMA_warnings <- function(arg_names, function_name){
  checks <- list(
    list(
      params = c("pAdjustMethod", "correction_method", "do_padj"),
      label  = "multiple-testing correction method"
    ),
    list(
      params = c("universe", "background", "custom_bg", "bg_genes"),
      label  = "background gene set"
    )
  )
  
  for (check in checks) {
    if (!any(check$params %in% arg_names)) {
      warning(
        sprintf(
          "No %s was specified for %s().
Consider using the corresponding parameter for your call.",
          check$label,
          function_name
        ),
        call. = FALSE
      )
    }
  }
  invisible()
}


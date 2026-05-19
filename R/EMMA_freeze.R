#' EMMA_freeze
#'
#' This function records the R environment during analysis runtime and generates
#' a lockfile that can be used with tools such as `renv`.
#' By default, all currently loaded namespaces are recorded.
#'
#' @param project Character string corresponding to the path to the project
#' directory where the lockfile should be written. If the directory does not
#' exist, it will be created. It defaults to the current working directory
#' @param file Character string referring to the name of the lockfile to generate.
#' It defaults to "renv.lock"
#' @param pkgs Character vector of package names to snapshot. It defaults to all
#' currently loaded namespaces via `loadedNamespaces()`
#' @param prompt Logical indicating whether to prompt before taking actions.
#' Defaults to `interactive()`
#' @param force Logical indicating whether to force creation of the lockfile.
#' Defaults to `TRUE`
#' 
#' @details
#' This function calls `renv::snapshot()` with the specified packages.
#' The resulting lockfile can later be restored with `renv::restore()` to
#' recreate the same package environment.
#' 
#' By default, the lockfile is created with `force = TRUE`, allowing snapshot
#' creation even if inconsistencies are detected in the environment.
#' 
#' @returns Invisibly returns the path to the generated lockfile.
#' The lockfile is written in JSON format and can be used with `renv::restore()`
#' to recreate the package environment
#' 
#' @seealso \code{\link[renv]{snapshot}}, \code{\link[renv]{restore}}
#'
#' @export
#'
#' @examples
#' # create a lockfile
#' if (requireNamespace("renv", quietly = TRUE)) {
#' tmp <- tempfile("emma_env")
#' dir.create(tmp)
#'
#' EMMA_freeze(project = tmp)
#' 
#' # inspect generated files
#' list.files(tmp)
#'
#' # to restore the environment later
#' # renv::restore(project = tmp)
#' }
EMMA_freeze <- function(project = getwd(),
                        file = "renv.lock",
                        pkgs = loadedNamespaces(),
                        prompt = interactive(),
                        force = TRUE){
  
  # when using EMMA_freeze, we only need renv loaded (without attaching)
  # to avoid extra heavy dependency.
  if (!requireNamespace("renv", quietly = TRUE)) {
    stop(
      "The 'renv' package is required for EMMA_freeze(). Please install it."
    )
  }
  
  # checks on args
  if (!is.character(project) || length(project) != 1L || is.na(project)) {
    stop("`project` must be a single character string.")
  }
  
  if (!is.character(file) || length(file) != 1L || is.na(file)) {
    stop("`file` must be a single character string.")
  }
  
  if (!is.character(pkgs)) {
    stop("`pkgs` must be a character vector of package names.")
  }
  
  if (!is.logical(prompt) || length(prompt) != 1L || is.na(prompt)) {
    stop("`prompt` must be TRUE or FALSE.")
  }
  
  if (!is.logical(force) || length(force) != 1L || is.na(force)) {
    stop("`force` must be TRUE or FALSE.")
  }
  
  
  # create project dir if needed
  if (!dir.exists(project)) {
    dir.create(project, recursive = TRUE)
  } 
  
  lockfile <- file.path(project, file)
  
  prompt <- isTRUE(prompt) # if interactive it s TRUE, else takes what the user passes
  
  # no prompt in non interactive sessions
  if (!interactive()) {
    prompt <- FALSE
  }
  
  ##### snapshot environment
  renv::snapshot(
    project = project,
    lockfile = lockfile,
    packages = pkgs,
    prompt = prompt,
    force = force
  )

  cli::cli_alert_info(
    "Environment snapshot saved to: {.val {lockfile}}. \nTo recreate this environment, use `renv::restore()`.")
  
  invisible(lockfile)

}

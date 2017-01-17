##
# usePackages
# Team Maja - Simon Veen & Gijs Peters
# 17-01-17

##
#' @title usePackages
#' @author Team Maja - Simon Veen & Gijs Peters
#' @description Loads multiple libraries, and installs them if required.
#' @param ... The packages to load
#' @param stopOnError Whether the program should fail upon error. True by default.
#' @return A boolean value indicating if the packages have loaded correctly
usePackages <- function(..., stopOnError=T) {
  packages <- c(...)
  success <- T
  for (p in packages) {
    evals <- paste0("success && (require(", p, ") || (is.null(install.packages('", p, "'))))")
    success <- eval(parse(text=evals))
    eval(parse(text=paste0("require(", p, ")")))
    if (!success && stopOnError) {
      stop(paste("Failed to load package", p))
    }
  }
  invisible(success)
}
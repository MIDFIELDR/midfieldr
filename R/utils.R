#' Pipe operator
#'
#' @name %>%
#' @rdname pipe
#' @keywords internal
#' @export
#' @importFrom magrittr %>%
#' @usage lhs \%>\% rhs
NULL




# adapted from
# G. Brooke Anderson and Dirk Eddelbuettel
# The R Journal (2017) 9:1, pages 486-497
# https://journal.r-project.org/archive/2017/RJ-2017-026/index.html

.pkgglobalenv <- new.env(parent = emptyenv())

.onAttach <- function(libname, pkgname) {
	has_data_package <- requireNamespace("midfielddata")
	if(!has_data_package){
		packageStartupMessage(paste("To use this package, you must install the",
																"midfielddata package."))
		packageStartupMessage(paste("To install that package, run",
																"`install.packages('midfielddata',",
																"repos = 'https://midfieldr.github.io/drat/',",
																"type = 'source')`."))
		packageStartupMessage("See the `midfielddata` vignette for more details.")
	}
	assign("has_data", has_data_package, envir = .pkgglobalenv)
}

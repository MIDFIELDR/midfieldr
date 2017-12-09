#' @importFrom magrittr %>%
#' @importFrom tidyr unite
NULL

#' Unite ethnicity and sex variables
#'
#' Creates a character variable \code{PEER_GROUP} by uniting the characters in the \code{ETHNIC} and \code{SEX} variables.
#'
#' @param x A data frame with at least two character variables \code{ETHNIC} and \code{SEX}.
#'
#' @return A data frame with a new variable \code{PEER_GROUP}. Other variables in the data frame are returned unaffected.
#'
#' @export
unite_ethnicity_sex <- function(x){

	stopifnot(is.data.frame(x))
	stopifnot("ETHNIC" %in% names(x))
	stopifnot("SEX"    %in% names(x))

	# unite ethnicity and sex in new peer group variable
	x <- x %>%
		unite(PEER_GROUP, c(ETHNIC, SEX), sep = " ", remove = FALSE)

	return(x)
}
"unite_ethnicity_sex"

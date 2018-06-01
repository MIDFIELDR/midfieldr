#' @importFrom dplyr select quos left_join mutate_if funs
#' @importFrom magrittr %>%
#' @importFrom tidyr expand
#' @importFrom rlang syms
#' @importFrom purrr map_chr
NULL

#' Assign zero to missing combinations
#'
#' A wrapper around \code{tidyr::expand()}. Expands a data frame to include
#' all combinations of values, including those not found in the data. Replaces
#' NA in numeric columns with zero.
#'
#' @param df A data frame.
#'
#' @param ... Specification of columns to expand.
#'
#' @return The same data frame with new rows with a zero count for
#' missing combinations.
#'
#' @export
zero_fill <- function(df, ...) {
	stopifnot(is.data.frame(df))

	# obtain list of symbolic variable names to recover column order
	var_name_list <- rlang::syms(names(df))

	# convert multiple bare column names to quosures
	var_quo <- dplyr::quos(...)

	# expand the data frame, creating all combinations
	combinations <- df %>% tidyr::expand(!!!var_quo)

	# insert NA for combinations missing from the original
	df <- dplyr::left_join(combinations, df)

	# convert NA in numeric columns to a zero
	df <- df %>%
		dplyr::mutate_if(is.numeric, dplyr::funs(replace(., is.na(.), 0)))

	# recover original column order
	df <- df %>%
		dplyr::select(!!!var_name_list)
}
"zero_fill"

#' @importFrom dplyr arrange
#' @importFrom magrittr %>%
#' @importFrom tidyr spread gather
#' @importFrom rlang sym syms
#' @importFrom utils head tail
NULL

#' Insert a count of zero for missing combinations of categorical variables.
#'
#' Counts the number of students grouped by all the variables in \code{df}. The count is assigned the variable name in \code{count_label}. If the variables \code{sex}, \code{race}, or \code{institution} are present, the function fills a zero for a missing count at every intersection of these variables.
#'
#' @param df A tidy data frame with any number of character variables and only one numerical variable.
#'
#' @return The same data frame with new rows with a zero count for missing combinations.
#'
#' @export
zero_fill <- function(df) {
	# for gather() and spread() key-value pairs, the "key" is any
	# character variable and the "value" is the single numerical variable

	# must be a df
	stopifnot(is.data.frame(df))
	# obtain type of variables to distinguish character fron numeirc
	var_types <- sapply(df, typeof)
	# obtain list of symbolic variable names to recover column order
	var_name_list <- rlang::syms(names(df))

	# must have only one numerical count value
	value_idx <- var_types[var_types == "double" | var_types == "integer"]
	value_len <- max(seq_along(value_idx))
	stopifnot(value_len == 1)

	# must have at least two character variables for spread/gather
	key_idx <- var_types[var_types == "character"]
	key_len <- max(seq_along(key_idx))
	stopifnot(key_len >= 2)

	# acquire the names for the "key-value" pair
	key_names  <- names(key_idx)
	value_name <- names(value_idx)

	# select the "key" and "value" variables for spread() and gather()
	key   <- rlang::sym(key_names[[1]])
	value <- rlang::sym(value_name[[1]])

	# obtain the first and last value of the key for gathering
	df <- df %>% dplyr::arrange(!!key)
	key_level_1 <- utils::head(unique(df[[key]]), n = 1)
	key_level_n <- utils::tail(unique(df[[key]]), n = 1)

	# spread, creates NA for missing combinations, fill NA with zero, and gather
	df <- df %>%
		tidyr::spread(!!key, !!value, fill = 0) %>%
		tidyr::gather(!!key, !!value, key_level_1:key_level_n) %>%
		select(!!!var_name_list)
}
"zero_fill"

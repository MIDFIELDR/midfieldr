#' @importFrom dplyr group_by summarize left_join mutate select
#' @importFrom dplyr ungroup quo_name arrange
#' @importFrom magrittr %>%
#' @importFrom purrr map_chr
#' @importFrom forcats fct_reorder
#' @importFrom rlang sym :=
#' @importFrom stats median
#' @importFrom tibble data_frame
NULL

#' Prepare multiway data for graphing
#'
#' Transforms a data frame such that two categorical variables become factors
#' with their levels ordered by medians of the quantitative variable.
#'
#' In multiway data, there is a single quantitative value (or response) for
#' every combination of levels of two categorical variables.
#' \code{multiway_order()} converts the categorical variables to factors and
#' orders the factors by increasing median values of the levels of the
#' categorical variables.
#'
#' @param x A data frame with one numerical variable and two categorical
#' variables.
#'
#' @param medians A logical value indicating whether or not the medians
#' computed to order the factors should be included in the data frame
#' returned. The default is FALSE.
#'
#' @return A data frame with its two categorical variables converted
#' to factors and ordered by increasing medians of the numerical variable. The
#' medians of the quantitative variable for each category are added to the
#' data frame if argument \code{medians} is TRUE.
#'
#' @examples
#' # construct a data frame with one numeric and two character variables
#' set.seed(20150531)
#' cat1 <- rep(c("Art", "History", "Math"), each = 2)
#' cat2 <- rep(c("Male", "Female"), times = 3)
#' x    <- round(runif(6, min = 0.1, max = 0.7), 3)
#' df1  <- tibble::data_frame(cat1, cat2, x)
#' df1
#'
#' # convert characters to factors ordered by medians
#' df2 <- multiway_order(df1)
#' df2 <- dplyr::arrange(df2, cat1, cat2)
#' df2
#'
#' # include the medians in the output
#' df3 <- multiway_order(df1, medians = TRUE)
#' df3 <- dplyr::arrange(df3, cat1, cat2)
#' df3
#'
#' @export
multiway_order <- function(x, medians = FALSE) {
	stopifnot(is.data.frame(x))
	if(is.null(medians)) medians <- FALSE

	# obtain type of variables to distinguish numeric from other
	v_class <- purrr::map_chr(x, class)

	# only one numeric value
	sel <- v_class == "numeric" | v_class == "integer" | v_class == "double"
	value_idx <- v_class[sel]
	value_len <- max(seq_along(value_idx))
	stopifnot(exprs = {
		value_len == 1
	})

	# two categorical variables, either character or factor
	cat_idx <- v_class[v_class == "character" | v_class == "factor"]
	cat_len <- max(seq_along(cat_idx))
	stopifnot(exprs = {
		cat_len == 2
	})

	# names of the 3 variables as symbols
	# are used in grouping, summarizing, and joining
	cat1  <- rlang::sym(names(cat_idx)[[1]])
	cat2  <- rlang::sym(names(cat_idx)[[2]])
	value <- rlang::sym(names(value_idx)[[1]])

	# construct names for the median variables
	med1  <- rlang::sym(paste0("med_", names(cat_idx)[[1]]))
	med2  <- rlang::sym(paste0("med_", names(cat_idx)[[2]]))

	# determine medians grouped by first category
	y <- x %>%
		dplyr::group_by(!!cat1) %>%
		dplyr::summarize(!!med1 := round(median(!!value, na.rm = TRUE), 3)) %>%
		dplyr::ungroup()
	# create first factor and order by the median values
	x <- dplyr::left_join(x, y, by = dplyr::quo_name(cat1)) %>%
		dplyr::mutate(!!cat1 := forcats::fct_reorder(!!cat1, !!med1))

	# determine medians grouped by second category
	y <- x %>%
		dplyr::group_by(!!cat2) %>%
		dplyr::summarize(!!med2 := round(median(!!value, na.rm = TRUE), 3))
	# create second factor and order by the median values
	x <- dplyr::left_join(x, y, by = dplyr::quo_name(cat2)) %>%
		dplyr::mutate(!!cat2 := forcats::fct_reorder(!!cat2, !!med2))

	# conditional to include the medians in the output
	if (medians) {
		x <- x
	} else {
		x <- x %>% select(!!cat1, !!cat2, !!value)
	}
}
"multiway_order"

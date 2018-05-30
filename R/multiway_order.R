#' @importFrom dplyr group_by summarize left_join mutate select
#' @importFrom dplyr ungroup quo_name
#' @importFrom magrittr %>%
#' @importFrom purrr map_chr
#' @importFrom forcats fct_reorder
#' @importFrom rlang sym :=
#' @importFrom stats median
NULL

#' Multiway order
#'
#' Prepare multiway data for graphing.
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
#' @return A data frame with its two categorical variables converted
#' to factors and ordered by increasing medians of the numerical variable.
#'
#' @export
multiway_order <- function(x) {
  stopifnot(is.data.frame(x))

  # obtain type of variables to distinguish numeric from other
  var_class <- purrr::map_chr(x, class)

  # must have only three variables
  var_len <- max(seq_along(var_class))
  stopifnot(exprs = {
    var_len == 3
  })

  # only one numeric value
  value_idx <- var_class[var_class == "numeric"]
  value_len <- max(seq_along(value_idx))
  stopifnot(exprs = {
    value_len == 1
  })

  # two categorical variables, either character or factor
  cat_idx <- var_class[var_class == "character" | var_class == "factor"]
  cat_len <- max(seq_along(cat_idx))
  stopifnot(exprs = {
    cat_len == 2
  })

  # names of the 3 variables as symbols
  # are used in grouping, summarizing, and joining
  cat1  <- rlang::sym(names(cat_idx)[[1]])
  cat2  <- rlang::sym(names(cat_idx)[[2]])
  value <- rlang::sym(names(value_idx)[[1]])

  # determine medians grouped by first category
  medians <- x %>%
    dplyr::group_by(!!cat1) %>%
    dplyr::summarize(med1 = median(!!value, na.rm = TRUE)) %>%
    dplyr::ungroup()
  # create first factor and order by the median values
  x <- dplyr::left_join(x, medians, by = dplyr::quo_name(cat1)) %>%
    dplyr::mutate(!!cat1 := forcats::fct_reorder(!!cat1, med1))

  # determine medians grouped by second category
  medians <- x %>%
    dplyr::group_by(!!cat2) %>%
    dplyr::summarize(med2 = median(!!value, na.rm = TRUE))
  # create second factor and order by the median values
  x <- dplyr::left_join(x, medians, by = dplyr::quo_name(cat2)) %>%
    dplyr::mutate(!!cat2 := forcats::fct_reorder(!!cat2, med2))
}
"multiway_order"

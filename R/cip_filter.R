#' @importFrom plyr ldply
#' @importFrom dplyr filter arrange bind_rows group_by ungroup row_number
#' @importFrom magrittr %>%
#' @importFrom stringr str_length str_c str_detect
#' @importFrom tibble as_tibble
#' @importFrom dplyr enquo select
NULL

#' Filter CIP data
#'
#' Filter a data frame of Classification of Instructional Programs (CIP) codes
#' to return the rows that match conditions.
#'
#' The purpose of \code{cip_filter()} is to obtain the CIP codes of specific
#' programs and use the results to obtain the records of students in those
#' programs.
#'
#' @param series The conditions used to filter the data. A character vector
#' (or coercible to one) of any combination of 2, 4, or 6-digit CIP codes.
#' If NULL, \code{data} is returned unchanged.
#'
#' @param data A data frame of character variables (or coercible to one).
#' Required variables are \code{CIP2}, \code{CIP4}, and \code{CIP6}. If NULL,
#' \code{data} is the midfieldr \code{cip} dataset.
#'
#' @return A data frame: \code{data} filtered by the conditions in \code{series}.
#'
#' @examples
#' cip_filter(series = c("490101", "490205"))
#' cip_filter(series = c("^4901", "^4902"))
#' cip_filter(series = c("^49", "^99"))
#' cip_filter(series = c("^54", "^4901", "490205"))
#' cip_filter(series = seq(540102, 540108))
#'
#' @export
cip_filter <- function(series = NULL, data = NULL) {
  # default cip data set, else coerce to characters
  if (is.null(data)) {
    data <- midfieldr::cip
  } else {
    stopifnot(is.data.frame(data))
  }

  if (is.null(series)) {
    # default series is the 2-digit main entries
    cip <- data %>%
      arrange(CIP6) %>%
      group_by(CIP2) %>%
      filter(row_number(CIP2) == 1) %>% # again, keep the first term
      ungroup()
  } else {
    # coerce series to character
    series <- as.character(series)
    collapse_series <- str_c(series, collapse = "|")

    # search each column for strings in collapse_series
    cip <- plyr::ldply(names(data), function(x)
      paste0("filter(data, str_detect(data$", x, ", collapse_series))") %>%
        parse(text = .) %>%
        eval())
  }

  # omit duplicates (if any) and arrange in order of CIP
  cip <- unique(cip) %>%
    arrange(CIP2, CIP4, CIP6)

  cip <- as_tibble(cip)
}

#' @importFrom tibble add_column
#' @importFrom purrr map_chr
#' @importFrom dplyr %>%
NULL

#' Add a column of program labels to a CIP data frame
#'
#' Adds a new character variable named \code{program} to a CIP data frame.
#'
#' Assigning a custom label to a program or a group of programs provides
#' the option of grouping and summarizing CIP data in ways not afforded by
#' the default program names in the 2010 CIP data.
#'
#' With \code{.data} as the first argument, \code{cip_label()} is
#' compatible with the pipe operator \code{\%>\%}.
#'
#' @param .data A filtered subset of the midfieldr \code{cip} data frame.
#'
#' @param program An optional character variable. There are four options:
#'
#' If NULL, the default, the 6-digit CIP program names are assigned to the new column.
#'
#' If NULL, but one of the named \code{cip_series} is used to create the \code{.data} argument, then the series name is assigned to the new column.
#'
#' If one of three strings ("cip2name", "cip4name", or "cip6name"), then the 2-digit, 4-digit, or 6-digit CIP program names are assigned to the new column.
#'
#' Any other string is assigned to the new column.
#'
#' @return The input data frame with an added \code{program} variable.
#'
#' @examples
#' # Extract the Philosophy and Religion programs
#' x <- cip_filter(series = "^38")
#' y <- cip_label(x, program = "test label")
#'
#' # The function is pipe-compatible
#' y <- x %>% cip_label("test label")
#'
#' # With no program argument, the 6-digit CIP names are assigned
#' y <- x %>% cip_label()
#'
#' # Argument options include
#' y <- x %>% cip_label(program = "cip6name")
#' y <- x %>% cip_label(program = "cip4name")
#' y <- x %>% cip_label(program = "cip2name")
#'
#' # When a 4-digit level name is desired
#' y <- cip_filter(series = "^1410") %>% cip_label("cip4name")
#'
#' # But if the result is too long, it can be manually reassigned
#' y <- cip_filter(series = "^1410") %>% cip_label("Electrical Engineering")
#' @export
cip_label <- function(.data, program = NULL) {

  # .data must match midfieldr cip data structure
  stopifnot(identical(
    purrr::map_chr(cip, class),
    purrr::map_chr(.data, class)
  ))

  if (is.null(program)) { # if none given
    series <- sort(.data$cip6)
    if (identical(series, sort(cip_engr))) { # if a named series
      program <- "Engineering"
    } else if (identical(series, sort(cip_bio_sci))) {
      program <- "Biological and Biomedical Sciences"
    } else if (identical(series, sort(cip_math_stat))) {
      program <- "Mathematics and Statistics"
    } else if (identical(series, sort(cip_other_stem))) {
      program <- "Other STEM"
    } else if (identical(series, sort(cip_stem))) {
      program <- "STEM"
    } else if (identical(series, sort(cip_phys_sci))) {
      program <- "Physical Sciences"
    } else { # if not named, use 6-digit names by default
      program <- .data$cip6name
    }
  } else { # program argument is given
    if (identical(program, "cip2name")) { # use CIP data names
      program <- .data$cip2name
    } else if (identical(program, "cip4name")) {
      program <- .data$cip4name
    } else if (identical(program, "cip6name")) {
      program <- .data$cip6name
    } else { # otherwise, use the input argument
      program <- program
    }
  }
  # add program name
  df <- tibble::add_column(.data, program = program)
}

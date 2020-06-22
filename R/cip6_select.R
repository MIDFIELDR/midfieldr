#' @importFrom tibble add_column
#' @importFrom purrr map_chr
#' @importFrom dplyr %>% select
#' @importFrom wrapr stop_if_dot_args let
NULL

#' Select the 6-digit CIP code and name and add a program label
#'
#' From a CIP data frame, select the columns with the 6-digit codes and names
#' and add a new character variable named \code{program}.
#'
#' The 2-digit and 4-digit codes and names are silently dropped.
#'
#'  Assigning a custom label to a program or a group of programs provides
#'  the option of grouping, summarizing, and joining data in ways not afforded
#'  by the default CIP data. We can also create program names that are
#'  less verbose than the default names.
#'
#' @param data Data frame of CIP codes and names with the same structure
#' as midfieldr \code{cip}.
#'
#' @param program Character variable. There are four options:
#'
#' If program = NULL, the default, the 4-digit CIP program names are assigned
#' to the new column.
#'
#' If program = "named_series", then the series name is assigned to the
#' new column.
#'
#' If one of three strings ("cip2name", "cip4name", or "cip6name"), then the
#' 2-digit, 4-digit, or 6-digit CIP program names are assigned to the new
#' column.
#'
#' Any other string fills the new column.
#'
#' @param ... Not used for values, forces later arguments to bind by name.
#'
#' @param cip6 Optional argument, the column name in quotes of the 6-digit
#' CIP code variable in \code{data}. Default is "cip6".
#'
#' @param cip6name Optional argument, the column name in quotes of the
#' 6-digit CIP program name variable in \code{data}. Default is "cip6name".
#'
#' @param cip4name Optional argument, the column name in quotes of the
#' 4-digit CIP program name variable in \code{data}. Default is "cip4name".
#'
#' @param cip2name Optional argument, the column name in quotes of the
#' 2-digit CIP program name variable in \code{data}. Default is "cip2name".
#'
#' @return A data frame with the 6-digit code and name columns from the
#' input data frame with an added \code{program} variable.
#'
#' @seealso \code{\link[midfieldr]{cip_filter}} for exploring CIP codes.
#'
#' @examples
#' # Extract the Philosophy and Religion programs and label
#' x <- cip_filter(cip, keep_any = "^38")
#' y <- cip6_select(x, program = "Phil-Relig")
#'
#' # With no program argument, the 6-digit CIP names are assigned
#' y <- cip6_select(x)
#'
#' # Argument options include
#' y <- cip6_select(x, program = "cip6name")
#' y <- cip6_select(x, program = "cip4name")
#' y <- cip6_select(x, program = "cip2name")
#' @export
cip6_select <- function(data, program = NULL, ..., cip6 = "cip6",
                        cip6name = "cip6name", cip4name = "cip4name",
                        cip2name = "cip2name") {

  # column class must match midfieldr cip
  stopifnot(identical(
    unname(purrr::map_chr(midfieldr::cip, class)),
    unname(purrr::map_chr(data, class))
  ))

  # force optional arguments to be usable only by name
  wrapr::stop_if_dot_args(substitute(list(...)), "cip6_select")

  # addresses R CMD check warning "no visible binding"
  CIP6 <- NULL
  CIP6NAME <- NULL
  CIP4NAME <- NULL
  CIP2NAME <- NULL

  # add program name and select 6-digit code and name
  # use wrapr::let() to allow alternate column names
  mapping <- c(
    CIP6 = cip6, CIP6NAME = cip6name, CIP4NAME = cip4name,
    CIP2NAME = cip2name
  )
  wrapr::let(
    alias = mapping,
    expr = {
      # use 4-digit names by default
      if (is.null(program) || identical(program, cip4name)) {
        program <- data[[CIP4NAME]]

        # named series
      } else if (identical(program, "named_series")) {
        series <- sort(data[[CIP6]])
        if (identical(series, sort(cip_engr))) {
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
        } else {
          # named series not recognized
          stop("cip6_select: Error in named series")
        }
      } else if (identical(program, cip2name)) {
        program <- data[[CIP2NAME]]
      } else if (identical(program, cip6name)) {
        program <- data[[CIP6NAME]]
      } else {
        # input string is used
        program <- program
      }
      data <- tibble::add_column(data, program = program) %>%
        dplyr::select(CIP6, CIP6NAME, program)
    }
  )
}
"cip6_select"

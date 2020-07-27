#' @importFrom data.table setDT setDF setattr as.data.table
NULL

#' Label programs and extract 6-digit CIP columns
#'
#' Extract two columns of a data frame and add a column of program
#' labels. The data are a subset of midfieldr \code{\link[midfieldr]{cip}} or
#' equivalent. The result is a 3-column data frame with 6-digit CIP codes,
#' 6-digit CIP names, and user-assigned program labels.
#'
#' The typical \code{data} argument is an output of \code{\link{get_cip}()}
#' with six columns: 2-digit codes and names, 4-digit codes and names, and
#' 6-digit codes and names. \code{label_programs()} retains the two 6-digit
#' columns and adds a \code{program} column for the labels. Equivalent to
#'
#' \code{data$program <- "my_chosen_label"}\cr
#' \code{data[, c("cip6", "cip6name", "program")]}
#'
#' \code{label_programs()} facilitates selecting labels suitable for
#' grouping, summarizing, and joining operations. One can assign a custom
#' label or use the 2-, 4-, or 6-digit program names in CIP. The
#' \code{label} argument has three options:
#'
#' \enumerate{
#'   \item A string (in quotes), for example \code{label = "Electrical
#'   engineering"}, places the string in every row of the new
#'   \code{program} column
#'   \item If \code{label = "cip2name"}, the labels are the 2-digit CIP
#'   program names. Argument "cip6name" produces similar results.
#'   \item If \code{label = NULL} or "cip4name", the labels are the
#'   4-digit CIP program names
#' }
#'
#' @param data data frame of CIP codes and names
#' @param label scalar character string
#'
#' @return \code{data.frame} with the following properties:
#' \itemize{
#'   \item Rows are not modified
#'   \item The 6-digit code and name columns are not modified. Other
#'    columns are dropped and a \code{program} column is added.
#'   \item Grouping structures, if any, are not preserved
#'   \item Data frame extensions \code{tbl} or \code{data.table} are preserved
#' }
#'
#' @examples
#' ece_cip <- get_cip(cip, keep_any = "^1410")
#' label_programs(ece_cip, label = "ECE")
#' label_programs(ece_cip, label = "cip2name")
#' label_programs(ece_cip, label = "cip6name")
#'
#' @family data_carpentry
#'
#' @export
#'
label_programs <- function(data = NULL, label = NULL) {

  # check arguments
  assert_explicit(data)
  assert_class(data, "data.frame")
  assert_class(label, "character")
  assert_required_column(data, "cip6")
  assert_required_column(data, "cip6name")

  if (isTRUE("program" %in% names(data))) {
    stop("`data` may not include an existing `program` column",
      call. = FALSE
    )
  }
  if (isFALSE(identical(class(data$cip6), "character")) ||
    isFALSE(identical(class(data$cip6name), "character"))) {
    stop("Columns `cip6` and `cip6name` must be character class",
      call. = FALSE
    )
  }

  # bind names
  cip6name <- NULL
  program <- NULL
  cip6 <- NULL

  # to preserve data.frame, data.table, or tibble
  dat_class <- get_df_class(data)
  DT <- data.table::as.data.table(data)

  # do the work
  if (isTRUE(is.null(label)) ||
    isTRUE(identical(label, "cip4name"))) {
    if (isFALSE(all("cip4name" %in% names(DT)))) {
      stop("Column name `cip4name` required when `label = cip4name` or NULL",
        call. = FALSE
      )
    } else if (isFALSE(identical(class(DT$cip4name), "character"))) {
      stop("Column `cip4name` must be character class",
        call. = FALSE
      )
    } else {
      # labels are 4-digit CIP names
      temp <- DT$cip4name
    }
  } else if (isTRUE(identical(label, "cip2name"))) {
    if (isFALSE(all("cip2name" %in% names(DT)))) {
      stop("Column name `cip2name` required when `label = cip2name`",
        call. = FALSE
      )
    } else if (isFALSE(identical(class(DT$cip2name), "character"))) {
      stop("Column `cip2name` must be character class",
        call. = FALSE
      )
    } else {
      # labels are 2-digit CIP names
      temp <- DT$cip2name
    }
  } else if (isTRUE(identical(label, "cip6name"))) {
    # labels are 6-digit CIP names
    temp <- DT$cip6name
  } else {
    # labels are the user-supplied string
    temp <- label
  }
  # ready to go
  DT$program <- temp
  DT <- DT[, .(cip6, cip6name, program)]

  # works by reference
  revive_class(DT, dat_class)
}

#' @importFrom data.table setDT setDF
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
#'
#' @param label scalar character string
#'
#' @return \code{data.frame} with the following properties:
#' \itemize{
#'   \item Rows are not modified
#'   \item The 6-digit code and name columns are not modified. Other
#'    columns are dropped and a \code{program} column is added.
#'   \item Grouping structures, if any, are not preserved
#'   \item Data frame extension attributes, e.g., tibble, are not preserved
#' }
#'
#' @family data_carpentry
#'
#' @examples
#' ece_cip <- get_cip(cip, keep_any = "^1410")
#' label_programs(ece_cip, label = "ECE")
#' label_programs(ece_cip, label = "cip2name")
#' label_programs(ece_cip, label = "cip6name")
#'
#' @export
label_programs <- function(data = NULL, label = NULL) {

  # check arguments
  assert_class(data, "data.frame")
  assert_class(label, "character")

  if (is.null(data)) {
    stop("Explicit `data` argument required",
         call. = FALSE
    )
  }
  if (isTRUE("program" %in% names(data))) {
    stop("`data` may not include an existing `program` column",
    call. = FALSE
    )
  }
  if (isFALSE(all(c("cip6", "cip6name") %in% names(data)))) {
    stop("`data` must include columns `cip6` and `cip6name`",
      call. = FALSE
    )
  } else {
    if (isFALSE(identical(class(data$cip6), "character")) ||
      isFALSE(identical(class(data$cip6name), "character"))) {
      stop("Columns `cip6` and `cip6name` must be character class",
      call. = FALSE
      )
    }
  }

  # bind names
  # NA

  # do the work
  data.table::setDF(data)
  if (isTRUE(is.null(label)) ||
      isTRUE(identical(label, "cip4name"))) {

    if (isFALSE(all("cip4name" %in% names(data)))) {
      stop(paste(
        "`data` must include column `cip4name`",
        "when `label` argument is `cip4name` or NULL."
      ),
      call. = FALSE
      )

    } else if (isFALSE(identical(class(data$cip4name), "character"))) {
      stop("Column `cip4name` must be character class",
      call. = FALSE
      )

    } else {
      # labels are 4-digit CIP names
      temp <- data$cip4name
    }

  } else if (isTRUE(identical(label, "cip2name"))) {

    if (isFALSE(all("cip2name" %in% names(data)))) {
      stop(paste(
        "`data` must include column `cip2name`",
        "when `label` argument is `cip2name`"
      ),
      call. = FALSE
      )

    } else if (isFALSE(identical(class(data$cip2name), "character"))) {
      stop("Column `cip2name` must be character class",
      call. = FALSE
      )

    } else {
      # labels are 2-digit CIP names
      temp <- data$cip2name
    }

  } else if (isTRUE(identical(label, "cip6name"))) {
    # labels are 6-digit CIP names
    temp <- data$cip6name

  } else {
    # labels are the user-supplied string
    temp <- label

  }
  # ready to go
  data$program <- temp



  data <- data[, c("cip6", "cip6name", "program"), drop = FALSE]
}

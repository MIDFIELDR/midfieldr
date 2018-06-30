#' @importFrom dplyr is.tbl rename select inner_join %>%
NULL

#' Gather students starting in programs
#'
#' Filters a data frame of student matriculation information (ID and starting major) to keep those starting in specified programs.
#'
#' \code{gather_start()} uses \code{dplyr::inner_join()} to combine the rows and columns of its two arguments, both data frames. All variables in the two arguments except \code{id}, \code{cip6} or \code{start} and \code{program} are quietly dropped.
#'
#' \code{gather_start()} excludes transfer students unless you set \code{transfer = TRUE}. If you are using the result to compute graduation rates per the IPEDS definition, transfer students should be omitted.
#'
#' @param .data A data frame of student matriculation information with two required character variables: student \code{id} and the \code{cip6} code for their starting major. Default is \code{midfieldstudents}.
#'
#' @param cip_group A data frame with two required character variables:  \code{cip6} or \code{start} (6-digit CIP codes) and \code{program} (program labels).
#'
#' @param transfer Logical to include (TRUE) or exclude (FALSE) transfer students. Default is FALSE.
#'
#' @return A data frame with variables \code{id} (unique MIDFIELD student ID), \code{start} (6-digit CIP code), and \code{program} (a program label).
#'
#' @examples
#' cip_group <- cip_filter(cip, series = "^54")
#' cip_group <- cip_label(cip_group, program = "cip2name")
#' starters <- gather_start(cip_group = cip_group)
#' head(starters)
#'
#' @export
gather_start <- function(.data, cip_group, transfer = FALSE) {
  if (isTRUE(missing(.data))) {
    .data <- midfielddata::midfieldstudents
  }

  if (!.pkgglobalenv$has_data) {
    stop(paste("To use this function, you must have the midfielddata package installed."))
  }
  if (isFALSE(is.data.frame(.data) || dplyr::is.tbl(.data))) {
    stop("midfieldr::gather_start() arguments must be a data frame or tbl")
  }
  if (isFALSE(is.data.frame(cip_group) || dplyr::is.tbl(cip_group))) {
    stop("midfieldr::gather_start() arguments must be a data frame or tbl")
  }
  if (isFALSE("cip6" %in% names(.data) || "start" %in% names(.data))) {
    stop("midfieldr::gather_start() data frame must include a `cip6` or 'start' variable")
  }
  if (isTRUE("cip6" %in% names(cip_group) && "start" %in% names(cip_group))) {
    stop("midfieldr::gather_start() data frame must not include both a `cip6` and 'start' variable")
  }

  # if "start" in var names, rename to "cip6"
  if (isTRUE("start" %in% names(.data))) {
    .data <- dplyr::rename(.data, cip6 = start)
  }

  # keep transfer students if transfer is TRUE
  if (isTRUE(transfer)) {
    students <- .data
  } else {
    students <- .data %>% dplyr::filter(transfer == "N")
  }

  # keep two columns from data set
  students <- students %>% dplyr::select(id, cip6)

  # keep two columns from desired program
  programs <- cip_group %>% dplyr::select(cip6)

  # inner_join() reminder
  # return all IDs that match programs in cip_group
  # return columns from both x and y
  # return all combinations of x and y
  starters <- dplyr::inner_join(students, programs, by = "cip6") %>%
    dplyr::rename(start = cip6)
}
"gather_start"

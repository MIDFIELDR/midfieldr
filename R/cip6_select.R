#' @importFrom dplyr is.tbl if_else near
NULL

#' Select 6-digit CIPs and add program labels
#'
#' From a CIP data frame, select the columns with the 6-digit codes and names
#' and add a new character variable named \code{program}.
#'
#' The 2-digit and 4-digit codes and names are silently dropped.
#'
#' Assigning a custom label to a program or a group of programs provides
#' the option of grouping, summarizing, and joining data in ways not afforded
#' by the default program names in CIP data. We can also create program names
#' that are less verbose than the default names.
#'
#' The variable names and class in \code{data} must match the variable names
#' and class in the \code{cip} data set.
#'
#' @param data Data frame or tibble with character variables for CIP codes
#' and program names, typically a filtered subset of \code{cip}.
#'
#' @param program Scalar character, that is, of length 1. There are
#' three options:
#'
#' If program is NULL, the default, the 4-digit CIP program names
#' fill the new column.
#'
#' If program is "cip2name", "cip4name", or "cip6name", the
#' 2-digit, 4-digit, or 6-digit CIP program name fills the new column.
#'
#' If program is any other string, that string fills the new column.
#'
#' @return A data frame with 6-digit CIP codes and names and the
#' assigned program label.
#' @family data_carpentry
#' @seealso \code{\link[midfieldr]{cip_filter}} for exploring CIP codes.
#'
#' @examples
#' ece <- cip_filter(cip, keep_any = "^1410")
#' cip6_select(ece, program = "ECE")
#' cip6_select(ece, program = "cip2name")
#' cip6_select(ece, program = "cip6name")
#' ece %>% cip6_select(program = "ECE")
#' ece %>% cip6_select()
#'
#' @export
cip6_select <- function(data = NULL, program = NULL){
  # argument checks
  if (is.null(data)) {
    stop(paste("cip6_select. Explicit data argument required",
               "unless passed by a pipe."),
         call. = FALSE)
  }
  if (!(is.data.frame(data) || dplyr::is.tbl(data))) {
    stop("cip6_select. Data argument must be a data frame or tbl.",
                        call. = FALSE)
  }
  if(!identical(sort(names(data)), sort(names(cip))))   {
    stop("cip6_select. Variable names in data must match names in cip.",
         call. = FALSE)
  }
  if(!identical(rep("character", 6),
                unname(unlist(lapply(data, function(x) class(x)))))){
    stop("cip6_select. Variables in data must be character class only.",
         call. = FALSE)
  }
  if(!is.null(program) &&
     !(is_atomic_character(program) &&
       dplyr::near(1, length(program)))){
    stop("cip6_select. Argument program must a scalar character or NULL.",
         call. = FALSE)
  }

  # program argument options
  if (identical(program, "cip2name")) {
    temp <- data[["cip2name"]]
  } else if (identical(program, "cip4name") || is.null(program)) {
    temp <- data[["cip4name"]]
  } else if (identical(program, "cip6name")) {
    temp <- data[["cip6name"]]
  } else {
    temp <- program
  }

  # add program variable and select the three columns
  data[["program"]] <- temp
  data <- data[, c("cip6", "cip6name", "program")]
}
"cip6_select"

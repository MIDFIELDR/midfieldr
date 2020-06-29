#' @importFrom dplyr if_else is.tbl near
#' @importFrom wrapr stop_if_dot_args
NULL

#' Filter CIP data frame
#'
#' Filter a data frame of Classification of Instructional Programs (CIP) codes
#' and return the rows that match conditions.
#'
#' The variable names and class in \code{data} must match the variable names
#' and class in the \code{cip} data set.
#'
#' The \code{keep_any} argument is an atomic character vector of search
#' terms used to filter the CIP data frame. Typical search terms include
#' words and phrases describing academic programs or their CIP codes.
#'
#' The optional \code{drop_any} argument is similar except it drops rows
#' instead of keeping them.
#'
#' Errors are produced if search terms do not exist in \code{data}. An error
#' is also produced if the filter result is empty.
#'
#' @param data Data frame or tibble with character variables for CIP codes
#' and program names. Default is \code{cip}.
#'
#' @param keep_any Character vector used to filter \code{data}, keeping all
#' rows in which any matches or partial matches are detected.
#'
#' @param ... Not used for values. Forces the subsequent optional arguments
#' to only be usable by name.
#'
#' @param drop_any Character vector, optional argument. The output of
#' the \code{keep_any} filter is the input to the \code{drop_any} filter,
#' dropping all rows in which any matches or partial matches are detected.
#'
#' @return Data frame with all columns of \code{data} and of subset of its rows.
#' @family data_carpentry
#' @examples
#' cip_filter(cip, keep_any = c("^1407", "^1410"))
#' cip_filter(cip, keep_any = "civil engineering", drop_any = "technology")
#' cip_filter(cip, keep_any = "History") %>%
#'   cip_filter(keep_any = "American")
#' \dontrun{
#' # result is empty
#' cip_filter(cip, keep_any = "engineering", drop_any = "engineering")
#' # argument doesn't exist or is misspelled
#' cip_filter(cip, keep_any = "enginerring")
#' }
#' @export
cip_filter <- function(data = NULL, keep_any = NULL, ..., drop_any = NULL) {
  # force arguments after ... to be usable only by name
  wrapr::stop_if_dot_args(
    substitute(list(...)),
    "cip_filter. Arguments after ... must be named."
  )
  # argument checks
  if (is.null(data)) {
    data <- midfieldr::cip
  }
  if (!(is.data.frame(data) || dplyr::is.tbl(data))) {
    dplyr::if_else(is_atomic_character(data),
            stop(paste("cip_filter. Explicit data argument required",
                       "unless passed by a pipe."),
                 call. = FALSE),
            stop("cip_filter. Data argument must be a data frame or tbl.",
                 call. = FALSE))
  }
  if(!identical(sort(names(data)), sort(names(cip))))   {
    stop("cip_filter. Variable names in data must match names in cip.",
         call. = FALSE)
  }
  if(!identical(rep("character", 6),
                unname(unlist(lapply(data, function(x) class(x)))))){
    stop("cip_filter. Variables in data must be character class only.",
         call. = FALSE)
  }
  if(!is.null(keep_any) && !is_atomic_character(keep_any)){
    stop("cip_filter. Argument keep_any must be an atomic character vector.",
         call. = FALSE)
  }
  if(!is.null(drop_any) && !is_atomic_character(drop_any)){
    stop("cip_filter. Argument drop_any must be an atomic character vector.",
         call. = FALSE)
  }

  # filtering to keep specific rows
  if (length(keep_any) > 0) {# NULL keep_any has length 0.
    keep_string <- paste(keep_any, collapse = "|")
    idx_to_keep <- lapply(data,
                          function(x) grep(keep_string, x, ignore.case = TRUE))
    idx <- sort(unique(unname(unlist(idx_to_keep))))
    data <- data[idx, ]
  }
  # filtering to drop specific rows
  if (length(drop_any) > 0) {# NULL drop_any has length 0.
    drop_string <- paste(drop_any, collapse = "|")
    idx_to_drop <- lapply(data,
                          function(x) grep(drop_string, x, ignore.case = TRUE))
    idx <- sort(unique(unname(unlist(idx_to_drop))))
    if (dplyr::near(sum(idx), 0)) { # search terms do not exist
      stop("cip_filter. Argument drop_any misspelled or does not exist.",
           call. = FALSE)
    } else {
      data <- data[-idx, ]
    }
  }
  if (dplyr::near(0, nrow(data))) {
    stop("cip_filter. No programs satisfy the filter criteria.",
         call. = FALSE)
  }
  return(data)
}
"cip_filter"

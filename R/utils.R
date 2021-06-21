
# internal utility functions

# ------------------------------------------------------------------------

#' Set column order and row order
#'
#' Use the vector of column names in \code{cols} as the ordering argument
#' in \code{data.table::setcolorder()} and as the key argument in
#' \code{data.table::setkeyv()} to order the rows.
#'
#' @param dframe data frame
#' @param cols character vector of column names to use as keys
#' @noRd
set_colrow_order <- function(dframe, cols) {
  on.exit(setkey(dframe, NULL))

  # ensure dframe is data.table class
  setDT(dframe)

  # column order of data frame by vector of names
  setcolorder(dframe, neworder = cols)

  # order rows by using names as keys
  setkeyv(dframe, cols = cols)
}

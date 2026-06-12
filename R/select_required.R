

#' Select required midfieldr variables
#'
#' Deprecated in favor of `select_basic_cols(dframe, patternv)`. 
#'
#' @param midfield_x Data frame
#' @param select_add Chr vector
#'
#' @rdname midfieldr_deprecated
#' @export
select_required <- function(midfield_x, select_add = NULL) {
  
  .Deprecated(
    new = "select_basic_cols",
    package = "midfieldr",
    msg = paste(
      "select_required() is deprecated.",
      "Please use select_basic_cols() instead.\n",
      'See help("deprec_midfieldr").'
    )
  )
  
  # call the new function
  select_basic_cols(dframe = midfield_x, patternv = select_add)
}

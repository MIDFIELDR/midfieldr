#' @import data.table
#' @importFrom wrapr stop_if_dot_args
NULL

#' Subset rows by matching values in a common key column
#'
#' Subset rows of one data frame by values of a key variable that match values
#' of the same key variable in a second data frame.
#'
#' Two data frames are input. The \code{match_to} data frame is subset to
#' retain its key column only.  The result is merged with \code{dframe} in an
#' inner-join, returning the rows of \code{dframe} with values matching the key
#' values in \code{match_to}.
#'
#' All columns in \code{dframe} are returned unless a subset is given in the
#' \code{select} argument. Column subsetting occurs after the inner join, so the
#' key column does not have to be included in the vector of column names in
#' \code{select}. The final operation is to subset for unique rows.
#'
#' @param dframe data frame to be subset and returned, column identified in
#'        \code{key_col} required
#' @param match_to data frame, column identified in \code{key_col} required
#' @param key_col character, name of the key column
#' @param ... not used, force later arguments to be used by name
#' @param select character vector of \code{dframe} column names to retain,
#'        default all columns
#' @return A \code{data.table} with the following properties:
#' \itemize{
#'     \item Unique rows with matching values
#'     \item All columns or those specified by \code{select}
#'     \item Grouping structures are not preserved
#' }
#' @family functions
#' @export
#' @examples
#' # TBD
filter_by_key<- function(dframe,
                         match_to,
                         key_col,
                         ...,
                         select = NULL) {

  wrapr::stop_if_dot_args(
    substitute(list(...)), "Arguments after ... must be named,"
  )

  # default optional arguments
  assert_class(dframe, "data.frame")
  assert_class(match_to, "data.frame")
  select <- select %||% names(dframe)

  # check arguments
  assert_class(key_col, "character")
  assert_class(select, "character")

  # existence of required columns
  assert_required_column(dframe, key_col)
  assert_required_column(match_to, key_col)

  # to use DT syntax in next assertions
  setDT(dframe)
  setDT(match_to)
  dframe <- copy(dframe)

  # class of required columns
  # assert_class(dframe[get(key_col)], "character")
  # assert_class(match_to[get(key_col)], "character")

  # bind names due to nonstandard evaluation notes in R CMD check
  # var <- NULL


  # key must be in both data frames
  stopifnot("`key_col` must be a column in `dframe`" = key_col %in% names(dframe))
  stopifnot("`key_col` must be a column in `match_to`" = key_col %in% names(match_to))

  if (is.null(select)) {select <- names(dframe)}

  # keep one column
  match_to <- match_to[, key_col, with = FALSE]
  match_to <- unique(match_to)

  # set common key
  setkeyv(dframe, key_col)
  setkeyv(match_to, key_col)

  # inner join
  dframe <- match_to[dframe, nomatch = 0]

  # keep selected columns
  dframe <- dframe[, select, with = FALSE]
  dframe <- unique(dframe)

  setkey(dframe, NULL)

  # enable printing (see data.table FAQ 2.23)
  dframe[]
}

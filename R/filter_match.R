

#' @import data.table
#' @importFrom wrapr stop_if_dot_args
#' @importFrom checkmate qassert assert_names
NULL


#' Subset rows by matching values in shared key columns
#'
#' Subset rows of one data frame by values of a key column that match values
#' of a similar key column in a second data frame. Columns are not subset
#' unless selected in an optional argument.
#'
#' Two data frames are input. The \code{match_to} data frame is subset to
#' retain its key column only.  The result is merged with \code{dframe} in an
#' inner-join, returning the rows of \code{dframe} with values matching the key
#' values in \code{match_to}.
#'
#' Column subsetting occurs after the inner join, so the
#' key column does not have to be included in the vector of column names in
#' \code{select}.
#'
#' @param dframe Data frame to be subset and returned. Must contain the key
#'        column named in \code{by_col}.
#' @param match_to Data frame with key column values to be matched to. The
#'        only column used is the required key column named in \code{by_col}.
#' @param by_col Character scalar, name of the key column. Values in the
#'        key column must be character strings.
#' @param ... Not used, force later arguments to be used by name.
#' @param select Optional character vector of \code{dframe} column names
#'        to retain,
#'        default all columns.
#' @return A \code{data.table} with the following properties:
#' \itemize{
#'     \item Rows with matching values.
#'     \item All columns or those specified by \code{select}.
#'     \item Grouping structures are not preserved.
#' }
#'
#'
#' @family filter_*
#'
#'
#' @examples
#' # Start with a toy sample of student (built-in data set)
#' str(toy_student)
#'
#'
#' # Filter by matching IDs of graduates
#' x_student <- filter_match(toy_student,
#'                           match_to = toy_degree,
#'                           by_col   = "mcid")
#' # Note change in number of rows
#' str(x_student)
#'
#'
#' # Same filter and select 3 columns only
#' x_student <- filter_match(toy_student,
#'                           match_to = toy_degree,
#'                           by_col   = "mcid",
#'                           select   = c("mcid", "race", "sex"))
#' str(x_student)
#'
#'
#' # Filter term data for engineering program codes (start with "14")
#' engr_term <- toy_term[grepl("^14", cip6), ]
#' str(engr_term)
#'
#'
#' # Filter student by matching IDs of engineering students
#' x_student <- filter_match(toy_student,
#'                    match_to = engr_term,
#'                    by_col   = "mcid",
#'                    select   = c("mcid", "institution", "transfer", "sex"))
#' str(x_student)
#'
#'
#' # The 'by_col' column does not have to be included in the `select` columns
#' x_student <- filter_match(toy_student,
#'                           match_to = engr_term,
#'                           by_col   = "mcid",
#'                           select   = c("institution", "transfer", "sex"))
#' str(x_student)
#'
#'
#' @export
#'
#'
filter_match <- function(dframe,
                         match_to,
                         by_col,
                         ...,
                         select = NULL) {

  # assert arguments after dots used by name
  wrapr::stop_if_dot_args(
    substitute(list(...)),
    paste(
      "Arguments after ... must be named.\n",
      "* Did you forget to write `select = `?\n *"
    )
  )

  # required arguments
  qassert(dframe, "d+")
  qassert(match_to, "d+")
  qassert(by_col, "s1")

  # optional arguments
  select <- select %||% names(dframe)
  qassert(select, "s+")

  # inputs modified (or not) by reference
  setDT(dframe)
  setDT(match_to) # immediately subset, so side-effect OK

  # required columns
  assert_names(colnames(dframe), must.include = by_col)
  assert_names(colnames(match_to), must.include = by_col)

  # class of required columns
  # qassert(dframe[, ..by_col], "s+")
  # qassert(match_to[, ..by_col], "s+")

  # bind names due to NSE notes in R CMD check
  # NA

  # do the work
  match_to <- match_to[, by_col, with = FALSE]
  match_to <- unique(match_to)

  # set common key
  setkeyv(dframe, by_col)
  setkeyv(match_to, by_col)

  # inner join
  dframe <- match_to[dframe, nomatch = 0]

  # keep selected columns
  dframe <- dframe[, select, with = FALSE]
  setkey(dframe, NULL)

  # enable printing (see data.table FAQ 2.23)
  dframe[]
}



#' @import data.table
#' @importFrom checkmate qassert assert_names
NULL



#' Add a column of institution names
#'
#' Add a column of character values with institution names (or labels) using
#' student ID as the join-by variable. In the MIDFIELD practice data, the
#' labels are anonymized. Based on information in the MIDFIELD \code{term}
#' data table or equivalent.
#'
#' If a student is associated with more than one institution, the institution
#' at which they completed the most terms is returned. An existing column with
#' the same name as the added column is overwritten.
#'
#' @param dframe Data frame with required variable \code{mcid}.
#' @param midfield_table MIDFIELD \code{term} data table or equivalent with
#'        required variables \code{mcid}, \code{institutiion}, \code{term}.
#' @return A \code{data.table}  with the following properties:
#' \itemize{
#'     \item Rows are not modified.
#'     \item Column \code{institution} is added.
#'     \item Grouping structures are not preserved.
#' }
#'
#'
#' @family add_*
#'
#'
#' @examples
#' # extract a column of IDs from student
#' id <- toy_student[, .(mcid)]
#'
#'
#' # add institutions from term
#' DT1 <- add_institution(id, midfield_table = toy_term)
#' head(DT1)
#'
#'
#' # will overwrite institution column if present
#' DT2 <- add_institution(DT1, midfield_table = toy_term)
#' head(DT2)
#'
#'
#'
#'
#'
#'
#'
#'
#' @export
#'
#'
add_institution <- function(dframe,
                            midfield_table) {

  # required arguments
  qassert(dframe, "d+")
  qassert(midfield_table, "d+")

  # optional arguments
  # NA

  # inputs modified (or not) by reference
  dframe <- copy(as.data.table(dframe)) #  must copy
  setDT(midfield_table) # immediately subset, so side-effect OK

  # required columns
  assert_names(colnames(dframe),
               must.include = c("mcid"))
  assert_names(colnames(midfield_table),
               must.include = c("mcid", "institution", "term"))

  # class of required columns
  qassert(dframe[, mcid], "s+")
  qassert(midfield_table[, mcid], "s+")
  qassert(midfield_table[, institution], "s+")
  qassert(midfield_table[, term], "s+")

  # bind names due to NSE notes in R CMD check
  N <- NULL

  # do the work
  DT <- filter_match(midfield_table,
    match_to = dframe,
    by_col = "mcid",
    select = c("mcid", "institution", "term")
  )

  # count terms at institutions
  DT <- DT[, .N, by = c("mcid", "institution")]



  # what if there is a tie? can we select the most recent institution?
  # keep the institution with the most terms (if more than one)
  setkeyv(DT, c("mcid", "N"))
  DT <- DT[, .SD[.N], by = "mcid"]
  DT[, N := NULL]

  # join to dframe, overwrite institution if any
  if ("institution" %chin% names(dframe)) {
    dframe[, institution := NULL]
  }

  # left outer join, keep all rows of dframe
  setkeyv(DT, "mcid")
  setkeyv(dframe, "mcid")
  dframe <- DT[dframe]

  # remove grouping structure
  setkey(dframe, NULL)

  # enable printing (see data.table FAQ 2.23)
  dframe[]
}

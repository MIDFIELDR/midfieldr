#' @import data.table
NULL

#' Add a column of institution names
#'
#' Add a column of character values with institution names (or labels) using
#' student ID as the join-by variable. In the MIDFIELD practice data, the
#' labels are anonymized. Based on information in the MIDFIELD \code{term}
#' data table.
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
#' @family add_*
#' @export
#' @examples
#' # TBD
add_institution <- function(dframe,
                            midfield_table) {

    # explicit arguments and NULL defaults if any
    assert_explicit(dframe)
    assert_explicit(midfield_table)

    # check argument class
    assert_class(dframe, "data.frame")
    assert_class(midfield_table, "data.frame")

    # dframe is modified "by reference" throughout
    setDT(dframe)
    setDT(midfield_table)

    # existence of required columns
    assert_required_column(dframe, "mcid")
    assert_required_column(midfield_table, "mcid")
    assert_required_column(midfield_table, "institution")
    assert_required_column(midfield_table, "term")

    # class of required columns
    assert_class(dframe[, mcid], "character")
    assert_class(midfield_table[, mcid], "character")
    assert_class(midfield_table[, institution], "character")
    assert_class(midfield_table[, term], "character")

    # bind names due to NSE notes in R CMD check
    N <- NULL

    DT <- filter_match(midfield_table,
                       match_to = dframe,
                       by_col = "mcid",
                       select = c("mcid", "institution", "term"))

    # count terms at institutions
    DT <- DT[, .N, by = c("mcid", "institution")]

    # test
    # y <- data.table(
    #   mcid = "MID25783178",
    #   institution = " Institution Q",
    #   N = 2
    # )
    # y
    # x <- rbindlist(list(x, y))

    # what if there is a tie? can we selec the most recent institution?
    # keep the institution with the most terms (if more than one)
    setkeyv(DT, c("mcid", "N"))
    DT <- DT[, .SD[.N], by = "mcid"]
    DT[, N := NULL]

    # join to dframe, overwrite institution if any
    if("institution" %chin% names(dframe)) {dframe[, institution := NULL]}

    # left outer join, keep all rows of dframe
    setkeyv(DT, "mcid")
    setkeyv(dframe, "mcid")
    dframe <- DT[dframe]

    # remove grouping structure
    setkey(dframe, NULL)

    # enable printing (see data.table FAQ 2.23)
    dframe[]
}


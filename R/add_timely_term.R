#' @import data.table
#' @importFrom wrapr stop_if_dot_args
NULL

#' Add column from term for the limiting term for timely completion
#'
#' Given information about a student's academic path, determine the latest
#' term for which program completion could be considered timely.
#'
#' The basic heuristic starts with \code{span} number of years for each
#' student (default 6 years) and adjusts the span by subtracting a whole
#' number of years based on the level at which the student is admitted.
#'
#' For example, a student admitted at a 4th-year or senior level is assumed
#' to have completed 3 years of a program, so their span is reduced by 3 years.
#' Similarly, the span of 3rd-year admissions are reduced by two years, and
#' the span of 2nd-year admissions is reduced by one year. The adjusted span
#' is added to their starting term; the result is the limiting term for
#' timely completion reported in a \code{timely_term} column added to the
#' data frame.
#'
#' This model for timely completion is simplistic, and future
#' heuristics may be added for more sophisticated estimates.
#'
#' If \code{details} is TRUE, additional column(s) that support the finding
#' are returned as well. Here the extra columns are the student's initial
#' (admission) term \code{term_i}, initial level \code{level_i}, and
#' the adjusted span \code{adj_span}.
#'
#' @param dframe data frame with required variable \code{mcid}
#' @param midfield_table MIDFIELD term data table
#'        with required variables \code{mcid}, \code{term}, and \code{level}
#' @param ... not used, forces later arguments to be used by name
#' @param details logical scalar to add columns reporting information on
#'        which the timely completion limit is based, default FALSE
#' @param span numeric scalar, number of years to define timely completion,
#'        default 6 years
#' @param heuristic not used, placeholder for future alternative methods of
#'        estimating them timely completion term
#' @return A \code{data.table}  with the following properties:
#' \itemize{
#'     \item Rows are not modified
#'     \item Column \code{timely_term} is added, columns \code{term_i},
#'           \code{level_i}, and \code{adj_span} are added optionally
#'     \item Grouping structures are not preserved
#' }
#' @family functions
#' @export
#' @examples
#' # TBD
add_timely_term<- function(dframe,
                           midfield_table,
                           ...,
                           details = NULL,
                           span = NULL,
                           heuristic = NULL) {

    # force arguments after dots to be used by name
    wrapr::stop_if_dot_args(
        substitute(list(...)), "Arguments after ... must be named,"
    )

    # explicit arguments and NULL defaults if any
    assert_explicit(dframe)
    assert_explicit(midfield_table)
    details <- details %||% FALSE
    span <- span %||% 6
    heuristic <- NULL # for future use

    # check argument class
    assert_class(dframe, "data.frame")
    assert_class(span, "numeric")
    assert_class(midfield_table, "data.frame")
    assert_class(details, "logical")
    # heuristic ignored for now

    # dframe is modified "by reference" throughout
    setDT(dframe)
    setDT(midfield_table)

    # existence of required columns
    assert_required_column(dframe, "mcid")
    assert_required_column(midfield_table, "mcid")
    assert_required_column(midfield_table, "term")
    assert_required_column(midfield_table, "level")

    # class of required columns
    assert_class(dframe[, mcid], "character")
    assert_class(midfield_table[, mcid], "character")
    assert_class(midfield_table[, term], "character")
    assert_class(midfield_table[, level], "character")

    # bind names due to NSE notes in R CMD check
    timely_term <- NULL
    adj_span <- NULL
    level_i <- NULL
    delta <- NULL
    yyyy <- NULL

    # preserve column order except columns that match new columns
    added_cols <- c("term_i", "level_i", "adj_span", "timely_term")
    names_dframe <- colnames(dframe)
    key_names <- names_dframe[!names_dframe %chin% added_cols]
    dframe <- dframe[, key_names, with = FALSE]

    # subset midfield data table
    DT <- filter_by_key(dframe = midfield_table,
                        match_to = dframe,
                        key_col = "mcid",
                        select =  c("mcid", "term", "level"))

    # separate term encoding
    DT[, `:=` (yyyy = as.numeric(substr(term, 1, 4)),
               t = as.numeric(substr(term, 5, 5)))]

    # keep fall through summer terms, omit "month" terms A, B, etc.
    DT <- DT[t %in% seq(1, 6)]

    # retain the first recorded term by ID
    setorderv(DT, c("mcid", "term"))
    DT <- DT[, .SD[1], by = c("mcid")]
    setnames(DT,
             old = c("term", "level"),
             new = c("term_i", "level_i"))

    # if first term is in summer, delay to the subsequent Fall
    DT[t %in% c(4, 5, 6), `:=` (yyyy = yyyy + 1, t = 1)]

    # reduce span by assumed number of completed years by level
    DT[, delta := fcase(
        level_i %like% "04", 3,
        level_i %like% "03", 2,
        level_i %like% "02", 1,
        default = 0
    )]
    DT[, adj_span := span - delta]

    # use adj_span to construct estimated term for timely-completion
    DT[t == 1, timely_term:= paste0(yyyy + adj_span - 1, 3)]
    DT[t  > 1, timely_term:= paste0(yyyy + adj_span    , 1)]

    # remove intermediate variables
    DT[, c("yyyy", "t", "delta") := NULL]

    # left-outer join, keep all rows of dframe
    dframe <-  merge(dframe, DT, by = "mcid", all.x = TRUE)

    # restore column and row order
    set_colrow_order(dframe, key_names)

    # include or omit the details columns
    if (details == FALSE) {
        cols_we_want <- c(key_names, "timely_term")
        dframe <- dframe[, cols_we_want, with = FALSE]
    }

    # remove grouping structure, if any
    setkey(dframe, NULL)

    # enable printing (see data.table FAQ 2.23)
    dframe[]
}


#' @import data.table
#' @importFrom wrapr stop_if_dot_args
NULL

#' Add a column for the limiting term for timely completion
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
#' timely completion reported in a \code{term_timely} column added to the
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
#' @param ... not used, forces later arguments to be used by name
#' @param span numeric scalar, number of years to define timely completion,
#'        default 6 years
#' @param mdata MIDFIELD term data, default \code{midfielddata::term},
#'        with required variables \code{mcid}, \code{term}, and \code{level}
#' @param details logical scalar to add columns reporting information on
#'        which the timely completion limit is based, default FALSE
#' @param heuristic not used, placeholder for future alternative methods of
#'        estimating them timely completion term
#' @return A \code{data.table}  with the following properties:
#' \itemize{
#'     \item Rows are not modified
#'     \item Column \code{term_timely} is added, columns \code{term_i},
#'           \code{level_i}, and \code{adj_span} are added optionally
#'     \item Grouping structures are not preserved
#' }
#' @export
#' @examples
#' # TBD
add_term_timely<- function(dframe,
                           ...,
                           span = NULL,
                           mdata = NULL,
                           details = NULL,
                           heuristic = NULL) {

    wrapr::stop_if_dot_args(
        substitute(list(...)), "Arguments after ... must be named,"
    )

    # default arguments if NULL
    span <- span %||% 6
    mdata <- mdata %||% midfielddata::term
    details <- details %||% FALSE
    heuristic <- NULL

    # bind names due to NSE notes in R CMD check
    term_timely <- NULL
    adj_span <- NULL
    level_i <- NULL
    delta <- NULL
    yyyy <- NULL

    # check arguments
    assert_explicit(dframe)
    assert_class(dframe, "data.frame")
    assert_class(span, "numeric")
    assert_class(mdata, "data.frame")
    assert_class(details, "logical")
    # heuristic ignored for now

    # The dframe argument is modified "by reference." Thus changing its value
    # inside the function immediately changes its value in the calling frame
    # --- a data.table feature designed for fast data manipulation,
    # especially for data that occupies a lot of memory.
    setDT(dframe)
    setDT(mdata)

    # existence of required columns
    assert_required_column(dframe, "mcid")
    assert_required_column(mdata, "mcid")
    assert_required_column(mdata, "term")
    assert_required_column(mdata, "level")

    # class of required columns
    assert_class(dframe[, mcid], "character")
    assert_class(mdata[, mcid], "character")
    assert_class(mdata[, term], "character")
    assert_class(mdata[, level], "character")

    # preserve column order except columns that match new columns
    added_cols <- c("term_i", "level_i", "adj_span", "term_timely")
    names_dframe <- colnames(dframe)
    key_names <- names_dframe[!names_dframe %chin% added_cols]
    dframe <- dframe[, key_names, with = FALSE]

    # work on the mdata data
    # get student's first term and level
    cols_we_want <- c("mcid", "term", "level")
    rows_we_want <- mdata$mcid %chin% dframe$mcid
    DT <- mdata[rows_we_want, cols_we_want, with = FALSE]

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
    DT[t == 1, term_timely:= paste0(yyyy + adj_span - 1, 3)]
    DT[t  > 1, term_timely:= paste0(yyyy + adj_span    , 1)]

    # remove intermediate variables
    DT[, c("yyyy", "t", "delta") := NULL]

    # left-outer join, keep all rows of dframe
    dframe <-  merge(dframe, DT, by = "mcid", all.x = TRUE)

    # restore column and row order
    set_colrow_order(dframe, key_names)

    # include or omit the details columns
    if (details == FALSE) {
        cols_we_want <- c(key_names, "term_timely")
        dframe <- dframe[, cols_we_want, with = FALSE]
    }

    # remove grouping structure, if any
    setkey(dframe, NULL)

    # enable printing (see data.table FAQ 2.23)
    dframe[]
}


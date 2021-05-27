#' @import data.table
#' @importFrom wrapr stop_if_dot_args
NULL

#' Add a column for the timely completion limit term
#'
#' Given information about a student's academic path, determine the latest
#' term for which program completion could be considered timely.
#'
#' The current model for timely completion is simple, though future
#' heuristics may be added for more sophisticated estimates. The current
#' estimate starts with \code{span} number of years for each student
#' (default 6 years) and adjusts the span by subtracting a whole number of
#' years based on the level at which the student matriculates.
#'
#' For example, a 4th-year or senior level matriculant is assumed to have
#' completed 3 years of a program, so their span is reduced by 3 years.
#' Similarly, a 3rd-year or junior-level matriculant is assumed to have
#' completed 2 years of a program, so their span is reduced by 2 years.
#'
#' The adjusted span is added to their starting term; the result is the
#' limiting term for timely completion reported in a \code{timely_limit}
#' column added to the data frame.
#'
#' If \code{details} is TRUE, additional column(s) that support the finding
#' are returned as well. Here the extra columns are the student's initial
#' (matriculation) term \code{term_i}, initial level \code{level_i}, and
#' the adjusted span \code{adj_span}.
#'
#' @param dframe data frame
#' @param ... not used, forces later arguments to be used by name
#' @param span numeric scalar, number of years to define timely completion,
#'        default 6 years
#' @param record data frame of term attributes, default midfieldterms
#' @param details logical scalar to add columns reporting information on
#'        which the timely completion limit is based, default FALSE
#' @param heuristic not used, placeholder for future alternative methods of
#'        estimating them timely completion term
#' @return Data frame with the following properties:
#' \itemize{
#'     \item Rows are not modified
#'     \item Column \code{timely_limit} is added, columns \code{term_i},
#'           \code{level_i}, and \code{adj_span} are added optionally
#'     \item Data frame attributes \code{tbl} or \code{data.table}
#'           are preserved
#'     \item Grouping structures are not preserved
#' }
#' @examples
#' # TBD
#'
#' @family functions
#' @export
add_timely_limit <- function(dframe,
                             ...,
                             span = NULL,
                             record = NULL,
                             details = NULL,
                             heuristic = NULL) {

    wrapr::stop_if_dot_args(
        substitute(list(...)), "Arguments after ... must be named,"
    )

    # default arguments if NULL
    span <- span %||% 6
    record <- record %||% midfielddata::midfieldterms
    details <- details %||% FALSE
    heuristic <- NULL

    # bind names due to nonstandard evaluation notes in R CMD check
    yyyy <- NULL
    delta <- NULL
    level_i <- NULL
    adj_span <- NULL
    timely_limit <- NULL

    # check arguments
    assert_explicit(dframe)
    assert_class(dframe, "data.frame")
    assert_class(span, "numeric")
    assert_class(record, "data.frame")
    assert_class(details, "logical")
    # heuristic ignored for now

    # existence of required columns
    assert_required_column(dframe, "id")
    assert_required_column(record, "id")
    assert_required_column(record, "term")
    assert_required_column(record, "level")

    # class of required columns
    assert_class(dframe[, id], "character")
    assert_class(record[, id], "character")
    # to do: revise term in midfielddata to be character, for now:
    record[, term := as.character(term)]
    assert_class(record[, term], "character")
    assert_class(record[, level], "character")

    # preserve original data.frame, data.table, or tibble class
    df_class <- get_dframe_class(dframe)

    # prepare dframe, preserve column order for return
    # omit existing column(s) that match column(s) we add
    setDT(dframe)
    added_cols <- c("term_i", "level_i", "adj_span", "timely_limit")
    names_dframe <- colnames(dframe)
    key_names <- names_dframe[!names_dframe %chin% added_cols]
    dframe <- dframe[, key_names, with = FALSE]

    # work on the record data
    # get student's first term and level
    cols_we_want <- c("id", "term", "level")
    rows_we_want <- record$id %chin% dframe$id
    DT <- record[rows_we_want, cols_we_want, with = FALSE]

    # separate term encoding
    DT[, `:=` (yyyy = as.numeric(substr(term, 1, 4)),
               t = as.numeric(substr(term, 5, 5)))]

    # keep fall through summer terms, omit "month" terms A, B, etc.
    DT <- DT[t %in% seq(1, 6)]

    # retain the first recorded term by ID
    setorderv(DT, c("id", "term"))
    DT <- DT[, .SD[1], by = c("id")]
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
    DT[t == 1, timely_limit := paste0(yyyy + adj_span - 1, 3)]
    DT[t  > 1, timely_limit := paste0(yyyy + adj_span    , 1)]

    # remove intermediate variables
    DT[, c("yyyy", "t", "delta") := NULL]

    # left-outer join, keep all rows of dframe
    dframe <-  merge(dframe, DT, by = "id", all.x = TRUE)

    # prepare return
    # order columns and rows using original columns as keys
    set_colrow_order(dframe, key_names)

    # do we return the details variables?
    if (details == FALSE) { # omit the details
        cols_we_want <- c(key_names, "timely_limit")
        dframe <- dframe[, cols_we_want, with = FALSE]
    }

    # restore original data frame class
    revive_class(dframe, df_class)
}


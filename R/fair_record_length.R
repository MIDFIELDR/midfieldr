#' @import data.table
#' @importFrom wrapr stop_if_dot_args
NULL

#' Subset ID vector for fair record length
#'
#' Subset a vector of student IDs, omitting those who matriculate too near
#' the end of the data record for fairly assessing program completion.
#'
#' Most persistence metrics are computed using program completion as a
#' criterion. To fairly assess whether or not a student has completed a
#' program, there must exist a sufficient number of terms in the data
#' record between matriculation and the institutional end-of-record.
#'
#' The \code{span} argument (default 6 years) is the basis interval between
#' matriculation and the data end-of-record considered sufficient for
#' program completion assessment. The basis interval is used as-is for students
#' whose level in their first term is "01 Freshman" (first-year). For
#' students entering at higher levels, the span is reduced by one year per
#' level. For example, the span for an entering sophomore is reduced by one
#' year; entering junior, reduced by two years; entering senior, reduced by
#' three years.
#'
#' The adjusted \code{span} defines the interval during which program
#' completion would be considered "timely" for that student. The last term of
#' this interval is the student's "timely completion term." The last term in
#' the term data overall, by institution, is the institution's
#' end-of-record term.
#'
#' Program completion can be assessed fairly only for students whose timely
#' completion term is no later than their institution's end-of record term.
#' IDs of students satisfying this condition are returned by the function.
#' IDs not satisfying this condition are dropped.
#'
#' The function accesses one of the midfielddata data sets:
#' \code{\link[midfielddata]{midfieldterms}}.
#'
#' @param id character vector of student IDs
#' @param ... not used, force later arguments to be used by name.
#' @param span numeric scalar, number of years to define fair assessment of
#' program completion, default is 6 years
#' @param record data frame of term attributes, default midfieldterms
#' @param heuristic not used. Argument to be used in the future for more
#' sophisticated algorithms to determine a student's timely completion term.
#'
#' @return character vector of student IDs, a subset of the input
#'
#' @examples
#' #TBD
#'
#' @family functions
#'
#' @export
fair_record_length <- function(id,
                               ...,
                               span = NULL,
                               record = NULL,
                               heuristic = NULL) {

  wrapr::stop_if_dot_args(
    substitute(list(...)), "Arguments after ... must be named,"
  )

  # record must have id, institution, term, level

  # heuristic is a placeholder (not used currently) for a future version
  # with a more sophisticated estimate of fair record length

  # defaults if NULL
  span <- span %||% 6
  record <- record %||% midfielddata::midfieldterms
  heuristic <- heuristic %||% NULL

  # bind names due to nonstandard evaluation notes in R CMD check
  inst_max_term <- NULL

  # timely completion term: id, institution, w_term (i.e., the omega term)
  w_term <- estimate_omega_term(id, span, record)

  # institution and inst_max_term
  max_term <- pull_inst_max_term(record)

  # join
  keycols <- c("institution")
  setkeyv(w_term, keycols)
  setkeyv(max_term, keycols)
  DT <- merge(w_term, max_term, by = keycols, all.x = TRUE)

  # subset for fair record length
  DT <- DT[w_term <= inst_max_term]

  # return IDs
  latest_id <- unique(DT[, (id)])
}

# ------------------------------------------------------------------------
# internal functions
# ------------------------------------------------------------------------

#' Estimate timely completion term
#'
#' The timely completion term is last term of the interval during
#' which a student's program completion would be considered timely.
#'
#' The \code{span} argument (typically 6 years) is the basis interval between
#' matriculation and the timely completion term. The basis interval is used
#' as-is for students whose level in their first term is "01 Freshman"
#' (first-year). For students entering at higher levels, the span is reduced
#' by one year per level. For example, the span for an entering sophomore is
#' reduced by one year; entering junior, reduced by two years;
#' entering senior, reduced by three years.
#'
#' @param id character vector of student IDs
#' @param span numeric scalar, number of years to define fair assessment of
#' program completion
#' @param record data frame of term attributes
#' @noRd
estimate_omega_term <- function(id, span, record) {

  # bind names
  term_i <- NULL
  yyyy <- NULL
  delta_span <- NULL
  level_i <- NULL
  w_term <- NULL

  # subset rows
  rows_we_want <- record$id %chin% id
  DT <- record[rows_we_want]

  # limit terms to 1:6, omitting month-terms A, B, C, etc
  DT <- DT[as.numeric(substr(term, 5, 5)) %in% seq(1, 6)]

  # student's first term and institution
  cols <- c("id", "term", "level", "institution")
  DT <- DT[, cols, with = FALSE]
  setorderv(DT, cols = c("id", "term"))
  DT <- DT[, .SD[1], by = id]
  setnames(DT,
           old = c("term", "level"),
           new = c("term_i", "level_i"))

  # separate term for term addition
  DT[, `:=` (yyyy = as.numeric(substr(term_i, 1, 4)),
             t = as.numeric(substr(term_i, 5, 5)))]

  # adjust summer terms to subsequent Fall
  DT[t %in% c(4, 5, 6), `:=` (yyyy = yyyy + 1, t = 1)]

  # first-term level is used to reduce span years
  DT[, delta_span := fcase(
    level_i %like% "01", 0,
    level_i %like% "02", 1,
    level_i %like% "03", 2,
    level_i %like% "04", 3,
    default = 0
  )]
  DT[, span := span - delta_span]

  # construct the omega term
  DT[t == 1, w_term := paste0(yyyy + span - 1, 3)]
  DT[t > 1,  w_term := paste0(yyyy + span    , 1)]

  # return
  DT <- DT[, .(id, institution, w_term)]
}

# ------------------------------------------------------------------------

#' Pull the end-of-record term by institution
#'
#' An institution's end-of-record term is the last term in the term data
#' overall, by institution.
#'
#' @param record data frame of term attributes
#' @noRd
pull_inst_max_term <- function(record) {

  # bind names
  # placeholder <- NULL

  cols <- c("institution", "term")
  data_limit <- record[, cols, with = FALSE]
  setorderv(data_limit, cols = cols)
  data_limit <- data_limit[, .SD[.N], by = "institution"]
  setnames(data_limit, old = "term", new = "inst_max_term")
}

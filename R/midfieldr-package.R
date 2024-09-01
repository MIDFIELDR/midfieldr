#' @keywords internal
"_PACKAGE"

#' @importFrom checkmate assert_data_frame
#' @importFrom checkmate assert_int
#' @importFrom checkmate assert_names
#' @importFrom checkmate qassert
#' @importFrom checkmate assert_subset
#' @importFrom data.table setkey
#' @importFrom data.table setkeyv
#' @importFrom data.table setcolorder
#' @importFrom data.table setnames
#' @importFrom data.table setorderv
#' @importFrom data.table setorder
#' @importFrom data.table fcase
#' @importFrom data.table fifelse
#' @importFrom data.table copy
#' @importFrom data.table as.data.table
#' @importFrom data.table shift
#' @importFrom data.table setDF
#' @importFrom data.table setDT
#' @importFrom data.table %chin%
#' @importFrom data.table %like%
#' @importFrom data.table .SD
#' @importFrom data.table .N
#' @importFrom data.table :=
#' @importFrom stats na.omit
#' @importFrom stats reorder
#' @importFrom wrapr let
#' @importFrom wrapr stop_if_dot_args
#' @importFrom wrapr %?%
#' @importFrom wrapr check_equiv_frames
NULL

# bind names due to NSE notes in R CMD check
if (getRversion() >= "2.15.1") {
  utils::globalVariables(c(
    ".",
    # midfield data table names
    "student", "term", "course", "degree", 
    # midfielddata column names
    "abbrev", "act_comp", "age_desc", "cip6", "coop", "course", "degree", 
    "discipline_midfield", "faculty_rank", "gpa_cumul", "gpa_term", "grade", 
    "high_school", "home_zip", "hours_course", "hours_cumul", 
    "hours_cumul_attempt", "hours_term", "hours_term_attempt", "hours_transfer", 
    "institution", "level", "mcid", "number", "race", "sat_math", "sat_verbal", 
    "section", "sex", "standing", "term", "term_course", "term_degree", 
    "transfer", "type", "us_citizen"
  ))
}

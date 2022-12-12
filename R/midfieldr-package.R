
#' @importFrom checkmate assert_data_frame assert_int qassert
#' @importFrom checkmate assert_subset assert_names
#' 
#' @importFrom data.table setkey setkeyv setcolorder setnames setorderv setorder
#' @importFrom data.table fcase fifelse copy as.data.table shift
#' @importFrom data.table setDF setDT
#' @importFrom data.table %chin% %like% .SD .N :=
#' 
#' @importFrom stats na.omit reorder
#' 
#' @importFrom wrapr let stop_if_dot_args %?%
NULL

#' Tools and Methods for Working with MIDFIELD Data in R
#'
#' ```{r child = "man/rmd/note-description-paragraph.Rmd"} 
#' ```
#' 
#' ```{r child = "man/rmd/note-midfielddata-and-midfield.Rmd"} 
#' ````
#' 
#' ```{r child = "man/rmd/note-nsf-grant.Rmd"}
#' ```
#'
#' @source Data provided by MIDFIELD: \url{https://midfield.online/}. 
#' @docType package
#' @family package
#' @name midfieldr-package
#'   
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

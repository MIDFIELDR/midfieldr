# Documentation described below using an inline R code chunk, e.g.,
# "`r var_mcid`" or "`r var_institution`", are documented in the
# R/roxygen.R file.


# -------------------------------------------------------------------

#' Table of academic programs
#'
#' A data table based on the US National Center for Education Statistics (NCES),
#' Integrated Postsecondary Education Data System (IPEDS), 2010 CIP. The data
#' are codes and names for 1582 instructional programs organized on three
#' levels: a 2-digit series, a 4-digit series, and a 6-digit series.
#'
#' The midfielddata taxonomy includes one non-IPEDS code (999999) for Undecided
#' or Unspecified, instances in which institutions reported no program
#' information or that students were not enrolled in a program.
#'
#' @usage  cip
#' @family cip-data
#' @source <https://nces.ed.gov/ipeds/cipcode/>
#'
#' @format A `data.table` with 1582 rows and 6 columns keyed by the
#'         6-digit CIP code:
#' \describe{
#'
#'   \item{`cip6name`}{Character, program name at the 6-digit level}
#'
#'   \item{`cip6`}{Character, 6-digit code representing "specific
#'   instructional programs" (US National Center for Education Statistics).}
#'
#'   \item{`cip4name`}{Character, program name at the 4-digit level.}
#'
#'   \item{`cip4`}{Character, 4-digit code (the first 4 digits of `cip6`)
#'   representing "intermediate groupings of programs that have
#'   comparable content and objectives."}
#'
#'   \item{`cip2name`}{Character, program name at the 2-digit level.}
#'
#'   \item{`cip2`}{Character, 2-digit code (the first 2 digits of `cip6`)
#'   representing "the most general groupings of related programs."}
#'
#' }
#'
"cip"


#' Alternate table of academic programs
#'
#' A data table of the 2010 Classification of Instructional Programs (CIP)
#' accessed in 2026 from the US National Center for Education Statistics
#' (NCES). Like the `cip` data set originally included with midfieldr,
#' `cip2010` provides codes and names for instructional programs organized
#' on three levels: a 2-digit series, a 4-digit series, and a 6-digit series.
#'
#' The midfielddata taxonomy includes one non-IPEDS code (999999) for Undecided
#' or Unspecified, instances in which institutions reported no program
#' information or that students were not enrolled in a program.
#'
#' @usage cip2010
#' @family cip-data
#' @source <https://nces.ed.gov/ipeds/cipcode/>
#'
#' @format `data.table` with 1849 rows and 6 columns keyed by the 6-digit CIP
#'   code:
#'
#' \describe{
#'
#'   \item{`cip6`}{Character, 6-digit code representing "specific
#'   instructional programs" (US National Center for Education Statistics).}
#'
#'   \item{`cip6name`}{Character, program name at the 6-digit level}
#'
#'   \item{`cip4`}{Character, 4-digit code (the first 4 digits of `cip6`)
#'   representing "intermediate groupings of programs that have
#'   comparable content and objectives."}
#'
#'   \item{`cip4name`}{Character, program name at the 4-digit level.}
#'
#'   \item{`cip2`}{Character, 2-digit code (the first 2 digits of `cip6`)
#'   representing "the most general groupings of related programs."}
#'
#'   \item{`cip2name`}{Character, program name at the 2-digit level.}
#' }
"cip2010"


# -------------------------------------------------------------------

#' Starting program proxies for FYE students
#'
#' Proxies are the degree-granting engineering programs we estimate that
#' First-Year Engineering (FYE) students would have declared had they not been
#' required to enroll in FYE. Keyed by student ID. Proxies are provided for all
#' students in the midfielddata practice data who ever enroll in FYE.
#'
#' The proxy variable contains 6-digit CIP codes of degree-granting engineering
#' programs, e.g., Electrical Engineering, Mechanical Engineering, etc., that
#' are substituted for the FYE CIP code when an analysis requires
#' degree-granting starting programs. The most common application is a
#' graduation rate calculation.
#'
#' The estimation is based on students' earliest non-FYE, degree-granting
#' programs and a multiple imputation suitable for categorical variables using
#' the mice package. The predictor variables are institution, race, and sex.
#' The estimated variable is the 6-digit CIP code of a degree-granting
#' engineering program at their institution.
#'
#' `fye_proxy` holds only for the practice data in midfielddata---these values
#' cannot be commingled with the MIDFIELD research database.
#'
#' @usage fye_proxy
#' @family cip-data
#'
#' @format `data.table` with 5789 rows and 2 columns keyed by student ID:
#' \describe{
#'   `r var_mcid`
#'   `r var_proxy`
#'  }
"fye_proxy"

# -------------------------------------------------------------------

#' Small 'student' dataset for examples
#'
#' A subset of rows from the midfielddata `student` table. A small dataset
#' for use in examples.
#'
#' @usage toy_student
#' @family toy-data
#'
#' @format Data frame with 351 rows and 13 columns (`data.table` class).
#'         Key: `{mcid}.`
#'   \describe{
#'   `r var_mcid`
#'   `r var_race`
#'   `r var_sex`
#'   `r var_institution`
#'   `r var_transfer`
#'   `r var_hours_transfer`
#'   `r var_age_desc`
#'   `r var_us_citizen`
#'   `r var_home_zip`
#'   `r var_high_school`
#'   `r var_sat_math`
#'   `r var_sat_verbal`
#'   `r var_act_comp`
#'   }
"toy_student"


# -------------------------------------------------------------------

#' Small 'term' dataset for examples
#'
#' A subset of rows from the midfielddata `term` table matching the IDs in
#' `toy_student.` A small dataset for use in examples.
#'
#' @usage toy_term
#' @family toy-data
#'
#' @format Data frame with 1821 rows and 13 columns (`data.table` class).
#'         Composite key: `{mcid, term}.`
#'   \describe{
#'   `r var_mcid`
#'   `r var_term`
#'   `r var_cip6_term`
#'   `r var_institution`
#'   `r var_level`
#'   `r var_standing`
#'   `r var_coop`
#'   `r var_hours_term`
#'   `r var_hours_term_attempt`
#'   `r var_hours_cumul`
#'   `r var_hours_cumul_attempt`
#'   `r var_gpa_term`
#'   `r var_gpa_cumul`
#'   }
"toy_term"


# -------------------------------------------------------------------

#' Small 'course' dataset for examples
#'
#' A subset of rows from the midfielddata `course` table matching the IDs in
#' `toy_student.` A small dataset for use in examples.
#'
#' @usage toy_course
#' @family toy-data
#'
#' @format Data frame with 8950 rows and 12 columns (`data.table` class).
#'         Composite key: `{mcid, term_course, abbrev, number}.`
#'   \describe{
#'   `r var_mcid`
#'   `r var_term_course`
#'   `r var_abbrev`
#'   `r var_number`
#'   `r var_institution`
#'   `r var_course`
#'   `r var_section`
#'   `r var_type`
#'   `r var_faculty_rank`
#'   `r var_hours_course`
#'   `r var_grade`
#'   `r var_discipline_midfield`
#'   }
"toy_course"


# -------------------------------------------------------------------

#' Small 'degree' dataset for examples
#'
#' A subset of rows from the midfielddata `degree` table that comprises
#' those students from the `toy_student` dataset who complete a program.
#' A small dataset used in examples.
#'
#' @usage toy_degree
#' @family toy-data
#'
#' @format Data frame with 193 rows and 4 columns (`data.table` class).
#'         Composite key: `{mcid, term_degree, cip6}.`
#'   \describe{
#'   `r var_mcid`
#'   `r var_term_degree`
#'   `r var_cip6_degree`
#'   `r var_institution`
#'   `r var_degree`
#'   }
"toy_degree"


# -------------------------------------------------------------------

#' Grade scale
#'
#' Data frame of letter grades and conventional point assignments used for
#' computing grade point averages.
#'
#' @usage grade_scale
#' @family scales
#'
#' @format `data.table` with 12 rows and 2 columns:
#' \describe{
#'   \item{`letter_grade`}{Character, letter grades using the conventional US
#'       scale from A to F.}
#'   \item{`points`}{Numerical, 4.0 scale of points assigned to letter grades.}
#' }
"grade_scale"

# -------------------------------------------------------------------

#' ACT-SAT conversion scale
#'
#' Data frame for converting between ACT and SAT scores. A range of SAT scores
#' converts to a single ACT score; an ACT score converts to a single
#' value equivalent SAT score.
#'
#' @usage act_sat_scale
#' @family scales
#' @source ACT/SAT Concordance (2018) ACT Education Corp. <https://www.act.org/content/dam/act/unsecured/documents/ACT-SAT-Concordance-Tables.pdf>
#'
#'
#' @format `data.table` with 28 rows and 4 columns:
#' \describe{
#'   \item{`act_comp`}{Numerical, ACT composite score.}
#'   \item{`sat_lower`}{Numerical, total SAT, lower limit of range
#'   corresponding to the ACT composite score.}
#'   \item{`sat_equiv`}{Numerical, total SAT, value to use when
#'   converting ACT score to a single SAT score.}
#'   \item{`sat_upper`}{Numerical, total SAT, upper limit of range
#'   corresponding to the ACT composite score.}
#' }
"act_sat_scale"

# -------------------------------------------------------------------

#' Baseline population to start a typical analysis
#'
#' Data frame of IDs after processing the practice data for data sufficiency and
#' degree seeking. Provides a convenient bloc to start many of the analysis
#' illustrated in the package articles.
#'
#' @usage population_baseline
#' @family case-study-data
#'
#' @format `data.table` with 76875 rows and 1 column:
#' \describe{
#'   `r var_mcid`
#' }
"population_baseline"

# -------------------------------------------------------------------

#' Case-study results
#'
#' Data table of longitudinal stickiness for the four programs of the case study
#' (Civil, Electrical, Industrial/Systems, and Mechanical Engineering) grouped
#' by program, race/ethnicity, and sex. Provided for the convenience of vignette
#' users.
#'
#' Longitudinal stickiness is the ratio of the number of students graduating
#' from a program to the number of students ever enrolled in the program over
#' the time span of available data. Results are based on data that have been
#' filtered for data sufficiency, degree seeking, undergraduate terms, and
#' timely completion.
#'
#' @usage case_results
#' @family case-study-data
#'
#' @format `data.table` with 43 rows and 4 columns:
#' \describe{
#'  `r var_program`
#'  `r var_people`
#'  `r var_ever`
#'  `r var_grad`
#'  `r var_stick`
#' }
"case_results"

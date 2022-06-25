# -------------------------------------------------------------------

#' Table of academic programs
#'
#' A data table based on the US National Center for Education Statistics
#' (NCES), Integrated Postsecondary Education Data System (IPEDS), 2010
#' CIP, \url{http://nces.ed.gov/ipeds/cipcode/}. The data are codes and
#' names for 1582 instructional programs organized on three levels: a
#' 2-digit series, a 4-digit series, and a 6-digit series.
#'
#' The midfielddata taxonomy includes one non-IPEDS code (999999) for
#' Undecided or Unspecified, instances in which institutions reported no
#' program information or that students were not enrolled in a program.
#'
#' @format A \code{data.table} with 1582 rows and 6 columns keyed by the
#' 6-digit CIP code:
#' \describe{
#'
#'   \item{cip6}{Character 6-digit code representing "specific
#'   instructional programs" (US National Center for Education Statistics).}
#'
#'   \item{cip6name}{Character program name at the 6-digit level}
#'
#'   \item{cip4}{Character 4-digit code (the first 4 digits of \code{cip6})
#'   representing "intermediate groupings of programs that have
#'   comparable content and objectives."}
#'
#'   \item{cip4name}{Character program name at the 4-digit level.}
#'
#'   \item{cip2}{Character 2-digit code (the first 2 digits of \code{cip6})
#'   representing "the most general groupings of related programs."}
#'
#'   \item{cip2name}{Character program name at the 2-digit level.}
#'
#' }
#'
#' @family cip-data
#'
"cip"

# -------------------------------------------------------------------

#' Starting programs imputed for FYE students
#'
#' Degree-granting, engineering CIP codes that can be substituted for
#' First-Year-Engineering (FYE) codes when required by a persistence metric.
#'
#' FYE is different from other non-degree-granting CIP designations such
#' as "undecided" or "undeclared". FYE students are neither undecided nor
#' undeclared---they have been accepted by their institutions as
#' Engineering majors.
#'
#' Starting programs in \code{fye_start} are the engineering programs we
#' predict that students would have declared had they not been required to
#' enroll in FYE. The prediction is based on their first post-FYE program and
#' an imputation suitable for multiple categorical variables using the mice
#' package. The predictor variables are institution, race, and sex. The
#' predicted variable is the 6-digit CIP code of a degree-granting engineering
#' program at their institution.
#'
#' \code{fye_start} holds only for the practice data in
#' midfielddata---these values cannot be commingled with the research
#' database available to MIDFIELD partners.
#'
#' @format \code{data.table} with 5033 rows and 2 columns keyed by student
#' ID. The variables are:
#' \describe{
#'
#'   \item{mcid}{Character, de-identified student ID.}
#'
#'   \item{start}{Character, 6-digit CIP code of the predicted starting
#'   program.}
#'
#'  }
#'
#' @family cip-data
#'
"fye_start"


# -------------------------------------------------------------------

#' Student data for examples
#'
#' A small subset by row and column of the MIDFIELD student table
#' for use in package examples.
#'
#' @format \code{data.table} with 100 rows and 6 columns keyed by
#' student ID.
#' \describe{
#'
#'  \item{mcid}{Character, de-identified student ID.}
#'
#'  \item{institution}{Character, de-identified institution name, e.g.,
#'   Institution A, Institution B, etc.}
#'
#'  \item{transfer}{Character, stating whether the student is a First-Time in
#'  College students or a First-Time Transfer student.}
#'
#'  \item{hours_transfer}{Numeric, transfer hours accepted at the
#'  institution.}
#'
#'  \item{race}{Character, race/ethnicity as self-reported by the student,
#'  e.g., Asian, Black, Hispanic/LatinX, etc.}
#'
#'  \item{sex}{character, sex as self-reported by the student, possible
#'  values are Female, Male, and Unknown.}
#'
#' }
#'
#' @family toy-data
#'
"toy_student"

# -------------------------------------------------------------------

#' Course data for examples
#'
#' A small subset by row and column of the MIDFIELD course table
#' for use in package examples.
#'
#' @format \code{data.table} with 4616 rows and 6 columns keyed by
#' student ID.
#' \describe{
#'
#'  \item{mcid}{Character, anonymized student ID.}
#'
#'  \item{institution}{Character, de-identified institution name, e.g.,
#'       Institution A, Institution B, etc.}
#'
#'  \item{term}{Character, academic year and term, format YYYYT.}
#'
#'  \item{abbrev}{Character, course alphabetical identifier, e.g. ENGR, MATH,
#'  ENGL.}
#'
#'  \item{number}{Character, course numeric identifier, e.g. 101, 3429.}
#'
#'  \item{grade}{Character, course grade, e.g., A+, A, A-, B+, I, NG, etc.}
#'
#' }
#'
#' @family toy-data
#'
"toy_course"

# -------------------------------------------------------------------

#' Term data for examples
#'
#' A small subset by row and column of the MIDFIELD term table
#' for use in package examples.
#'
#' @format \code{data.table} with 169 rows and 6 columns keyed by
#' student ID.
#' \describe{
#'
#'  \item{mcid}{Character, de-identified student ID.}
#'
#'  \item{institution}{Character, de-identified institution name, e.g.,
#'       Institution A, Institution B, etc.}
#'
#'  \item{term}{Character, academic year and term, format YYYYT.}
#'
#'  \item{cip6}{Character, 6-digit CIP code of program in which a student
#'  is enrolled in a term.}
#'
#'  \item{level}{Character, 01 Freshman, 02 Sophomore, etc.}
#'
#'  \item{hours_term}{Numeric, credit hours earned in the term.}
#'
#' }
#'
#' @family toy-data
#'
"toy_term"

# -------------------------------------------------------------------

#' Degree data for examples
#'
#' A small subset by row and column of the MIDFIELD degree table
#' for use in package examples.
#'
#' @format \code{data.table} with 64 rows and 5 columns keyed by
#' student ID.
#' \describe{
#'
#'  \item{mcid}{Character, anonymized student ID.}
#'
#'  \item{institution}{Character, anonymized institution name, e.g.,
#'       Institution A, Institution B, etc.}
#'
#'  \item{term_degree}{Character, academic year and term in which
#'  a student completes their program, format YYYYT.}
#'
#'  \item{cip6}{Character, 6-digit CIP code of program in which a student
#'  earns a degree.}
#'
#'  \item{degree}{Character, type of degree awarded, e.g., Bachelor's
#'  Degree, Bachelor of Arts, Bachelor of Science, etc.}
#'
#' }
#'
#' @family toy-data
#'
"toy_degree"

# -------------------------------------------------------------------

#' Case-study starting pool
#' 
#' An intermediate result provided for the convenience of vignette users. 
#' The starting pool of students ever enrolled in the four programs of the 
#' case study. Keyed by student ID. 
#' 
#' Starting with the midfielddata \code{term} practice data set, we extracted 
#' every observation with CIP codes of the four engineering programs in the 
#' case study: Civil, Electrical, Industrial/Systems, and Mechanical 
#' Engineering. 
#'
#' @format \code{data.table} with 161,696 rows and 2 columns.
#' 
#' \describe{
#'
#'  \item{mcid}{Character, anonymized student identifier}
#'
#'  \item{cip6}{Character, 6-digit CIP program codes.}
#'
#' }
#'
#' @family case-study-data
#'
"study_pool"

# -------------------------------------------------------------------

#' Case-study observations
#' 
#' An intermediate result provided for the convenience of vignette users. 
#' Post-processed observations of students ever enrolled in and graduating 
#' from the four programs of the case study. Keyed by student ID.  
#' 
#' Starting with the case-study starting pool of students ever enrolled in the 
#' four programs of the study (Civil, Electrical, Industrial/Systems, and 
#' Mechanical Engineering), we filtered the data for data sufficiency, 
#' degree seeking, program, and timely completion. 
#' 
#' A data frame of "ever enrolled" and a data frame of "timely graduates" 
#' were bound using shared column names and are distinguished in the 
#' \code{group} variable.  This data structure facilitates grouping and 
#' summarizing by race, sex, program, and group.  
#'
#' @format \code{data.table} with 11,212 rows and 5 columns.
#' 
#' \describe{
#'
#'  \item{mcid}{Character, anonymized student identifier}
#'
#'  \item{race}{Character, self-reported race/ethnicity.}
#'
#'  \item{sex}{Character, self-reported sex.}
#'  
#'  \item{program}{Character, academic program label.}
#'  
#'  \item{group}{Character, indicating the grouping (\code{ever} or 
#'  \code{grad}) to which an observation belongs.} 
#'
#' }
#'
#' @family case-study-data
#'
"study_observations"




# -------------------------------------------------------------------

#' Case-study results
#'
#' An intermediate result provided for the convenience of vignette users. 
#' Longitudinal stickiness keyed by program, race/ethnicity, and sex.
#' 
#' Starting with the prepared data (the case study stickiness observations), 
#' we compute longitudinal stickiness for the four programs of the study (Civil, 
#' Electrical, Industrial/Systems, and Mechanical Engineering) grouped by 
#' program, race/ethnicity, and sex. 
#' 
#' Longitudinal stickiness is the ratio of the number of students graduating
#' from a program to the number of students ever enrolled in the program over
#' the time span of available data. Results are based on data that have been 
#' filtered for data sufficiency, degree seeking, program, and timely 
#' completion. 
#'
#' @format \code{data.table} with 55 rows and 6 columns.
#' 
#' \describe{
#'
#'  \item{program}{Character, academic program label.}
#'
#'  \item{race}{Character, self-reported race/ethnicity.}
#'
#'  \item{sex}{Character, self-reported sex.}
#'
#'  \item{ever}{Numerical, number of students ever enrolled in a program.}
#'
#'  \item{grad}{Numerical, number of students completing a program.}
#'
#'  \item{stick}{Numerical, program stickiness, the ratio \code{grad} to 
#'  \code{ever}, in percent.}
#'
#' }
#'
#' @family case-study-data
#'
"study_results"

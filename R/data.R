# -------------------------------------------------------------------

#' Table of academic programs
#'
#' A data table based on the US National Center for Education Statistics
#' (NCES), Integrated Postsecondary Education Data System (IPEDS), 2020
#' CIP, \url{https://nces.ed.gov/ipeds/cipcode}. The data are codes and
#' names for 1582 instructional programs organized on three levels: a
#' 2-digit series, a 4-digit series, and a 6-digit series.
#'
#' The midfielddata taxonomy includes one non-IPEDS code:
#' \describe{
#'   \item{999999}{Undecided or Unspecified. For instances in which
#'   institutions reported no program information or that students were
#'   not enrolled in a program.}
#' }
#' @format A \code{data.table} with 1582 rows and 6 columns keyed by the
#' 6-digit CIP code:
#' \describe{
#'   \item{cip6}{Character 6-digit code representing "specific
#'   instructional programs" (US National Center for Education Statistics)}
#'   \item{cip6name}{Character program name at the 6-digit level}
#'   \item{cip4}{Character 4-digit code (the first 4 digits of \code{cip6})
#'   representing "intermediate groupings of programs that have
#'   comparable content and objectives"}
#'   \item{cip4name}{Character program name at the 4-digit level}
#'   \item{cip2}{Character 2-digit code (the first 2 digits of \code{cip6})
#'   representing "the most general groupings of related programs"}
#'   \item{cip2name}{Character program name at the 2-digit level}
#' }
#' @family cip-data
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
#'    \item{mcid}{Character, anonymized student identifier}
#'    \item{start}{Character, 6-digit CIP code of the predicted
#'          starting program}
#'    }
#' @family cip-data
"fye_start"

# -------------------------------------------------------------------

#' Case-study programs
#'
#' Data frame of 6-digit CIP codes and custom program names for Civil,
#' Electrical, Industrial, and Mechanical Engineering programs
#' from midfielddata. Used in the case study developed in the vignettes.
#'
#' Some program names have been shortened for convenience when creating
#' graphs.
#'
#' @format \code{data.table} with 12 rows and 2 columns keyed by the
#' 6-digit CIP code. The variables are:
#' \describe{
#'   \item{cip6}{Character 6-digit code representing "specific instructional
#'        programs" (US National Center for Education Statistics)}
#'   \item{program}{Program name assigned for grouping, summarizing,
#'   and joining}
#' }
#' @family case-study-data
"study_programs"

# -------------------------------------------------------------------

#' Case-study students
#'
#' Data frame of student IDs and program codes of students ever enrolled
#' in the Civil, Electrical, Industrial, and Mechanical Engineering programs
#' from midfielddata.
#'
#' Data have been subset for data sufficiency. Does not include predicted
#' starting programs for FYE students.
#'
#' @format \code{data.table} with 8219 rows and 2 columns keyed by
#' student ID. The variables are:
#' \describe{
#'   \item{mcid}{Character, anonymized student identifier}
#'   \item{cip6}{Character 6-digit code representing "specific instructional
#'        programs" (US National Center for Education Statistics)}
#' }
#' @family case-study-data
"study_students"

# -------------------------------------------------------------------

#' Case-study stickiness results
#'
#' Stickiness metric results for Civil, Electrical,
#' Industrial, and Mechanical Engineering programs from midfielddata. Results
#' are grouped by program, race/ethnicity, and sex. Used in the case study
#' developed in the vignettes.
#'
#' Stickiness of a program is the ratio of the number of students graduating
#' from a program to the number of students ever enrolled in the program.
#'
#' With a quantitative response value for each combination of levels of two
#' categorical variables, these are multiway data. However, some responses
#' are NA where observations didn't exist or were removed because of small
#' population size.
#'
#' Data have also been subset to remove ambiguous levels of race/ethnicity.
#'
#' @format \code{data.table} with 31 rows and 3 columns keyed by
#' program, race/ethnicity, and sex.
#' \describe{
#'  \item{program}{Character, instructional programs selected for study}
#'  \item{race_sex}{Character, student race/ethnicity and sex}
#'  \item{stick}{Numerical, program stickiness, a persistence metric}
#' }
#' @family case-study-data
"study_stickiness"

# -------------------------------------------------------------------

#' Case-study graduation rate results
#'
#' Graduation rate metric results for Civil, Electrical,
#' Industrial, and Mechanical Engineering programs from midfielddata. Results
#' are grouped by program, race/ethnicity, and sex. Used in the case study
#' developed in the vignettes.
#'
#' Graduation rate of a program is fraction of students starting in a
#' program who graduate in that program.
#'
#' Data have also been subset to remove ambiguous levels of race/ethnicity.
#'
#' @format \code{data.table} with 32 rows and 3 columns keyed by
#' program, race/ethnicity, and sex.
#' \describe{
#'  \item{program}{Character, instructional programs selected for study}
#'  \item{race_sex}{Character, student race/ethnicity and sex}
#'  \item{grad_rate}{Numerical, program graduation rate, a persistence metric}
#' }
#' @family case-study-data
"study_grad_rate"

# -------------------------------------------------------------------

#' Student data for examples
#'
#' A small subset by row and column of the MIDFIELD student table
#' for use in package examples.
#'
#' @format \code{data.table} with 100 rows and 6 columns keyed by
#' student ID.
#' \describe{
#'  \item{mcid}{Character, anonymized student identifier}
#'  \item{institution}{Character, anonymized institution name, e.g.,
#'       Institution A, Institution B, etc.}
#'  \item{transfer}{Character, stating whether the student is a First-Time in
#'       College students or a First-Time Transfer student}
#'  \item{hours_transfer}{Numeric, transfer hours accepted at the institution}
#'  \item{race}{Character, race/ethnicity as self-reported by the student,
#'       e.g., Asian, Black, Hispanic/LatinX, etc.}
#'  \item{sex}{character, sex as self-reported by the student, values are
#'       Female, Male, and Unknown}
#' }
#' @family toy-data
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
#'  \item{mcid}{Character, anonymized student identifier}
#'  \item{institution}{Character, anonymized institution name, e.g.,
#'       Institution A, Institution B, etc.}
#'  \item{term}{character, academic year and term, format YYYYT}
#'  \item{abbrev}{character, course alpha identifier, e.g. ENGR, MATH,
#'  ENGL, composite key (see id)}
#'  \item{number}{character, course numeric identifier, e.g. 101, 3429,
#'  composite key (see id)}
#'  \item{grade}{character, course grade, e.g., A+, A, A-, B+, I, NG, etc.}
#' }
#' @family toy-data
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
#'  \item{mcid}{Character, anonymized student identifier}
#'  \item{institution}{Character, anonymized institution name, e.g.,
#'       Institution A, Institution B, etc.}
#'  \item{term}{character, academic year and term, format YYYYT}
#'  \item{cip6}{character, 6-digit CIP code of program in which a student
#'  is enrolled in a term}
#'  \item{level}{character, 01 Freshman, 02 Sophomore, etc.}
#'  \item{hours_term}{numeric, credit hours earned in the term}
#' }
#' @family toy-data
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
#'  \item{mcid}{Character, anonymized student identifier}
#'  \item{institution}{Character, anonymized institution name, e.g.,
#'       Institution A, Institution B, etc.}
#'  \item{term}{character, academic year and term, format YYYYT, in which
#'  a student completes their program}
#'  \item{cip6}{character, 6-digit CIP code of program in which a student
#'  earns a degree}
#'  \item{degree}{character, type of degree awarded, e.g., Bachelor's
#'  Degree, Bachelor of Arts, Bachelor of Science, etc.}
#' }
#' @family toy-data
"toy_degree"

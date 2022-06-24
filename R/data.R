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

#' Case-study observations starting pool
#' 
#' An intermediate result provided for the convenience of vignette users. 
#' Data from the midfielddata package is processed to obtain observations 
#' of students ever enrolled in the case study programs of Civil, Electrical, 
#' Industrial/Systems, and Mechanical Engineering without filtering for 
#' data sufficiency or timely completion. Keyed by student ID. 
#'
#' @format \code{data.table} with 161,696 rows and 2 columns keyed by ID.
#' 
#' \describe{
#'
#'  \item{mcid}{Character, anonymized student identifier}
#'
#'  \item{cip6}{Character, 6-digit CIP codes of programs in which students
#'  are ever enrolled.}
#'
#' }
#'
#' @family case-study-data
#'
"study_starting_pool"

# -------------------------------------------------------------------

#' Case-study stickiness observations
#' 
#' An intermediate result provided for the convenience of vignette users. 
#' Data from the midfielddata package is processed to obtain observations of
#' students ever enrolled in, and those graduating in timely fashion from,
#' the case study programs of Civil, Electrical, Industrial/Systems, and 
#' Mechanical Engineering. Keyed by student ID. 
#'
#' @format \code{data.table} with 11212 rows and 5 columns keyed by ID.
#' 
#' \describe{
#'
#'  \item{mcid}{Character, anonymized student identifier}
#'
#'  \item{race}{Character, race/ethnicity as self-reported by the student, 
#'  e.g., Asian, Black, Hispanic/LatinX, etc.}
#'  
#'  \item{sex}{Character, sex as self-reported by the student, 
#'  values are Female, Male, and Unknown}
#'  
#'  \item{program}{Character, abbreviation indicating a program the 
#'  student completed}
#'  
#'  \item{group}{Character, indicating the grouping (\code{ever} or 
#'  \code{grad}) to which the student belongs.} 
#'
#' }
#'
#' @family case-study-data
#'
"study_stickiness_observ"




# -------------------------------------------------------------------

#' Case-study stickiness results
#'
#' An intermediate result provided for the convenience of vignette users. 
#' Longitudinal stickiness results for Civil, Electrical, Industrial, and
#' Mechanical Engineering programs from midfielddata. Results are keyed by
#' program, race/ethnicity, and sex.
#'
#' Longitudinal stickiness is the ratio of the number of students graduating
#' from a program to the number of students ever enrolled in the program over
#' the time span of available data.
#'
#' @format \code{data.table} with 33 rows and 6 columns keyed by
#' program, race/ethnicity, and sex.
#' \describe{
#'
#'   \item{program}{Character, program name assigned for grouping and
#'   summarizing and for display in graphs and tables.}
#'
#'  \item{race}{Character, race/ethnicity as self-reported by the student,
#'  e.g., Asian, Black, Hispanic/LatinX, etc.}
#'
#'  \item{sex}{Character, sex as self-reported by the student, values are
#'  Female, Male.}
#'
#'  \item{ever}{Numerical, number of students ever enrolled in the program,
#'  after accounting for data sufficiency and timely completion.}
#'
#'  \item{grad}{Numerical, number of students completing a program, after
#'  accounting for data sufficiency and timely completion.}
#'
#'  \item{stick}{Numerical, program stickiness, the ratio of the number of
#'  students completing a program to the number of students ever enrolled
#'  in the program.}
#'
#' }
#'
#' @family case-study-data
#'
"study_stickiness"

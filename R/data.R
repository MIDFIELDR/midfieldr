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

#' Case-study programs
#'
#' Data frame of 6-digit CIP codes and custom program names for Civil,
#' Electrical, Industrial, and Mechanical Engineering programs
#' from midfielddata. Used in the case study developed in the vignettes.
#'
#' Program names have been shortened for convenience when creating
#' graphs and tables.
#'
#' @format \code{data.table} with 12 rows and 2 columns keyed by the
#' 6-digit CIP code. The variables are:
#' \describe{
#'
#'   \item{cip6}{Character, 6-digit code of a program.}
#'
#'   \item{program}{Character, program name assigned for grouping and
#'   summarizing and for display in graphs and tables.}
#'
#' }
#'
#' @family case-study-data
#'
"study_program"

# -------------------------------------------------------------------

#' Case-study students
#'
#' Data frame of student attributes in the Civil, Electrical, Industrial,
#' and Mechanical Engineering programs from midfielddata. These data are
#' subset for data sufficiency and can be used as the starting point for
#' different persistence metrics such as stickiness or graduation rate.
#'
#' @format \code{data.table} with 8219 rows and 8 columns keyed by
#' student ID. The variables are:
#' \describe{
#'
#'   \item{mcid}{Character, de-identified student ID.}
#'
#'   \item{institution}{Character, anonymized institution name, e.g.,
#'   Institution A, Institution B, etc.}
#'
#'   \item{cip6}{Character, 6-digit code of a program in which a student
#'   is enrolled.}
#'
#'   \item{program}{Character, program name assigned for grouping and
#'   summarizing and for display in graphs and tables.}
#'
#'   \item{race}{Character, race/ethnicity as self-reported by the student,
#'   e.g., Asian, Black, Hispanic/LatinX, etc.}
#'
#'   \item{sex}{Character, sex as self-reported by the student, values are
#'   Female, Male, and Unknown.}
#'
#'   \item{timely_term}{Character, the last academic term in which program
#'   completion would be considered timely for a given student,
#'   format YYYYT.}
#'
#'   \item{data_sufficiency}{Logical, indicating whether the available data
#'   include a sufficient range of years to justify including a student in
#'   an analysis. Because the data sufficiency criterion has already been
#'   evaluated, the values should all be TRUE.}
#'
#' }
#'
#' @seealso \code{\link{add_timely_term}} and
#' \code{\link{add_data_sufficiency}}
#'
#' @family case-study-data
"study_student"

# -------------------------------------------------------------------

#' Case-study stickiness results
#'
#' Longitudinal stickiness results for Civil, Electrical, Industrial, and
#' Mechanical Engineering programs from midfielddata. Results are keyed by
#' program, race/ethnicity, and sex. Used in the case study developed in the
#' vignettes.
#'
#' Longitudinal stickiness is the ratio of the number of students graduating
#' from a program to the number of students ever enrolled in the program over
#' the time span of available data.
#'
#' Data are subset to satisfy the data sufficiency criterion and some
#' graduates are reclassified as non-completers to satisfy the timely
#' completion criterion. Data are also subset to remove groups with 10 or
#' fewer members in the \code{ever} column to reduce the risk of
#' identification.
#'
#' @format \code{data.table} with 38 rows and 6 columns keyed by
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
#'  Female, Male, and Unknown.}
#'
#'  \item{ever}{Numerical, number of students ever enrolled in the program,
#'  after subsetting for data sufficiency and small populations.}
#'
#'  \item{grad}{Numerical, number of students completing a program after
#'  subsetting for data sufficiency and accounting for timely completion.}
#'
#'  \item{stick}{Numerical, program stickiness, the ratio of the number of
#'  students completing a program to the number of students ever enrolled
#'  in the program.}
#'
#' }
#'
#' @seealso \code{\link{add_data_sufficiency}},
#' \code{\link{add_completion_timely}}
#'
#' @family case-study-data
#'
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
#'
#'  \item{program}{Character, instructional programs selected for study}
#'
#'  \item{race_sex}{Character, student race/ethnicity and sex}
#'
#'  \item{grad_rate}{Numerical, program graduation rate, a persistence metric}
#'
#' }
#'
#' @family case-study-data
#'
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
#'  \item{abbrev}{Character, course alpha identifier, e.g. ENGR, MATH,
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
#'  \item{term}{Character, academic year and term in which
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

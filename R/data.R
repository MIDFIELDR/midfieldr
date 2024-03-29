
# -------------------------------------------------------------------

#' Table of academic programs
#'
#' A data table based on the US National Center for Education Statistics (NCES),
#' Integrated Postsecondary Education Data System (IPEDS), 2010 CIP,
#' \url{http://nces.ed.gov/ipeds/cipcode/}. The data are codes and names for
#' 1582 instructional programs organized on three levels: a 2-digit series, a
#' 4-digit series, and a 6-digit series.
#'
#' The midfielddata taxonomy includes one non-IPEDS code (999999) for Undecided
#' or Unspecified, instances in which institutions reported no program
#' information or that students were not enrolled in a program. 
#' 
#' The MIDFIELD research database include CIPs for undergraduate pre-majors 
#' such as pre-med (511102), pre-law (220001), and pre-vet (511104).
#'
#' @format `data.table` with 1582 rows and 6 columns keyed by the 6-digit CIP
#'   code:
#' 
#' \describe{
#'
#'   \item{`cip6`}{Character 6-digit code representing "specific
#'   instructional programs" (US National Center for Education Statistics).}
#'
#'   \item{`cip6name`}{Character program name at the 6-digit level}
#'
#'   \item{`cip4`}{Character 4-digit code (the first 4 digits of `cip6`)
#'   representing "intermediate groupings of programs that have
#'   comparable content and objectives."}
#'
#'   \item{`cip4name`}{Character program name at the 4-digit level.}
#'
#'   \item{`cip2`}{Character 2-digit code (the first 2 digits of `cip6`)
#'   representing "the most general groupings of related programs."}
#'
#'   \item{`cip2name`}{Character program name at the 2-digit level.}
#'
#' }
#'
#' @family cip-data
#'
"cip"

# -------------------------------------------------------------------

#' Starting program proxies for FYE students
#'
#' Proxies are the degree-granting engineering programs we estimate that
#' First-Year Engineering (FYE) students would have declared had they not been
#' required to enroll in FYE. Keyed by student ID. Proxies are provided for all
#' students in the midfielddata practice data who enroll in FYE in their first
#' term.
#'
#' The proxy variable contains 6-digit CIP codes of degree-granting engineering
#' programs, e.g., Electrical Engineering, Mechanical Engineering, etc., that
#' are substituted for the FYE CIP code when an analysis requires
#' degree-granting starting programs. The most common application is a
#' graduation rate calculation.
#'
#' The estimation is based on students' first post-FYE programs and a multiple
#' imputation suitable for categorical variables using the mice package. The
#' predictor variables are institution, race, and sex. The estimated variable is
#' the 6-digit CIP code of a degree-granting engineering program at their
#' institution.
#'
#' `fye_proxy` holds only for the practice data in midfielddata---these values
#' cannot be commingled with the MIDFIELD research database.
#'
#' @format `data.table` with 4623 rows and 2 columns keyed by student ID. The
#'   variables are:
#' 
#' \describe{
#'
#'   \item{`mcid`}{Character, de-identified student ID.}
#'
#'   \item{`proxy`}{Character, 6-digit CIP code of the estimated proxy
#'   program.}
#'
#'  }
#'
#' @family cip-data
#'
"fye_proxy"

# -------------------------------------------------------------------

#' Student data for examples
#'
#' Selected variables modeled on those in the `student` practice data for use in
#' package examples and articles. Sampled from an early version of the practice
#' data, the toy data are not a current practice data sample.
#'
#' @format `data.table` with 99 rows and 4 columns keyed by student ID.
#'
#' \describe{
#'
#'  \item{`mcid`}{Character, de-identified student ID.}
#'
#'  \item{`institution`}{Character, de-identified institution name, e.g.,
#'   Institution A, Institution B, etc.}
#'
#'  \item{`race`}{Character, race/ethnicity as self-reported by the student,
#'  e.g., Asian, Black, Latine, etc.}
#'
#'  \item{`sex`}{character, sex as self-reported by the student, possible
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
#' Selected variables modeled on those in the `course` practice data for use in
#' package examples and articles. Sampled from an early version of the practice
#' data, the toy data are not a current practice data sample.
#'
#' @format `data.table` with 4616 rows and 6 columns keyed by student ID.
#' 
#' \describe{
#'
#'  \item{`mcid`}{Character, anonymized student ID.}
#'
#'  \item{`institution`}{Character, de-identified institution name, e.g.,
#'       Institution A, Institution B, etc.}
#'
#'  \item{`term`}{Character, academic year and term, format YYYYT.}
#'
#'  \item{`abbrev`}{Character, course alphabetical identifier, e.g. ENGR, MATH,
#'  ENGL.}
#'
#'  \item{`number`}{Character, course numeric identifier, e.g. 101, 3429.}
#'
#'  \item{`grade`}{Character, course grade, e.g., A+, A, A-, B+, I, NG, etc.}
#'
#' }
#'
#' @family toy-data
#'
"toy_course"

# -------------------------------------------------------------------

#' Term data for examples
#'
#' Selected variables modeled on those in the `term` practice data for use in
#' package examples and articles. Sampled from an early version of the practice
#' data, the toy data are not a current practice data sample.
#'
#' @format `data.table` with 150 rows and 5 columns keyed by student ID.
#'
#' \describe{
#'
#'  \item{`mcid`}{Character, de-identified student ID.}
#'
#'  \item{`institution`}{Character, de-identified institution name, e.g.,
#'       Institution A, Institution B, etc.}
#'
#'  \item{`term`}{Character, academic year and term, format YYYYT.}
#'
#'  \item{`cip6`}{Character, 6-digit CIP code of program in which a student
#'  is enrolled in a term.}
#'
#'  \item{`level`}{Character, 01 Freshman, 02 Sophomore, etc. The equivalent 
#'   values in the current practice data are 01 First-Year, 02-Second Year, 
#'   etc.}
#'
#' }
#'
#' @family toy-data
#' 
"toy_term"

# -------------------------------------------------------------------

#' Degree data for examples
#'
#' Selected variables modeled on those in the `degree` practice data for use in
#' package examples and articles. Sampled from an early version of the practice
#' data, the toy data are not a current practice data sample.
#'
#' @format `data.table` with 65 rows and 4 columns keyed by student ID.
#' 
#' \describe{
#'
#'  \item{`mcid`}{Character, anonymized student ID.}
#'
#'  \item{`institution`}{Character, anonymized institution name, e.g.,
#'       Institution A, Institution B, etc.}
#'
#'  \item{`term_degree`}{Character, academic year and term in which
#'  a student completes their program, format YYYYT.}
#'
#'  \item{`cip6`}{Character, 6-digit CIP code of program in which a student
#'  earns a degree.}
#'
#' }
#'
#' @family toy-data
#'
"toy_degree"

# -------------------------------------------------------------------

#' Case-study program labels and codes
#'
#' Data table of program CIP codes and labels of the four programs of the case
#' study. Keyed by 6-digit CIPs. Provided for the convenience of vignette users.
#'
#' Starting with the midfieldr `cip` data set, we extracted the CIPs of the four
#' programs of the case study and assigned them a custom label to be used for
#' grouping and summarizing.
#'
#' @format `data.table` with 15 rows and 2 columns.
#' 
#' \describe{
#'
#'  \item{`cip6`}{Character, 6-digit CIP program codes.}
#'  
#'  \item{`program`}{Character, abbreviated labels for four engineering 
#'  programs. Values are "CE" (Civil Engineering), "EE" (Electrical 
#'  Engineering), "ISE" (Industrial/Systems Engineering), and  "ME" (Mechanical 
#'  Engineering).}
#'
#' }
#'
#' @family case-study-data
#'
"study_programs"

# -------------------------------------------------------------------

#' Case-study observations
#'
#' Data table of post-processed observations of students ever enrolled in, and
#' students graduating from, the four programs of the case study. Keyed by
#' student ID. Provided for the convenience of vignette users.
#'
#' Starting with the case-study starting pool of students ever enrolled in the
#' four programs of the study (Civil, Electrical, Industrial/Systems, and
#' Mechanical Engineering), we filtered the data for data sufficiency, degree
#' seeking, program, and timely completion.
#'
#' A data frame of "ever enrolled" and a data frame of "timely graduates" were
#' bound using shared column names and are distinguished in the `bloc` variable.
#' This data structure facilitates grouping and summarizing by race, sex,
#' program, and group.
#'
#' @format `data.table` with 8917 rows and 5 columns.
#' 
#' \describe{
#'
#'  \item{`mcid`}{Character, anonymized student identifier}
#'
#'  \item{`race`}{Character, self-reported race/ethnicity.}
#'
#'  \item{`sex`}{Character, self-reported sex.}
#'  
#'  \item{`program`}{Character, academic program label.}
#'  
#'  \item{`bloc`}{Character, indicating the grouping (`ever_enrolled` or 
#'  `graduates`) to which an observation belongs.} 
#'
#' }
#'
#' @family case-study-data
#'
"study_observations"

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
#' filtered for data sufficiency, degree seeking, and timely completion.
#'
#' @format `data.table` with 50 rows and 6 columns.
#'
#' \describe{
#'
#'  \item{`program`}{Character, academic program label.}
#'
#'  \item{`race`}{Character, self-reported race/ethnicity.}
#'
#'  \item{`sex`}{Character, self-reported sex.}
#'
#'  \item{`ever_enrolled`}{Numerical, number of students ever enrolled in a 
#'  program.}
#'
#'  \item{`graduates`}{Numerical, number of students completing a program.}
#'
#'  \item{`stickiness`}{Numerical, program stickiness, the ratio `graduates` to
#'  `ever_enrolled`, in percent.}
#'
#' }
#'
#' @family case-study-data
#' 
"study_results"

# -------------------------------------------------------------------

#' Baseline ID bloc to start a typical analysis
#'
#' Data frame of IDs after processing the practice data for data sufficiency and
#' degree seeking. Provides a convenient bloc to start many of the analysis
#' illustrated in the package articles.
#'
#' @format `data.table` with 76875 rows and 1 column.
#'
#' \describe{
#'
#'  \item{`mcid`}{Character, anonymized student identifier}
#'
#' }
#'
#' @family case-study-data
#' 
"baseline_mcid"

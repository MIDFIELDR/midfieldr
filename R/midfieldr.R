#' Undergraduate Student Records For Longitudinal Research
#' \Sexpr[results=hide]{load("data/data_bits.rda")}
#'
#' A package for investigating a sample from the MIDFIELD database. The data  comprise student records from registrars at participating US universities, including demographic, term, course, and degree information for \Sexpr{data_bits[["obs_student"]]} undergraduate students from \Sexpr{data_bits[["year_min"]]} to \Sexpr{data_bits[["year_max"]]}.
#'
#'In our examples illustrating how to use \pkg{midfieldr} tools and datasets, the findings are generally disaggregated or conditioned by instructional program and student sex and race/ethnicity.  Sex and race/ethnicity categories are limited to those reported by the US institutions contributing to the MIDFIELD database.
#'
#' Datasets are provided with \pkg{midfieldr} plus three data packages: \pkg{midfieldstudents}, \pkg{midfieldterms}, and \pkg{midfieldcourses}.
#'
#' @section Data:
#' \describe{
#'
#'   \item{\code{midfieldstudents}}{\href{https://github.com/MIDFIELDR/midfieldstudents}{midfieldstudents} package. Demographic data for \Sexpr{data_bits[["obs_student"]]} students. Each observation is a unique student.}
#'
#'   \item{\code{midfieldterms}}{\href{https://github.com/MIDFIELDR/midfieldterms}{midfieldterms} package. Academic term data for \Sexpr{data_bits[["obs_student"]]} students. Each observation is one term for one student, yielding \Sexpr{round(data_bits[["obs_term"]]/1e+6, 1)} M observations.}
#'
#'   \item{\code{midfieldcourses}}{\href{https://github.com/MIDFIELDR/midfieldcourses}{midfieldcourses} package. Academic course data for \Sexpr{data_bits[["obs_student"]]}. Each observation is one course for one student, yielding \Sexpr{round(data_bits[["obs_course"]]/1e+6, 1)} M observations.}
#'
#'   \item{\code{midfielddegrees}}{\href{https://github.com/MIDFIELDR/midfieldstudents}{midfieldstudents} package. Graduation data for  \Sexpr{data_bits[["obs_degree"]]} students receiving degrees. Each observation is a unique student. }
#'
#'   \item{\code{cip}}{\href{https://github.com/MIDFIELDR/midfieldr}{midfieldr} package. A dataset of program codes and names of academic fields of study. Each of the 1552 observations is one program at the CIP 6-digit level.}
#'
#' }
#'
#' @section Functions:
#' midfieldr provides functions to access, manipulate, and graph the student record data.
#'
#' \describe{
#'
#'   \item{\code{cip_filter()}}{Filter a data frame of Classification of Instructional Programs (CIP) codes to return the rows that match conditions.}
#'
#'   \item{\code{join_demographics()}}{Add variables \code{ETHNIC} and \code{SEX} from the \code{student} dataset to a data frame.}
#'
#'   }
#'
#' @source Data provided by the MIDFIELD project: \url{https://engineering.purdue.edu/MIDFIELD}
#' @docType package
#' @name midfieldr
NULL

## addresses R CMD check warning "no visible binding"
if (getRversion() >= "2.15.1") {
	utils::globalVariables(c(".", ".x",  "CIP2", "CIP4", "CIP6", "student", "MID", "ETHNIC", "SEX", "BEGINYEAR", "INSTITUTION", "TCIP", "TCIP2", "TCIP3", "TCIPN", "TTERM", "TYEAR", "rcb_colors", "rcb_name", "rcb_code"))
}

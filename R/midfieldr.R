#' Undergraduate Student Records For Longitudinal Research
#'
#'A package for investigating a sample from the MIDFIELD database. The data  comprise student records from registrars at participating US universities, including demographic, term, course, and degree information for 165,000 undergraduate students from 1990 to 2016.
#'
#'In our examples illustrating how to use \pkg{midfieldr} tools and datasets, the findings are generally disaggregated or conditioned by instructional program and student sex and race/ethnicity.  Sex and race/ethnicity categories are limited to those reported by the US institutions contributing to the MIDFIELD database.
#'
#' Datasets are provided with \pkg{midfieldr} plus three data packages: \pkg{midfieldstudent}, \pkg{midfieldterm}, and \pkg{midfieldcourse}.
#'
#' @section Data:
#' \describe{
#'
#'   \item{\code{student}}{\href{https://github.com/MIDFIELDR/midfieldstudent}{midfieldstudent} package. Demographic data for 165,000 students. Each observation is a unique student.}
#'
#'   \item{\code{term}}{\href{https://github.com/MIDFIELDR/midfieldterm}{midfieldterm} package. Academic term data for 165,000 students. Each observation is one term for one student, yielding 1.1 M observations.}
#'
#'   \item{\code{course}}{\href{https://github.com/MIDFIELDR/midfieldcourse}{midfieldcourse} package. Academic course data for 165,000 students. Each observation is one course for one student, yielding 5.4 M observations.}
#'
#'   \item{\code{degree}}{\href{https://github.com/MIDFIELDR/midfieldstudent}{midfieldstudent} package. Graduation data for 90,000 students receiving degrees. Each observation is a unique student. }
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
	utils::globalVariables(c(".", ".x",  "CIP2", "CIP4", "CIP6", "student", "MID", "ETHNIC", "SEX", "BEGINYEAR", "INSTITUTION", "TCIP", "TCIP2", "TCIP3", "TCIPN", "TTERM", "TYEAR"))
}

#' Undergraduate Student Records For Longitudinal Research
#'
#' A package for investigating a sample from the MIDFIELD database. The data  comprise student records from registrars at participating US universities, including demographic, term, course, and degree information for 98,064 undergraduate students from 1987 to 2016.
#'
#'In our examples illustrating how to use \pkg{midfieldr} tools and datasets, the findings are generally disaggregated or conditioned by instructional program and student sex and race/ethnicity.  Sex and race/ethnicity categories are limited to those reported by the US institutions contributing to the MIDFIELD database.
#'
#' Datasets are provided with \pkg{midfieldr} plus four data packages: \pkg{midfieldstudents}, \pkg{midfieldcourses}, \pkg{midfieldterms}, and \pkg{midfielddegrees}.
#'
#' @section Data:
#' \describe{
#'
#'   \item{\code{cip}}{\href{https://github.com/MIDFIELDR/midfieldr}{midfieldr} package. A dataset of program codes and names of academic fields of study. Each of the 1544 observations is one program at the CIP 6-digit level.}
#'
#'   \item{\code{midfieldstudents}}{\href{https://github.com/MIDFIELDR/midfieldstudents}{midfieldstudents} package. Demographic data for 98,064 students. Each observation is a unique student.}
#'
#'   \item{\code{midfieldcourses}}{\href{https://github.com/MIDFIELDR/midfieldcourses}{midfieldcourses} package. Academic course data for 98,064 students. Each observation is one course for one student, yielding 3.5 M observations.}
#'
#'   \item{\code{midfieldterms}}{\href{https://github.com/MIDFIELDR/midfieldterms}{midfieldterms} package. Academic term data for 98,064 students. Each observation is one term for one student, yielding 723,886 observations.}
#'
#'   \item{\code{midfielddegrees}}{\href{https://github.com/MIDFIELDR/midfielddegrees}{midfielddegrees} package. Graduation data for 49,414 students receiving degrees. Each observation is a unique student. }
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
	utils::globalVariables(c(".", ".x", "CIP2", "CIP4", "CIP6", "student", "MID", "ETHNIC", "SEX", "BEGINYEAR", "INSTITUTION", "TCIP", "TCIP2", "TCIP3", "TCIPN", "TTERM", "TYEAR", "rcb_colors", "rcb_name", "rcb_code"))
}

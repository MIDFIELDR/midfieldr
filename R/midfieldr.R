#' @importFrom Rdpack reprompt
NULL

#' \code{midfieldr}: Tools for Student Records Research
#'
#' For investigating undergraduate student records in the MIDFIELD database
#' that comprises data from registrar's at participating US institutions.
#' Designed to work with MIDFIELD-structured data, providing
#' tools for accessing and manipulating student, term, course, and
#' degree information. Data are available for 97,640 undergraduate students
#' from 1987 to 2016.
#'
#' A typical midfieldr workflow might include:
#'
#' \itemize{
#'   \item \code{get_cip()} search the CIP data set for program codes
#'   \item \code{label_programs()} isolate and label specific programs to study
#'   \item \code{get_enrollees()} gather students ever enrolled in the programs
#'   \item \code{completion_feasible()} subset students for 6-year
#'   completion feasibility
#'   \item \code{get_graduates()} gather students graduating from the programs
#'   \item \code{get_race_sex()} obtain student sex and race/ethnicity
#'   \item \code{order_multiway()} condition multiway data for graphing
#' }
#'
#' Operations such subsetting, joining, and grouping and summarizing
#' are performed using one's preferred tools in base R or more advanced systems
#' such as dplyr or data.table. The examples use base R for data carpentry
#' and ggplot2 for graphs.
#'
#' @section Data:
#'
#' Instructional program data is provided in \code{cip}, a data frame of names
#' and codes of academic programs from the 2010 IPEDS Classification of
#' Instructional Programs (CIP) by the US Department of Education.
#'
#' Student record data is provided in a companion data package midfielddata.
#' Data are provided in four datasets: \code{midfieldstudents},
#' \code{midfieldcourses}, \code{midfieldterms}, and \code{midfielddegrees}.
#'
#' @section For more information:
#'
#' \itemize{
#'   \item vignette(package = 'midfieldr')
#'   \item website \href{https://midfieldr.github.io/midfieldr/}{midfieldr}
#'   \item website
#'   \href{https://midfieldr.github.io/midfielddata/}{midfielddata}
#'   \item website \href{https://engineering.purdue.edu/MIDFIELD}{MIDFIELD}
#' }
#'
#' @docType package
#' @name midfieldr
#' @family package
NULL

# binding
if (getRversion() >= "2.15.1") {
  utils::globalVariables(c(".", ":=", "..cols_we_want"))
}

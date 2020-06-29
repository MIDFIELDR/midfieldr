#' @importFrom Rdpack reprompt
NULL

#' Tools for Student Records Research
#'
#' A package for investigating a data sample from the MIDFIELD database. The
#' data comprise student records from registrars at participating US
#' universities, including demographic, term, course, and degree information
#' for 97,640 undergraduate students from 1987 to 2016.
#'
#' This package provides functions to access, manipulate, and graph student
#' record data. To illustrate the workflow, we would use these functions
#' to compute and display a persistence metric such as "stickiness":
#'
#' \itemize{
#'   \item \code{cip_filter()} to filter programs from the CIP data.
#'   \item \code{cip6_select()} to select 6-digit CIPs and add custom labels.
#'   \item \code{gather_ever()} to gather students ever enrolled.
#'   \item \code{gather_grad()} to gather graduating students.
#'   \item \code{race_sex_join()} to join student sex and race/ethnicity.
#'   \item dplyr package (or equivalent) to group, summarize, join, and
#'   compute a persistence metric.
#'   \item \code{multiway_order()} to prepare the results for graphing.
#'   \item ggplot2 package (or equivalent) to graph the results.
#' }
#'
#' To learn about these and other functions in detail, start with the
#' vignettes: \code{browseVignettes(package = "midfieldr")}.
#'
#' @section Data:
#'
#' Instructional program data is provided in \code{cip}, a data frame of names
#' and codes of academic programs from the 2010 IPEDS Classification of
#' Instructional Programs (CIP) by the US Department of Education.
#'
#' Student record data is provided in the companion data package,
#' \href{https://github.com/MIDFIELDR/midfielddata}{midfielddata}. Data
#' are provided in four datasets: \code{midfieldcourses},
#' \code{midfielddegrees}, \code{midfieldstudents}, and  \code{midfieldterms}.
#'
#' @source Data provided by the MIDFIELD project:
#' \url{https://engineering.purdue.edu/MIDFIELD}
#' @docType package
#' @name midfieldr
#' @family package
NULL

## addresses R CMD check warning "no visible binding"
if (getRversion() >= "2.15.1") {
  utils::globalVariables(c(
    ".", ".x", "rcb_colors", "midfielddegrees", "midfieldstudents",
    "midfieldterms", "midfieldcourses", "cip", "cip_bio_sci", "cip_engr",
    "cip_math_stat", "cip_other_stem", "cip_phys_sci", "cip_stem", "yyyyt",
    "n_digits"
  ))
}

#' @importFrom Rdpack reprompt
NULL

#' Tools for Undergraduate Student Records Research
#'
#' A package for investigating a data sample from the MIDFIELD database.
#' The data comprise student records from registrars at participating US
#' universities, including demographic, term, course, and degree information
#' for 97,640 undergraduate students from 1987 to 2016.
#'
#' This package provides functions to access, manipulate, and graph student
#' record data. For example, to examine graduation rates, we use the series of
#' functions:
#'
#' \itemize{
#'   \item \code{cip_filter()} to select programs
#'   \item \code{cip_label()} to add custom program labels
#'   \item \code{gather_start()} to gather starting students
#'   \item \code{gather_grad()} to gather graduating students
#'   \item \code{race_sex_join()} to join student sex and race
#'   \item \code{zero_fill()} to fill zero for missing combinations
#'   \item \code{dplyr::group()} and \code{summarize()} to count students
#'   \item \code{tally_gradrate()} to compute the metric
#'   \item \code{multiway_order()} to prepare the results for graphing
#'   \item \code{ggplot2::ggplot()} to graph the metric
#' }
#'
#' To learn about these and other functions, start with the vignettes:
#' \code{browseVignettes(package = "midfieldr")}.
#'
#' We generally group our findings by instructional
#' program and student sex and "race" as defined by the participating US
#' institutions for the years spanned in the sample data.
#'
#' Instructional program data is provided in \code{cip}, a data frame of names
#' and codes of academic programs from the 2010 IPEDS Classification of
#' Instructional Programs (CIP) by the US Department of Education.
#'
#' Student record data is provided in four data packages:
#' \href{https://github.com/MIDFIELDR/midfieldstudents}{midfieldstudents},
#' \href{https://github.com/MIDFIELDR/midfieldcourses}{midfieldcourses},
#' \href{https://github.com/MIDFIELDR/midfieldterms}{midfieldterms}, and
#' \href{https://github.com/MIDFIELDR/midfielddegrees}{midfielddegrees}.
#'
#' @source Data provided by the MIDFIELD project:
#' \url{https://engineering.purdue.edu/MIDFIELD}
#' @docType package
#' @name midfieldr
NULL

## addresses R CMD check warning "no visible binding"
if (getRversion() >= "2.15.1") {
  utils::globalVariables(c(
    ".", ".x", "CIP2", "CIP4", "CIP6", "student", "ID",
    "race", "sex", "rcb_colors", "rcb_name", "rcb_code",
    "midfielddegrees", "midfieldstudents", "med",
    "midfieldterms", "midfieldcourses", "institution",
    "term_degree", "program", "degree",
    "cip", "cip_bio_sci", "cip_engr", "cip_math_stat",
    "cip_other_stem", "cip_phys_sci", "cip_stem",
    "n_prog"
  ))
}

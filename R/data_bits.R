#' Characteristic numbers describing the midfieldr datasets
#'
#' A vector of named numbers describing characteristics of the midfieldr
#' datasets such as the number of observations or statistical summary values.
#'
#' The purpose of creating this small dataset is to have handy the named numbers
#' without loading the midfieldr datasets to reduce execution times in vignettes.
#'
#' @format A vector of named numbers
#' \describe{
#'
#'   \item{obs_cip}{The number of observations in \code{cip}}
#'   \item{obs_course}{The number of observations in \code{midfieldcourses}}
#'   \item{obs_degree}{The number of observations in \code{midfielddegrees}}
#'   \item{obs_student}{The number of observations in \code{midfieldstudents}}
#'   \item{obs_term}{The number of observations in \code{midfieldterms}}
#'
#'   \item{size_cip}{The amount of memory occupied by \code{cip}}
#'   \item{size_course}{The amount of memory occupied by \code{midfieldcourses}}
#'   \item{size_degree}{The amount of memory occupied by \code{midfielddegrees}}
#'   \item{size_student}{The amount of memory occupied by \code{midfieldstudents}}
#'   \item{size_term}{The amount of memory occupied by \code{midfieldterms}}
#'
#'   \item{var_cip}{The number of variables in \code{cip}}
#'   \item{var_course}{The number of variables in \code{midfieldcourses}}
#'   \item{var_degree}{The number of variables in \code{midfielddegrees}}
#'   \item{var_student}{The number of variables in \code{midfieldstudents}}
#'   \item{var_term}{The number of variables in \code{midfieldterms}}
#'
#'   \item{year_max}{The most recent year in \code{midfielddegrees}}
#'   \item{year_min}{The earliest year in \code{midfieldstudents}}
#'
#' }
"data_bits"

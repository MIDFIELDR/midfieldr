#' Deprecated functions in midfieldr
#'
#' These functions were deprecated in midfieldr 1.0.4.
#'
#' \describe{
#'
#'  \item{`add_completion_status()`}{is deprecated in favor of 
#'  [`completion_status()`]. Name change plus preserves data frame class.}
#'
#'  \item{`filter_cip()`}{is deprecated in favor of 
#'  [`filter_programs()`]. The new function is similar but with the CIP 
#'  data frame as the first argument, enabling chained functions like those 
#'  encountered using dplyr and friends.}
#'
#'  \item{`select_required()`}{is deprecated in favor of 
#'  [select_records()]. The new functionality is similar but with 
#'  exact matching to the default column names plus preserving data 
#'  frame class.}
#'
#' }
#'
#'
#' @name midfieldr-deprecated
NULL

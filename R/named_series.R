#' Named series of CIP  codes
#'
#' Collections of 6-digit CIP codes for groups of programs.
#'
#' The groups of programs include Engineering, Physical Sciences,
#'
#' Using the US National Science Foundation's definition of Science, Technology, Engineering, and Mathematics (STEM) programs, we have collected CIP codes and program names for STEM, Mathematics and Statistics, Engineering, Physical Sciences, etc.
#'
#'  A named series is used as a series argument in \code{filter_cip()}.
#'
#' @format A character vector of 6-digit CIP codes
#'
#' @name named_series
#' @examples
#' engr
#' filter_cip(engr)
NULL

#' @rdname named_series
"bio_sci"
#' @rdname named_series
"engr"
#' @rdname named_series
"math_stat"
#' @rdname named_series
"other_stem"
#' @rdname named_series
"phys_sci"
#' @rdname named_series
"stem"

#' Named series of 6-digit CIP  codes
#'
#' Collections of 6-digit CIP codes denoting groups of programs used as the
#' series argument in \code{cip_filter()}.
#'
#' While the 2-digit and 4-digit CIP series represent convenient groupings of
#' programs, e.g., History (CIP series 54) or Civil Engineering (CIP series 1408),
#' some groups of programs such as Science, Technology, Engineering, and
#' Mathematics (STEM) programs are comprised of programs from different 2-digit
#' series.
#'
#' The midfieldr `named_series` datasets are collections of 6-digit codes for
#' groups of programs from multiple 2-digit series, such as STEM programs, as
#' well as for programs in a single 2-digit series such as Engineering.
#'
#' The classification of STEM programs is from the US National Science
#' Foundation (NSF).
#'
#' \describe{
#'
#' \item{\code{bio_sci}}{Biological and Biomedical Sciences (CIP 26 series)}
#' \item{\code{engr}}{Engineering (CIP 14 series)}
#' \item{\code{math_stat}}{Mathematics and Statistics (CIP 27 series)}
#' \item{\code{other_stem}}{All 6-digit CIP codes for STEM programs excluding
#' series 14, 26, 27, and 40.}
#' \item{\code{phys_sci}}{Physical Sciences (CIP 40 series)}
#' \item{\code{stem}}{All 6-digit CIP codes for STEM programs. The concatenation
#' of all codes in the named series \code{bio_sci}, \code{engr}, \code{math_stat},
#' \code{other_stem}, and \code{phys_sci}.}
#'
#' }
#'
#' @name named_series
#' @format A character vector of 6-digit CIP codes
#' @source NSF STEM programs: \url{https://www.ice.gov/sites/default/files/documents/Document/2016/stem-list.pdf}
#' @examples
#' engr
#' cip_filter(engr)
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

#' Classification of Instructional Programs (CIP) data
#'
#' @description A dataset of program codes and names of academic fields of study from the Classification of Instructional Programs (CIP) standardized by the US Department of Education.
#'
#' The CIP taxonomy is organized on three levels: a 2-digit series, a 4-digit series, and a 6-digit series. This dataset has 48 unique 2-digit codes, 411 unique 4-digit codes, and 1543 unique 6-digit codes.
#'
#' The MIDFIELD taxonomy includes three entries not in the standard CIP data, "NonIPEDS - Undecided/Unspecified" encoded as "99", "9999", and "999999".
#'
#' @format A data frame (tibble) with 1544 observations and 6 variables. Each observation is a unique program.
#'
#' \describe{
#'
#'   \item{CIP2}{The 2-digit program code. A character variable.}
#'
#'   \item{PGRM2}{The name of the 2-digit instructional program. A character variable.}
#'
#'   \item{CIP4}{The 4-digit program code. A character variable.}
#'
#'   \item{PGRM4}{The name of the 4-digit instructional program. A character variable.}
#'
#'   \item{CIP6}{The 6-digit program code. A character variable.}
#'
#'   \item{PGRM6}{The name of the 6-digit instructional program. A character variable.}
#' }
#' @source \url{https://engineering.purdue.edu/MIDFIELD}
"cip"

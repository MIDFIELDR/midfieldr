#' Classification of Instructional Programs (CIP) data
#'
#' A dataset of codes and names for 1544 instructional programs organized on three levels: a 2-digit series, a 4-digit series, and a 6-digit series.
#'
#' As defined by the US National Center for Education Statistics, "The two-digit series represent the most general groupings of related programs. The four-digit series represent intermediate groupings of programs that have comparable content and objectives. The six-digit series, also referred to as six-digit CIP codes, represent specific instructional programs."
#'
#' Because 6-digit codes are used by institutions to report program information,  6-digit codes are also used in midfieldr datasets (\code{student}, \code{term}, \code{course}, and  \code{degree}) to encode program information.
#'
#' In addition to the standard codes and names, the midfieldr taxonomy includes the codes "99", "9999", and "999999", all named "NonIPEDS - Undecided/Unspecified", for instances in which institutions reported no program information or that students were not enrolled in a program (undecided).
#'
#' @format A tidy data frame (tibble) with 1544 observations and 6 variables. All variables are characters. An observation is a unique program.
#'
#' \describe{
#'
#'   \item{CIP2}{An instructional program's 2-digit code.}
#'
#'   \item{CIP2Name}{Name of a program at the 2-digit level.}
#'
#'   \item{CIP4}{An instructional program's 4-digit code.}
#'
#'   \item{CIP4Name}{Name of a program at the 4-digit level.}
#'
#'   \item{CIP6}{An instructional program's 6-digit code.}
#'
#'   \item{CIP6Name}{Name of a program at the 6-digit level.}
#' }
#' @source The MIDFIELD project (\url{https://engineering.purdue.edu/MIDFIELD}) provided the \code{cip} dataset, based on the 2010 codes provided by the US National Center for Education Statistics (\url{https://nces.ed.gov/ipeds/cipcode}). For detailed discussion of the CIP, see \url{https://nces.ed.gov/ipeds/cipcode/Files/Introduction_CIP2010.pdf}.
"cip"

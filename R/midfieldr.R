#' Undergraduate Student Records For Longitudinal Research
#'
#' @description A package for investigating a sample from the MIDFIELD database, a dataset compiled from registrar's student records from participating US universities. The sample data include demographic, term, course, and degree information for 165,000 undergraduate students from 1990 to 2016.
#'
#' @details The Multi-Institution Database for Investigating Engineering Longitudinal Development (MIDFIELD) was started with longitudinal studies of engineering students in mind (the "E" in MIDFIELD). However, the data comprise complete registrar's student records---any academic program at those institutions can be studied.
#'
#' @section Data:
#' Sample data from the MIDFIELD database are provided in 3 additional packages. The datasets are:
#'
#' \describe{
#'
#'   \item{\code{student}}{midfieldstudent package. Demographic data for 165,000 students. Each observation is a unique student.}
#'
#'   \item{\code{term}}{midfieldterm package. Academic term data for 165,000 students. Each observation is one term for one student, yielding 1.1 M observations.}
#'
#'   \item{\code{course}}{midfieldcourse package. Academic course data for 165,000 students. Each observation is one course for one student, yielding 5.4 M observations.}
#'
#'   \item{\code{degree}}{midfieldstudent package. Graduation data for 90,000 students receiving degrees. Each observation is a unique student. }
#'
#'   \item{\code{cip}}{midfieldr package. A dataset of program codes and names of academic fields of study. Each of the 1552 observations is one program at the CIP 6-digit level. \code{?cip} for more information.}
#'
#' }
#'
#' @docType package
#' @name midfieldr
NULL

## addresses R CMD check warning "no visible binding"
if (getRversion() >= "2.15.1") {
	utils::globalVariables(c(".", "GCIP", "GCIP2", "GCIP3", "GCIP_2", "GCIP_4", "GCIP_6", "MID", "MYEAR", "GYEAR", "GTERM", "ETHNIC", "SEX", "MTERM", "INSTITUTION", "TCIP", "TCIP_2", "TCIP_4", "TCIP_6", "CIP", "GRAD", "EVER", "STICK", "PEER_GROUP", "PROGRAM", "DEGREE", "GDESC", "GDESC2", "GDESC3", "GCODE", "GCODE2", "GCODE3"))
	}

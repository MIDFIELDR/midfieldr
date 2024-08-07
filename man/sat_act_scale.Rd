% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/data.R
\docType{data}
\name{sat_act_scale}
\alias{sat_act_scale}
\title{SAT-ACT conversion scale}
\format{
\code{data.table} with 28 rows and 4 columns:
\describe{
\item{\code{sat_upper}}{Numerical, total SAT, upper limit of range corresponding
to the ACT composite score.}
\item{\code{sat_equiv}}{Numerical, total SAT, value to use when converting ACT
score to a single SAT score.}
\item{\code{sat_lower}}{Numerical, total SAT, lower limit of range corresponding
to the ACT composite score.}
\item{\code{act_comp}}{Numerical, ACT composite score.}
}
}
\source{
ACT/SAT Concordance (2018) ACT Education Corp. \url{https://www.act.org/content/dam/act/unsecured/documents/ACT-SAT-Concordance-Tables.pdf}
}
\usage{
sat_act_scale
}
\description{
Data frame of SAT total scores and corresponding ACT composite scores.
Converting from SAT to ACT, a range of SAT scores convert to a single ACT
value. Converting from ACT to SAT, a single-value SAT equivalent is provided.
}
\seealso{
Other scales: 
\code{\link{grade_scale}}
}
\concept{scales}
\keyword{datasets}

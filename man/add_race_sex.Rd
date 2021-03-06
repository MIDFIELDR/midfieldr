% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/add_race_sex.R
\name{add_race_sex}
\alias{add_race_sex}
\title{Add columns for student race/ethnicity and sex}
\usage{
add_race_sex(dframe, midfield_student)
}
\arguments{
\item{dframe}{Data frame with required variable \code{mcid}.}

\item{midfield_student}{MIDFIELD \code{student} data table or equivalent
with required variables \code{mcid}, \code{race}, and \code{sex}.}
}
\value{
A \code{data.table}  with the following properties:
\itemize{
    \item Rows are not modified.
    \item Columns \code{race} and \code{sex} are added.
    \item Grouping structures are not preserved.
}
}
\description{
Add columns for students' self-reported race/ethnicity and sex using
student ID as the join-by variable. Obtains the information from the
MIDFIELD \code{student} data table or equivalent.
}
\details{
Existing columns with the same names as the added columns are overwritten.
}
\examples{
# Add race and sex to a data frame of graduates
dframe <- toy_degree[1:5, c("mcid", "cip6")]
add_race_sex(dframe, midfield_student = toy_student)


# Add race and sex to a data frame from the term table
dframe <- toy_term[21:26, c("mcid", "institution", "level")]
add_race_sex(dframe, midfield_student = toy_student)


# If present, existing race and sex columns are overwritten
# Using dframe from above,
DT1 <- add_race_sex(dframe, midfield_student = toy_student)
DT2 <- add_race_sex(DT1, midfield_student = toy_student)
all.equal(DT1, DT2)
}
\seealso{
Other add_*: 
\code{\link{add_completion_timely}()},
\code{\link{add_data_sufficiency}()},
\code{\link{add_institution}()},
\code{\link{add_timely_term}()}
}
\concept{add_*}

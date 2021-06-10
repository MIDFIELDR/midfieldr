% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/add_data_sufficiency.R
\name{add_data_sufficiency}
\alias{add_data_sufficiency}
\title{Add a column to evaluate data sufficiency}
\usage{
add_data_sufficiency(dframe, ..., mdata = NULL, details = NULL)
}
\arguments{
\item{dframe}{data frame with required variables
\code{institution} and \code{timely_term}}

\item{...}{not used, forces later arguments to be used by name}

\item{mdata}{MIDFIELD term data, default \code{midfielddata::term},
with required variables \code{institution} and \code{term}}

\item{details}{logical scalar to add columns reporting information on
which the evaluation is based, default FALSE}
}
\value{
A \code{data.table}  with the following properties:
\itemize{
    \item Rows are not modified
    \item Column \code{data_sufficiency} is added, column \code{inst_limit}
          is added optionally
    \item Grouping structures are not preserved
}
}
\description{
A column is added to a data frame indicating whether the data include a
sufficient number of years to justify including a student in an analysis
of student records. The new column is a logical variable (TRUE/FALSE
values).
}
\details{
Program completion is typically assessed over a given span of years after
admission. A student admitted too near the last term in the
available data should be excluded from analysis because the data
have insufficient span to fairly assess the student's record.

The data frame argument must include the \code{timely_term} column
obtained using the \code{add_timely_term()} function. Assessment is
considered fair if the student's timely completion term is no later than
the last term in their institution's data.

If the result in the \code{data_sufficiency} column is TRUE, then then student
should be included in the research. If FALSE, the student should be excluded
before calculating any persistence metric involving program completion
(graduation). The function performs no subsetting.

If \code{details} is TRUE, additional column(s) that support the finding
are returned as well. Here the extra column \code{inst_limit}, the latest
term reported by the institution in the available data.
}
\examples{
# TBD
}
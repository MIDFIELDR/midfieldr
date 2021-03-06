% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/add_timely_term.R
\name{add_timely_term}
\alias{add_timely_term}
\title{Add a column of timely completion terms}
\usage{
add_timely_term(
  dframe,
  midfield_term,
  ...,
  detail = NULL,
  span = NULL,
  sched_span = NULL
)
}
\arguments{
\item{dframe}{Data frame with required variable \code{mcid}.}

\item{midfield_term}{MIDFIELD \code{term} data table or equivalent with
required variables \code{mcid}, \code{term}, and \code{level}.}

\item{...}{Not used, forces later arguments to be used by name.}

\item{detail}{Optional flag to add columns reporting information
on which the evaluation is based, default FALSE.}

\item{span}{Optional numeric scalar, number of years to define timely
completion. Values that are 100%, 150%, and 200% of the "scheduled
span" (\code{sched_span}) are commonly used. Default 6 years.}

\item{sched_span}{Optional numeric scalar, the number of years an
institution officially schedules for completing a program. Default
4 years.}
}
\value{
A \code{data.table}  with the following properties:
\itemize{
    \item Rows are not modified.
    \item Column \code{timely_term} is added with an option to add
          columns \code{term_i}, \code{level_i}, and \code{adj_span}.
    \item Grouping structures are not preserved.
}
}
\description{
Add a column of academic term values to a data frame indicating the latest
term by which a student can graduate and have it considered a timely
completion. Student ID is the join-by variable; terms are encoded as
character strings YYYYT. Obtains the information from the
MIDFIELD \code{term} data table or equivalent.
}
\details{
The basic heuristic starts with \code{span} number of years for each student
(default 6 years). The span for students admitted at a higher level than
first year are reduced by one year for each full year the student is
assumed to have completed.

For example, a student admitted at the second-year level is assumed
to have completed one year of a program, so their span is reduced by one
year. Similarly, spans are reduced by two years for students admitted at
the 3rd-year level and by three years for students admitted at the
fourth-year level.

The adjusted span of years is added to their starting term; the result is
the timely completion term reported in the \code{timely_term} column.

The timely completion term is used in two evaluations: filtering for data
sufficiency (see \code{add_data_sufficiency()}) and assessing
completion for timeliness (\code{add_completion_timely()}).

If \code{detail} is TRUE, additional column(s) that support the finding
are returned as well. Here the extra columns are the student's initial
(admission) term \code{term_i}, initial level \code{level_i}, and
the adjusted span \code{adj_span}.

Existing columns with the same names as the added columns are overwritten.
}
\examples{
# Using the toy data sets
DT <- toy_student[1:10, .(mcid)]
add_timely_term(DT, midfield_term = toy_term)


# Add details on which the timely term is based
add_timely_term(DT, midfield_term = toy_term, detail = TRUE)


# Define timely completion as 200\% of scheduled span (8 years)
add_timely_term(DT, midfield_term = toy_term, span = 8)


# Optional arguments (after ...) must be named
add_timely_term(DT, toy_term, detail = TRUE, span = 6)

}
\seealso{
Other add_*: 
\code{\link{add_completion_timely}()},
\code{\link{add_data_sufficiency}()},
\code{\link{add_institution}()},
\code{\link{add_race_sex}()}
}
\concept{add_*}

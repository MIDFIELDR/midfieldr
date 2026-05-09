# Case study: Goals

Part 1 of a case study in three parts, illustrating how we work with
longitudinal student-level records.

1.  *Goals.*   Introducing the study.

2.  *Data.*   Transforming the data to yield the observations of
    interest.

3.  *Results.*   Summary statistics, metric, chart, and table.

## Definitions

**student-level data**

:   Data at the “student-level” refers to information about individual
    students including, for example, demographics, programs, academic
    standing, courses, grades, and degrees. Also called Student Unit
    Records (SURs).

:   MIDFIELD student-level data are provided in four data tables
    (`student`, `course`, `term`, and `degree`) that were compiled by
    institutions and anonymized and curated by the MIDFIELD data
    steward.

**stickiness**

:   Program “stickiness” \$\small\left(S\right)\$ is the ratio of the
    number of graduates of a program \$\small\left(N_g\right)\$ to the
    number ever enrolled in the program \$\small\left(N_e\right)\$.

:   \$\$ \small S = \frac{N_g}{N_e} = \frac{\mathrm{number\\ of\\
    graduates\\ of\\ a\\ program}}{\mathrm{number\\ ever\\ enrolled\\
    in\\ the\\ program}} \$\$

:   Stickiness is a more-inclusive alternative to graduation rate as a
    measure of a program’s success in attracting, keeping, and
    graduating their undergraduates. Stickiness includes many students
    excluded by graduation rate such as part-time students, transfers,
    students admitted in any term, and migrators ([Ohland et al.
    2012](#ref-Ohland+Orr+others:2012)).

## Goals

- Task:

  Compute and compare the stickiness of Civil, Electrical, Industrial,
  and Mechanical Engineering programs with students grouped by
  race/ethnicity and sex.

- Purpose:

  The case study illustrates how we work with student-level data.
  Starting with the curated data and concluding with a chart of the
  metric, we focus throughout on our process and the underlying
  rationale.

- Constraint:

  While we provide all the necessary code, we limit our discussion of
  the code (functions, arguments, syntax, etc.) to meet the constraint
  of providing a brief, yet complete, case study. Such discussions are
  left to later articles. One can always use the R help system to read
  more about a data set or function.

## References

Ohland, Matthew, Marisa Orr, Richard Layton, Susan Lord, and Russell
Long. 2012. “Introducing stickiness as a versatile metric of engineering
persistence.” *Proceedings of the Frontiers in Education Conference*,
1–5.

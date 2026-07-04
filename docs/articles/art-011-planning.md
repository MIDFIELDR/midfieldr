# Planning

The description section of the [Case
study](https://midfieldr.github.io/midfieldr/articles/articles/art-004-case-study.md)
article provides a good initial outline of how to plan your analysis
using MIDFIELD student records. Under each heading, we’ll pose some
prompts to help you assemble the resources you’ll need.

*Data.*  

- What programs are to be included?
- Do you know their CIP codes?
- If you don’t plan to use the `cip` dataset in midfieldr, do you have
  another source available? Do you know how it is structured?
- Are you planning to use the MIDFIELD research database? Have you
  requested access from ASEE?
- If not, do you have an alternative set of student-level data? To use
  midfieldr, your data must be modeled on the MIDFIELD database.

*Metric.*   Program *stickiness:* the ratio \small (S) of the number of
graduates of a program \small (N\_\textrm{grad}) to the number ever
enrolled in the program \small (N\_\textrm{ever}), including part-time
students, migrators, transfers, and students admitted in any term
([Ohland et al. 2012](#ref-Ohland+Orr+others:2012)).

\small S = \frac{\small N\_\textrm{grad}}{\small N\_\textrm{ever}} =
\frac{\small\mathrm{number\\ of\\ graduates\\ of\\ a\\
program}}{\small\mathrm{number\\ ever\\ enrolled\\ in\\ the\\ program}}

*Programs.*   Civil, Electrical, Industrial/Systems, and Mechanical
Engineering.

*Records.*   Exclude records later than a student’s first degree term;
filter for data sufficiency and degree seeking; no exclusions due to
part-time status, transfer status, admission term, or starting program.

*Population.*   The set of unique IDs from the above records.

*Blocs.*   Students ever enrolled in the programs and timely graduates
of the programs are required by the metric.

*Groupings.*   We select program, race/ethnicity, and sex for grouping
and summarizing.

*Outcome.*   To calculate the metric, we construct a data frame with
columns for each grouping variable (program, race/ethnicity, and sex)
and the counts by group \small N\_\textrm{grad} and \small
N\_\textrm{ever}.

*Dissemination.*   Exclude groupings too small to preserve anonymity.
Edit column names to suit the audience. Condition/transform data as
needed for tables or charts.

[▲ top of page](#top)

## References

Ohland, Matthew, Marisa Orr, Richard Layton, Susan Lord, and Russell
Long. 2012. “Introducing stickiness as a versatile metric of engineering
persistence.” *Proceedings of the Frontiers in Education Conference*,
1–5.

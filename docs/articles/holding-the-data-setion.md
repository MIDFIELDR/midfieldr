# Untitled

## Data: student-level records

***Research data.***   MIDFIELD \[@ohland:midfield:2023\] is a database
of 2.4M students in four tables (student, course, term, degree) that has
been managed since 2023 by the American Society for Engineering
Education (ASEE). Contact ASEE for further information.

***Practice data.***   The midfielddata package provides an anonymized
sample of the MIDFIELD database organized in four tables (student,
course, term, degree) as shown in Table 1. midfielddata is used
throughout these articles to demonstrate how midfieldr is used. However,
midfielddata must not be used to draw inferences about program
attributes or student experiences. midfielddata is for *practice*, not
*research*.

| Table | Each row is | N students | N rows | N columns | Mb memory |
|----|----|----|----|----|----|
| student | one student | 97,555 | 97,555 | 13 | 17.3 |
| course | one student per course per term | 97,555 | 3,289,532 | 12 | 324.3 |
| term | one student per term | 97,555 | 639,915 | 13 | 72.8 |
| degree | one student per degree | 49,543 | 49,665 | 5 | 5.2 |

Table 1. Student-level records in midfielddata {.table .gt_table
quarto-disable-processing="false" quarto-bootstrap="false"}

Data dictionaries are documented in
[`?student`](https://midfieldr.github.io/midfielddata/reference/student.html),
[`?course`](https://midfieldr.github.io/midfielddata/reference/course.html),
[`?term`](https://midfieldr.github.io/midfielddata/reference/term.html),
and
[`?degree`](https://midfieldr.github.io/midfielddata/reference/degree.html).
If you are new to these data, the best place to start is the
midfielddata website:

- [MIDFIELD data
  structure.](https://midfieldr.github.io/midfielddata/articles/data-structure.html)
  An article that describes the structure of the four data tables in
  midfielddata: number of observations, number and class of variables,
  representative values, and database keys.

- [Data linked by student
  ID.](https://midfieldr.github.io/midfielddata/articles/individual-students.html)
  An article that examines the variables and some representative values
  in midfielddata—we take a closer look at the records of individual
  students across the four data tables.

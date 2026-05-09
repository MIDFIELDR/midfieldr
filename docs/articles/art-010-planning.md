# Planning

Analysis of MIDFIELD data begins by identifying the groups of students,
programs, and metrics with which we intend to work.

## Workflow

Working with MIDFIELD data is iterative—intermediate results often cause
us to revisit an earlier assumption or select a different bloc or
student attributes to work with. Nevertheless, a completed analysis
usually comprises the following steps in roughly the sequence given
below. Accented entries indicate topics in the open article.

1.  Planning
    - Records $`\longleftarrow`$
    - Programs $`\longleftarrow`$
    - Metrics, blocs, and groupings $`\longleftarrow`$
2.  Initial processing
    - Data sufficiency
    - Degree seeking  
    - Identify programs  
3.  Blocs
    - Ever-enrolled  
    - FYE proxies  
    - Starters  
    - Graduates  
4.  Groupings
    - Program labels  
    - Demographics  
    - Other variables
5.  Metrics
    - Graduation rate  
    - Stickiness  
6.  Displays
    - Multiway charts  
    - Tables

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

**program**

:   US academic field of study. Can be used to indicate a specialty
    within a field or a collection of fields within a Department,
    College, or University. Programs are denoted by the *Classification
    of Instructional Programs* (CIP), a taxonomy of academic programs
    curated by the US Department of Education ([NCES
    2010](#ref-NCES:2010)).

**metric**

:   A quantitative measure derived from student-level data. Includes
    statistical measures such as counts of program starters or graduates
    as well as comparative ratios such as graduation rate or stickiness.
    Typically involves comparisons of specific blocs of students and
    programs.

bloc

:   A grouping of student-level data dealt with as a unit, for example,
    starters, students ever-enrolled, graduates, transfer students,
    traditional and non-traditional students, migrators, etc.

**grouping variables**

:   Detailed information in the student-level data that further
    characterize a bloc of records, typically used to create bloc
    subsets for comparison, for example, program, race/ethnicity, sex,
    age, grade level, grades, etc.

## Which records?

There are currently two points of access to MIDFIELD data:

[MIDFIELD](https://midfield.online/).   A database of anonymized
student-level records for approximately 2.4M undergraduates at 21 US
institutions from 1987-2022. In 2023, control and management of the
database was transferred to the American Society for Engineering
Education (ASEE). For further information, contact ASEE.

[midfielddata](https://midfieldr.github.io/midfielddata/).   An R data
package that supplies anonymized student-level records for 98,000
undergraduates at three US institutions from 1988-2018. A sample of the
MIDFIELD database, midfielddata provides practice data for the tools and
methods in the midfieldr package.

*To load research data.*   For users with access to the MIDFIELD
database, data are imported using any “read” function, e.g.,

``` r

# Not run
student <- fread("local_path_to_student_research_data")
course <- fread("local_path_to_course_research_data")
term <- fread("local_path_to_term_research_data")
degree <- fread("local_path_to_degree_research_data")
```

*To load practice data.*   Load from the midfielddata package.

``` r

# Load practice data
library(midfielddata)
data(student, course, term, degree)
```

The variables in the practice data are a subset of those in the research
data. A researcher transitioning from working with the practice data to
the research data should find that their scripts need little (if any)
modification.

*Reminder.*   midfielddata datasets are for practice, not research.

## Which programs?

Identify programs in *general* terms, for example,

- All Engineering  
- Engineering, Business, Social Sciences, and Arts and Humanities  
- Electrical Engineering and Computer Engineering

Search the `cip` data set included with midfieldr to identify the
6-digit CIP codes relevant to a study.

*Note.*   Most of our examples involve engineering programs. However,
MIDFIELD research data contain student-level records of *all
undergraduates in all programs* at their institution over the time spans
given.

## Which metrics, blocs, and groupings?

Before the data processing starts, we have to decide the metrics we want
to compare among which blocs of students grouped by what variables.
Metrics can include bloc counts or comparative ratios, for example:

- Blocs, e.g., counts of starters, graduates, migrators, etc.
- Four-year persistence
- Six-year graduation rate  
- Six-year stickiness

The metric determines the blocs to gather, for example:

- Graduation rate requires a bloc of starters and the subset who
  graduate in their starting program.
- Stickiness requires the bloc of ever enrolled in a program and the
  subset who graduate in that program.

The research study design determines the grouping variables, for
example,

- Completion status is a critical variable whenever graduation (program
  completion) is involved.  
- Programs, race/ethnicity, and sex are important grouping variables in
  many studies.
- Other student-level variables such as institution, GPA, grade level,
  etc., can also be used for grouping and summarizing.

## References

NCES. 2010. *IPEDS Classification of Instructional Programs (CIP)*.
National Center for Education Statistics.
<https://nces.ed.gov/ipeds/cipcode/>.

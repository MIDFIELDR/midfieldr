# Prepare FYE data for imputation

Constructs a data frame of students ever enrolled in First-Year
Engineering (FYE) programs based on information in the MIDFIELD (or
equivalent) `student` and `term` data tables. Conditions the data for
use as an input to the mice R package for multiple imputation. Sets up
three variables as predictors (institution, race/ethnicity, and sex) and
one variable to be imputed (program CIP code) keyed by student ID.

## Usage

``` r
prep_fye_mice(m_student, m_term, fye_cip = NULL, ..., alt_fye = NULL)
```

## Arguments

- m_student:

  Data frame or data frame extension (e.g., data.table or tibble) with
  required character variables `{mcid, race, sex}.` Typically based on
  one's original, unfiltered `student` source data without regard to
  data sufficiency.

- m_term:

  Data frame or data frame extension (e.g., data.table or tibble) with
  required character variables `{mcid, term, cip6, institution}.`
  Typically based on one's original, unfiltered `term` source data
  without regard to data sufficiency.

- fye_cip:

  Character, one 6-digit CIP code used for FYE programs. Default
  "140102", applied to all institutions except those (if any) optionally
  defined by user in `alt_fye.`

- ...:

  Not used for passing values; forces subsequent arguments to be
  referable only by name.

- alt_fye:

  Data frame or data frame extension (e.g., data.table or tibble) with
  character variables `{institution, alt_cip}.` For users with
  institutions that use a 6-digit CIP code other than the value in
  `fye_cip` for their FYE programs. One FYE code per institution.

## Value

Data frame with the following properties:

- Data frame class is preserved. Groups and keys are not preserved.

- Rows: One row for every degree-seeking FYE student.

- Columns: Conditioned for later use as an input to the mice R package
  for multiple imputation as follows:

  - `mcid`   Character, anonymized student identifier.

  - `race`   Factor, race/ethnicity from the `student` input data frame.
    An imputation predictor variable.

  - `sex`   Factor, sex from the `student` input data frame. An
    imputation predictor variable.

  - `institution`   Factor, anonymized institution name from the `term`
    data frame. An imputation predictor variable.

  - `proxy`   Factor, 6-digit CIP code of a student's known, first
    degree-granting engineering program or NA representing missing
    values to be imputed.

## Background

At some US institutions, engineering students are required to complete a
First-Year Engineering (FYE) program as a prerequisite for enrolling in
an engineering major. When one of these programs calculates a metric
that requires a count of starters, e.g., graduation rate, typically only
those students entering the degree-granting program post-FYE are
counted.

Some FYE students do not subsequently enter an engineering major—they
may switch to a non-engineering program or leave the database entirely.
Had FYE not been required, they would have instead been admitted to a
degree-granting engineering program of their choice, increasing the
count of starters in those programs resulting in a lower graduation rate
when they switched majors or left the database.

To improve the count of starters for FYE institutions, we introduce the
concept of "FYE proxies", that is, 6-digit CIP codes of the
degree-granting engineering programs that FYE students might have
declared had they not been required to enroll in FYE.

## Method

The function extracts all terms for all FYE students and identifies all
engineering programs in which they were ever enrolled. A `proxy`
variable is added with one of the following values:

1.  If a student record includes at least one, non-FYE, degree-granting
    engineering program, the CIP code of the first such program is
    returned as the student's FYE proxy.

2.  If not, the proxy is NA and is treated as a missing value to be
    imputed by `mice()`.

This function does not perform the imputation. It produces a data frame
that is ready to be used as an input to the `mice()` function in a
separate step.

Notes:

- Missing values (NA) in the required columns are removed. However, a
  value of "unknown" in a predictor column, e.g., race/ethnicity or sex,
  is acceptable.

- Accommodates only one 6-digit FYE CIP code per institution.

- After running `prep_fye_mice()` but before running `mice()`, one can
  edit the predictor variables if desired. The institution variable
  should remain to ensure that a student's imputed program is available
  at their institution.

- The resulting data frame is ready for use as input for the mice
  package, with all variables except `mcid` returned as factors.

## Examples

``` r
library(data.table)
#> data.table 1.18.4 using 8 threads (see ?getDTthreads).  
#> Latest news: r-datatable.com
#> 
#> Attaching package: ‘data.table’
#> The following object is masked from ‘package:base’:
#> 
#>     %notin%

# Subset student and term data using selected IDs
IDs <- c("MCID3112319668", "MCID3112214437", "MCID3112328548", 
         "MCID3111447797", "MCID3111566004", "MCID3111697452", 
         "MCID3112268500", "MCID3112320295")
student <- select_basic_cols(toy_student[mcid %chin% IDs])
term <- select_basic_cols(toy_term[mcid %chin% IDs])

# Obtain results
proxy <- prep_fye_mice(student, term)
proxy
#>              mcid   institution          race    sex  proxy
#>            <char>        <fctr>        <fctr> <fctr> <fctr>
#> 1: MCID3111447797 Institution J         White   Male 141901
#> 2: MCID3111566004 Institution J         Black Female   <NA>
#> 3: MCID3111697452 Institution J         Asian   Male   <NA>
#> 4: MCID3112214437 Institution J Other/Unknown   Male 140901
#> 5: MCID3112268500 Institution J         White   Male   <NA>
#> 6: MCID3112319668 Institution J         Asian Female 140701
#> 7: MCID3112320295 Institution J      Hispanic   Male   <NA>
#> 8: MCID3112328548 Institution J      Hispanic Female 141001

# ---------- Examine details
# Note: the CIP code and name for FYE is 140102 Pre-Engineering

# Join program names to term data for display
term_seq <- cip[term, .(mcid, term, cip6, cip6name), on = "cip6", nomatch = NULL]

# Function to display results for individual students
f <- function(IDs, i) {
    cat(paste("Student", i, "record\n"))
    print(term_seq[mcid == IDs[i]])
    cat("\nprep_fye_mice() results\n")
    print(proxy[mcid == IDs[i]])
}

# Example 1: Non-Engineering -> FYE -> Engineering
# 400501 (Chemistry) -> FYE -> 140701 (Chemical Engng)
# FYE proxy is 140701
f(IDs, 1)
#> Student 1 record
#>              mcid   term   cip6             cip6name
#>            <char> <char> <char>               <char>
#> 1: MCID3112319668  20081 400501   Chemistry, General
#> 2: MCID3112319668  20083 400501   Chemistry, General
#> 3: MCID3112319668  20091 140102      Pre-Engineering
#> 4: MCID3112319668  20093 140701 Chemical Engineering
#> 
#> prep_fye_mice() results
#>              mcid   institution   race    sex  proxy
#>            <char>        <fctr> <fctr> <fctr> <fctr>
#> 1: MCID3112319668 Institution J  Asian Female 140701

# Example 2: FYE -> Engineering -> Non-Engineering
# FYE -> 140901 (Computer Engng) -> 450601 (Economics)
# FYE proxy is 140901
f(IDs, 2)
#> Student 2 record
#>              mcid   term   cip6                      cip6name
#>            <char> <char> <char>                        <char>
#> 1: MCID3112214437  20061 140102               Pre-Engineering
#> 2: MCID3112214437  20063 140102               Pre-Engineering
#> 3: MCID3112214437  20073 140102               Pre-Engineering
#> 4: MCID3112214437  20091 140901 Computer Engineering, General
#> 5: MCID3112214437  20093 450601            Economics, General
#> 
#> prep_fye_mice() results
#>              mcid   institution          race    sex  proxy
#>            <char>        <fctr>        <fctr> <fctr> <fctr>
#> 1: MCID3112214437 Institution J Other/Unknown   Male 140901

# Example 3: FYE -> Engineering
# FYE -> 141001 (Electrical Engng)
# FYE proxy is 141001
f(IDs, 3)
#> Student 3 record
#>              mcid   term   cip6
#>            <char> <char> <char>
#> 1: MCID3112328548  20076 140102
#> 2: MCID3112328548  20081 140102
#> 3: MCID3112328548  20085 140102
#> 4: MCID3112328548  20091 141001
#> 5: MCID3112328548  20093 141001
#>                                                  cip6name
#>                                                    <char>
#> 1:                                        Pre-Engineering
#> 2:                                        Pre-Engineering
#> 3:                                        Pre-Engineering
#> 4: Electrical, Electronics and Communications Engineering
#> 5: Electrical, Electronics and Communications Engineering
#> 
#> prep_fye_mice() results
#>              mcid   institution     race    sex  proxy
#>            <char>        <fctr>   <fctr> <fctr> <fctr>
#> 1: MCID3112328548 Institution J Hispanic Female 141001

# Example 4: FYE -> Engineering -> Engineering
# FYE -> 141901 (Mechanical Engng) -> 143501 (Industrial Engng)
# FYE proxy is 141901 
f(IDs, 4)
#> Student 4 record
#>              mcid   term   cip6               cip6name
#>            <char> <char> <char>                 <char>
#> 1: MCID3111447797  19941 140102        Pre-Engineering
#> 2: MCID3111447797  19943 141901 Mechanical Engineering
#> 3: MCID3111447797  19945 141901 Mechanical Engineering
#> 4: MCID3111447797  19946 141901 Mechanical Engineering
#> 5: MCID3111447797  19971 141901 Mechanical Engineering
#> 6: MCID3111447797  19973 141901 Mechanical Engineering
#> 7: MCID3111447797  19976 143501 Industrial Engineering
#> 8: MCID3111447797  19981 143501 Industrial Engineering
#> 9: MCID3111447797  19983 143501 Industrial Engineering
#> 
#> prep_fye_mice() results
#>              mcid   institution   race    sex  proxy
#>            <char>        <fctr> <fctr> <fctr> <fctr>
#> 1: MCID3111447797 Institution J  White   Male 141901

# Example 5: Non-Engineering -> FYE -> Leaves the database
# 240102 (General Studies) -> FYE
# FYE proxy is NA 
f(IDs, 5)
#> Student 5 record
#>              mcid   term   cip6        cip6name
#>            <char> <char> <char>          <char>
#> 1: MCID3111566004  19961 240102 General Studies
#> 2: MCID3111566004  19963 140102 Pre-Engineering
#> 3: MCID3111566004  19965 140102 Pre-Engineering
#> 4: MCID3111566004  19966 140102 Pre-Engineering
#> 
#> prep_fye_mice() results
#>              mcid   institution   race    sex  proxy
#>            <char>        <fctr> <fctr> <fctr> <fctr>
#> 1: MCID3111566004 Institution J  Black Female   <NA>

# Example 6: FYE -> Leaves the database
# FYE proxy is NA 
f(IDs, 6)
#> Student 6 record
#>              mcid   term   cip6        cip6name
#>            <char> <char> <char>          <char>
#> 1: MCID3111697452  19985 140102 Pre-Engineering
#> 2: MCID3111697452  19986 140102 Pre-Engineering
#> 3: MCID3111697452  19991 140102 Pre-Engineering
#> 4: MCID3111697452  19996 140102 Pre-Engineering
#> 
#> prep_fye_mice() results
#>              mcid   institution   race    sex  proxy
#>            <char>        <fctr> <fctr> <fctr> <fctr>
#> 1: MCID3111697452 Institution J  Asian   Male   <NA>

# Example 7: Non-Engineering -> FYE -> Non-Engineering
# 240102 (General Studies) -> FYE -> 110101 (Computer Science)
# FYE proxy is NA 
f(IDs, 7)
#> Student 7 record
#>              mcid   term   cip6         cip6name
#>            <char> <char> <char>           <char>
#> 1: MCID3112268500  20071 240102  General Studies
#> 2: MCID3112268500  20073 140102  Pre-Engineering
#> 3: MCID3112268500  20081 110101 Computer Science
#> 4: MCID3112268500  20083 110101 Computer Science
#> 5: MCID3112268500  20091 110101 Computer Science
#> 6: MCID3112268500  20093 110101 Computer Science
#> 
#> prep_fye_mice() results
#>              mcid   institution   race    sex  proxy
#>            <char>        <fctr> <fctr> <fctr> <fctr>
#> 1: MCID3112268500 Institution J  White   Male   <NA>

# Example 8: FYE -> Non-Engineering
# FYE -> 230101 (English Literature)
# FYE proxy is NA 
f(IDs, 8)
#> Student 8 record
#>              mcid   term   cip6                                 cip6name
#>            <char> <char> <char>                                   <char>
#> 1: MCID3112320295  20081 140102                          Pre-Engineering
#> 2: MCID3112320295  20083 140102                          Pre-Engineering
#> 3: MCID3112320295  20091 230101 English Language and Literature, General
#> 4: MCID3112320295  20093 230101 English Language and Literature, General
#> 
#> prep_fye_mice() results
#>              mcid   institution     race    sex  proxy
#>            <char>        <fctr>   <fctr> <fctr> <fctr>
#> 1: MCID3112320295 Institution J Hispanic   Male   <NA>
```

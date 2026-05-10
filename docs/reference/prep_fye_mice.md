# Prepare FYE data for multiple imputation

Constructs a data frame of student-level records of First-Year
Engineering (FYE) programs and conditions the data for later use as an
input to the mice R package for multiple imputation. Sets up three
variables as predictors (institution, race/ethnicity, and sex) and one
variable to be estimated (program CIP code).

## Usage

``` r
prep_fye_mice(
  midfield_student = student,
  midfield_term = term,
  ...,
  fye_codes = NULL
)
```

## Arguments

- midfield_student:

  MIDFIELD `student` data table or equivalent with required variables
  `mcid`, `race`, and `sex.`

- midfield_term:

  MIDFIELD `term` data table or equivalent with required variables
  `mcid`, `institution`, `term`, and `cip6.`

- ...:

  Not used for passing values; forces subsequent arguments to be
  referable only by name.

- fye_codes:

  Optional character vector of 6-digit CIP codes to identify FYE
  programs, default "140102". Codes must be 6-digit strings of numbers;
  regular expressions are prohibited. Non-engineering codes—those that
  do not start with 14—produce an error.

## Value

A data frame in `data.table` format conditioned for later use as an
input to the mice R package for multiple imputation. The data frame
comprises one row for every FYE student, first-term and migrator.
Grouping structures are not preserved. The columns returned are:

- `mcid`:

  Character, anonymized student identifier. Returned as-is.

- `race`:

  Factor, race/ethnicity as self-reported by the student. An imputation
  predictor variable.

- `sex`:

  Factor, sex as self-reported by the student. An imputation predictor
  variable.

- `institution`:

  Factor, anonymized institution name. An imputation predictor variable.

- `proxy`:

  Factor, 6-digit CIP code of a student's known, post-FYE engineering
  program or NA representing missing values to be imputed.

## Details

At some US institutions, engineering students are required to complete a
First-Year Engineering (FYE) program as a prerequisite for declaring an
engineering major. Administratively, degree-granting engineering
programs such as Electrical Engineering or Mechanical Engineering treat
their incoming post-FYE students as their "starting" cohorts. However,
when computing a metric that requires a count of starters—graduation
rate, for example—FYE records must be treated with special care to avoid
a miscount.

To illustrate the potential for miscounting starters, suppose we wish to
calculate a Mechanical Engineering (ME) graduation rate. Students
starting in ME constitute the starting pool and the fraction of that
pool graduating in ME is the graduation rate. At FYE institutions, an ME
program would typically define their starting pool as the post-FYE
cohort entering their program. This may be the best information
available, but it invariably undercounts starters by failing to account
for FYE students who do not transition (post-FYE) to degree-granting
engineering programs—students who may have left the institution or
switched to non-engineering majors. In either case, in the absence of
the FYE requirement, some of these students would have been ME starters.
By neglecting these students, the count of ME starters is artificially
low resulting in an ME graduation rate that is artificially high. The
same is true for every degree-granting engineering discipline in an FYE
institution.

Therefore, to avoid miscounting starters at FYE institutions, we have to
estimate an "FYE proxy", that is, the 6-digit CIP codes of the
degree-granting engineering programs that FYE students would have
declared had they not been required to enroll in FYE. The purpose of
\`prep_fye_mice()“ is to prepare the data for making that estimation.

After running `prep_fye_mice()` but before running `mice()`, one can
edit variables or add variables to create a custom set of predictors.
The mice package expects all predictors and the proxy variables to be
factors. Do not delete the institution variable because it ensures that
a student's imputed program is available at their institution.

In addition, ensure that the only missing values are in the proxy
column. Other variables are expected to be complete (no NA values). A
value of "unknown" in a predictor column, e.g., race/ethnicity or sex,
is an acceptable value, not missing data. Observations with missing or
unknown values in the ID or institution columns (if any) should be
removed.

## Method

The function extracts all terms for all FYE students, including those
who migrate to enter Engineering after their first term, and identifies
the first post-FYE program in which they enroll, if any. This treatment
yields two possible outcomes for values returned in the `proxy` column:

1.  The student completes FYE and enrolls in an engineering major. For
    this outcome, we know that at the student's first opportunity, they
    enrolled in an engineering program of their choosing. The CIP code
    of that program is returned as the student's FYE proxy.

2.  The student does not enroll post-FYE in an engineering major. Such
    students have no further records in the database or switched from
    Engineering to another program. For this outcome, the data provide
    no information regarding what engineering program the student would
    have declared originally had the institution not required them to
    enroll in FYE. For these students a proxy value of NA is returned.
    These are the data treated as missing values to be imputed by
    `mice()`.

In cases where students enter FYE, change programs, and re-enter FYE,
only the first group of FYE terms is considered. Any programs before FYE
are ignored.

The resulting data frame is ready for use as input for the mice package,
with all variables except `mcid` returned as factors.

## Examples

``` r
# Using toy data
prep_fye_mice(toy_student, toy_term)
#>            mcid     race    sex   institution  proxy
#>          <char>   <fctr> <fctr>        <fctr> <fctr>
#>  1: MID26060301    Asian Female Institution C   <NA>
#>  2: MID25995980 Hispanic Female Institution C   <NA>
#>  3: MID25997636 Hispanic Female Institution C   <NA>
#>  4: MID26086310 Hispanic Female Institution C   <NA>
#>  5: MID26000057    White Female Institution C   <NA>
#>  6: MID26614720    Asian   Male Institution J   <NA>
#>  7: MID26593796    White   Male Institution J   <NA>
#>  8: MID25848589    White   Male Institution M 143501
#>  9: MID25846316    White   Male Institution M 143501
#> 10: MID25847220    White   Male Institution M 143501
#> 11: MID25828870    White   Male Institution M 149999

# Other columns, if any, are dropped
colnames(toy_student)
#> [1] "mcid"        "institution" "race"        "sex"        
colnames(prep_fye_mice(toy_student, toy_term))
#> [1] "mcid"        "race"        "sex"         "institution" "proxy"      

# Optional argument permits multiple CIP codes for FYE
prep_fye_mice(midfield_student = toy_student, 
              midfield_term =toy_term, 
              fye_codes = c("140101", "140102"))
#>            mcid     race    sex   institution  proxy
#>          <char>   <fctr> <fctr>        <fctr> <fctr>
#>  1: MID25977316    White   Male Institution B   <NA>
#>  2: MID26060301    Asian Female Institution C   <NA>
#>  3: MID25995980 Hispanic Female Institution C   <NA>
#>  4: MID25997636 Hispanic Female Institution C   <NA>
#>  5: MID26086310 Hispanic Female Institution C   <NA>
#>  6: MID26000057    White Female Institution C   <NA>
#>  7: MID26614720    Asian   Male Institution J   <NA>
#>  8: MID26593796    White   Male Institution J   <NA>
#>  9: MID25848589    White   Male Institution M 143501
#> 10: MID25846316    White   Male Institution M 143501
#> 11: MID25847220    White   Male Institution M 143501
#> 12: MID25828870    White   Male Institution M 149999
```

# Prepare FYE data for imputation

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

  MIDFIELD records *student* data frame or data frame extension.
  Required variables: `{mcid, race, sex}.`

- midfield_term:

  MIDFIELD records *term* data frame or data frame extension. Required
  variables: `{mcid, term, cip6, institution}.`

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
#>               mcid          race    sex   institution  proxy
#>             <char>        <fctr> <fctr>        <fctr> <fctr>
#>  1: MCID3111775049         Black Female Institution J   <NA>
#>  2: MCID3111587881         White Female Institution J   <NA>
#>  3: MCID3112382701         White Female Institution J   <NA>
#>  4: MCID3111914993         Asian   Male Institution J   <NA>
#>  5: MCID3112061482         Asian   Male Institution J   <NA>
#>  6: MCID3112265753         Asian   Male Institution J   <NA>
#>  7: MCID3112273754 Other/Unknown   Male Institution J   <NA>
#>  8: MCID3111160513         White   Male Institution J   <NA>
#>  9: MCID3111250695         White   Male Institution J   <NA>
#> 10: MCID3111304195         White   Male Institution J   <NA>
#> 11: MCID3111413518         White   Male Institution J   <NA>
#> 12: MCID3111580991         White   Male Institution J   <NA>
#> 13: MCID3111648099         White   Male Institution J   <NA>
#> 14: MCID3111652280         White   Male Institution J   <NA>
#> 15: MCID3111782447         White   Male Institution J   <NA>
#> 16: MCID3112008110         White   Male Institution J   <NA>
#> 17: MCID3112172401         White   Male Institution J   <NA>
#> 18: MCID3112382065         White   Male Institution J   <NA>
#> 19: MCID3112382653         White   Male Institution J   <NA>
#> 20: MCID3112384278         White   Male Institution J   <NA>
#> 21: MCID3112388922         White   Male Institution J   <NA>
#> 22: MCID3111931819         White   Male Institution J 140201
#> 23: MCID3111933160         White   Male Institution J 140201
#> 24: MCID3112172059         White   Male Institution J 140201
#> 25: MCID3111162677         White Female Institution J 140701
#> 26: MCID3112216887         White Female Institution J 140701
#> 27: MCID3111357512         White   Male Institution J 140701
#> 28: MCID3112169393         White Female Institution J 140801
#> 29: MCID3111354376         White   Male Institution J 140801
#> 30: MCID3111460368         White   Male Institution J 140801
#> 31: MCID3111656207         White   Male Institution J 140801
#> 32: MCID3111860947         White   Male Institution J 140801
#> 33: MCID3112267967         White   Male Institution J 140801
#> 34: MCID3112268235         White   Male Institution J 140801
#> 35: MCID3111909377 Other/Unknown   Male Institution J 140901
#> 36: MCID3111248941         White   Male Institution J 140901
#> 37: MCID3111355374         White   Male Institution J 140901
#> 38: MCID3111648837         White   Male Institution J 140901
#> 39: MCID3111842661         White   Male Institution J 140901
#> 40: MCID3111358440         White Female Institution J 141001
#> 41: MCID3111159270         White   Male Institution J 141001
#> 42: MCID3111164287         White   Male Institution J 141001
#> 43: MCID3111406464         White   Male Institution J 141001
#> 44: MCID3111584951         White   Male Institution J 141401
#> 45: MCID3112169971         White Female Institution J 141801
#> 46: MCID3111503953         Asian   Male Institution J 141901
#> 47: MCID3112174233      Hispanic   Male Institution J 141901
#> 48: MCID3111253227         White   Male Institution J 141901
#> 49: MCID3111355464         White   Male Institution J 141901
#> 50: MCID3111356562         White   Male Institution J 141901
#> 51: MCID3111786826         White   Male Institution J 141901
#> 52: MCID3112323623         White Female Institution J 143501
#> 53: MCID3111573067         Black   Male Institution J 143501
#> 54: MCID3111454125 International   Male Institution J 143501
#>               mcid          race    sex   institution  proxy
#>             <char>        <fctr> <fctr>        <fctr> <fctr>

# Other columns, if any, are dropped
colnames(toy_student)
#>  [1] "mcid"           "race"           "sex"            "institution"   
#>  [5] "transfer"       "hours_transfer" "age_desc"       "us_citizen"    
#>  [9] "home_zip"       "high_school"    "sat_math"       "sat_verbal"    
#> [13] "act_comp"      
colnames(prep_fye_mice(toy_student, toy_term))
#> [1] "mcid"        "race"        "sex"         "institution" "proxy"      

# Optional argument permits multiple CIP codes for FYE
prep_fye_mice(midfield_student = toy_student, 
              midfield_term = toy_term, 
              fye_codes = c("140101", "140102"))
#>               mcid          race    sex   institution  proxy
#>             <char>        <fctr> <fctr>        <fctr> <fctr>
#>  1: MCID3111802941         White Female Institution C   <NA>
#>  2: MCID3111282492      Hispanic   Male Institution C 140801
#>  3: MCID3111775049         Black Female Institution J   <NA>
#>  4: MCID3111587881         White Female Institution J   <NA>
#>  5: MCID3112382701         White Female Institution J   <NA>
#>  6: MCID3111914993         Asian   Male Institution J   <NA>
#>  7: MCID3112061482         Asian   Male Institution J   <NA>
#>  8: MCID3112265753         Asian   Male Institution J   <NA>
#>  9: MCID3112273754 Other/Unknown   Male Institution J   <NA>
#> 10: MCID3111160513         White   Male Institution J   <NA>
#> 11: MCID3111250695         White   Male Institution J   <NA>
#> 12: MCID3111304195         White   Male Institution J   <NA>
#> 13: MCID3111413518         White   Male Institution J   <NA>
#> 14: MCID3111580991         White   Male Institution J   <NA>
#> 15: MCID3111648099         White   Male Institution J   <NA>
#> 16: MCID3111652280         White   Male Institution J   <NA>
#> 17: MCID3111782447         White   Male Institution J   <NA>
#> 18: MCID3112008110         White   Male Institution J   <NA>
#> 19: MCID3112172401         White   Male Institution J   <NA>
#> 20: MCID3112382065         White   Male Institution J   <NA>
#> 21: MCID3112382653         White   Male Institution J   <NA>
#> 22: MCID3112384278         White   Male Institution J   <NA>
#> 23: MCID3112388922         White   Male Institution J   <NA>
#> 24: MCID3111931819         White   Male Institution J 140201
#> 25: MCID3111933160         White   Male Institution J 140201
#> 26: MCID3112172059         White   Male Institution J 140201
#> 27: MCID3111162677         White Female Institution J 140701
#> 28: MCID3112216887         White Female Institution J 140701
#> 29: MCID3111357512         White   Male Institution J 140701
#> 30: MCID3112169393         White Female Institution J 140801
#> 31: MCID3111354376         White   Male Institution J 140801
#> 32: MCID3111460368         White   Male Institution J 140801
#> 33: MCID3111656207         White   Male Institution J 140801
#> 34: MCID3111860947         White   Male Institution J 140801
#> 35: MCID3112267967         White   Male Institution J 140801
#> 36: MCID3112268235         White   Male Institution J 140801
#> 37: MCID3111909377 Other/Unknown   Male Institution J 140901
#> 38: MCID3111248941         White   Male Institution J 140901
#> 39: MCID3111355374         White   Male Institution J 140901
#> 40: MCID3111648837         White   Male Institution J 140901
#> 41: MCID3111842661         White   Male Institution J 140901
#> 42: MCID3111358440         White Female Institution J 141001
#> 43: MCID3111159270         White   Male Institution J 141001
#> 44: MCID3111164287         White   Male Institution J 141001
#> 45: MCID3111406464         White   Male Institution J 141001
#> 46: MCID3111584951         White   Male Institution J 141401
#> 47: MCID3112169971         White Female Institution J 141801
#> 48: MCID3111503953         Asian   Male Institution J 141901
#> 49: MCID3112174233      Hispanic   Male Institution J 141901
#> 50: MCID3111253227         White   Male Institution J 141901
#> 51: MCID3111355464         White   Male Institution J 141901
#> 52: MCID3111356562         White   Male Institution J 141901
#> 53: MCID3111786826         White   Male Institution J 141901
#> 54: MCID3112323623         White Female Institution J 143501
#> 55: MCID3111573067         Black   Male Institution J 143501
#> 56: MCID3111454125 International   Male Institution J 143501
#>               mcid          race    sex   institution  proxy
#>             <char>        <fctr> <fctr>        <fctr> <fctr>
```

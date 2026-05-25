# Alternative CIPs

In this article, we demonstrate constructing a Classification of
Instructional Programs (CIP) dataset using primary source data from the
US Integrated Postsecondary Education Data System (IPEDS). The result is
a dataset (`cip2010`) that can be used as an alternative to midfieldr’s
original CIP data (`cip`). The latest version of midfieldr includes both
datasets.

This article in the MIDFIELD workflow:

1.  Planning  
2.  Initial processing
    - Data sufficiency  
    - Degree seeking  
    - Identify programs
3.  Blocs  
4.  Groupings  
5.  Metrics  
6.  Displays

## Overview

The original midfieldr dataset `cip` and the new dataset `cip2010`
derived here are both based on the IPEDS 2010 CIP data. However, the
content of the two datasets is not identical. Aside from some
typographical differences, the main difference is that `cip2010` has 267
more rows than `cip`, about a 15% increase in program codes (225 of
these 267 rows are medical or dental *residency programs*). Essentially,
`cip` is a subset of `cip2010`.

This is not to say that `cip` is deficient—it was designed for
compatibility with the MIDFIELD database and thus the midfielddata
practice data as well. However, `cip2010` now makes the full set of 2010
CIP codes available should they be needed.

As of this writing (2026–05–25), the IPEDS website ([NCES
2026](#ref-cipcode:2026)) provides downloadable CSV files for the 2010
and 2020 CIP data via their “Resources” tab under the file names:

- `CIPCode2010.csv`
- `CIPCode2020.csv`

In this article, we document a procedure for converting
`CIPCode2010.csv` data into the midfieldr-friendly `cip2010` dataset. In
future, should a researcher require the 2020 CIP codes in a
midfieldr-friendly format, they can start by applying the procedure
documented here to `CIPCode2020.csv`.

## Get started

If you are writing your own script to follow along, we use these
packages in this article:

``` r

# Load packages
library(midfieldr)
library(data.table)

# From stringr package we use
# str_to_title(), str_replace(), and str_length()
library(stringr)
```

The first step is to download the CSV file from the IPEDs website. After
saving it to a convenient directory, label a path to that file
(`path_to_csv_file`) and import the data, using `DT` as our working data
table.

``` r

# Import the 2010 CIP file in data.table format
DT <- fread(path_to_csv_file, colClasses = "character")

# View the result
str(DT, strict.width = "cut", give.attr = FALSE, vec.len = 12)
#> Classes 'data.table' and 'data.frame':   2318 obs. of  8 variables:
#>  $ CIPFamily      : chr  "01" "01" "01" "01" "01" "01" "01" "01" "01" "01" "0"..
#>  $ CIPCode        : chr  "01" "01.00" "01.0000" "01.01" "01.0101" "01.0102" ""..
#>  $ Action         : chr  "No substantive changes" "No substantive changes" "N"..
#>  $ TextChange     : chr  "no" "no" "no" "no" "no" "no" "no" "no" "no" "no" "n"..
#>  $ CIPTitle       : chr  "AGRICULTURE, AGRICULTURE OPERATIONS, AND RELATED SC"..
#>  $ CIPDefinition  : chr  "Instructional programs that focus on agriculture an"..
#>  $ CrossReferences: chr  "" "" "14.0301 - Agricultural Engineering." "" "" """..
#>  $ Examples       : chr  "" "" "" "" "" "Examples: - Agricultural Systems Man"..
```

To construct our own CIP data set, we need three columns:

``` r

# Select columns
cols_we_want <- c("CIPFamily", "CIPCode", "CIPTitle")
DT <- DT[, ..cols_we_want]

# View the result
str(DT, strict.width = "cut", give.attr = FALSE, vec.len = 12)
#> Classes 'data.table' and 'data.frame':   2318 obs. of  3 variables:
#>  $ CIPFamily: chr  "01" "01" "01" "01" "01" "01" "01" "01" "01" "01" "01" "01"..
#>  $ CIPCode  : chr  "01" "01.00" "01.0000" "01.01" "01.0101" "01.0102" "01.010"..
#>  $ CIPTitle : chr  "AGRICULTURE, AGRICULTURE OPERATIONS, AND RELATED SCIENCES"..
```

Closer look at a sample of our primary-source data.

``` r

# Set the seed for reproducibility 
set.seed(202612)

# Extract a sample of 15 rows and reset the seed
x <- DT[sample(100:400, 15)]
set.seed(NULL)

# Order the rows by the CIP code
setorderv(x, "CIPCode")

# View the result
x
#>     CIPFamily CIPCode                                             CIPTitle
#>        <char>  <char>                                               <char>
#>  1:        04      04                   ARCHITECTURE AND RELATED SERVICES.
#>  2:        04   04.10                             Real Estate Development.
#>  3:        05 05.0117                                      Baltic Studies.
#>  4:        09 09.0102                    Mass Communication/Media Studies.
#>  5:        10   10.02 Audiovisual Communications Technologies/Technicians.
#>  6:        10 10.0302                                 Printing Management.
#>  7:        11 11.0701                                    Computer Science.
#>  8:        12      12                      PERSONAL AND CULINARY SERVICES.
#>  9:        13 13.0301                          Curriculum and Instruction.
#> 10:        13 13.0499   Educational Administration and Supervision, Other.
#> 11:        13   13.05              Educational/Instructional Media Design.
#> 12:        13   13.11           Student Counseling and Personnel Services.
#> 13:        13 13.1209       Kindergarten/Preschool Education and Teaching.
#> 14:        13 13.1312                             Music Teacher Education.
#> 15:        13 13.1319                         Technical Teacher Education.
```

Viewing the result, we observe:

- `CIPFamily` corresponds to `cip2` in midfieldr.
- `CIPCode` contains *all program codes* in a single column. In
  midfieldr, the 2-, 4-, and 6-digit codes are separated into columns
  `cip2`, `cip4`, and `cip6`.
- `CIPTitle` contains *all program names* in a single column. In
  midfieldr, the the 2-, 4-, and 6-digit names are separated into
  columns `cip2name`, `cip4name`, and `cip6name`.

When constructing the midfieldr `cip` data set, some characters were
changed from those in the source file, such as removing the decimal
point separator in the 4- and 6-digit codes or replacing slashes (“/”)
with commas (“,”). For example, compare the `13.1209` entry above to its
equivalent in the midfieldr `cip` data:

``` r

# CIPCode2010
filter_cip("13.1209", cip = DT)
#>    CIPFamily CIPCode                                       CIPTitle
#>       <char>  <char>                                         <char>
#> 1:        13 13.1209 Kindergarten/Preschool Education and Teaching.

# midfieldr default
filter_cip("131209", cip = cip)[, .(cip2, cip6, cip6name)]
#>      cip2   cip6                                       cip6name
#>    <char> <char>                                         <char>
#> 1:     13 131209 Kindergarten, Preschool Education and Teaching
```

Additionally, source-file 2-digit program names are in all-caps; in
midfieldr all program names are in title-case.

``` r

# CIPCode2010
DT[CIPCode == "04", .(CIPCode, CIPTitle)]
#>    CIPCode                           CIPTitle
#>     <char>                             <char>
#> 1:      04 ARCHITECTURE AND RELATED SERVICES.

# midfieldr default
cip[cip2 == "04", .(cip2, cip2name)][1]
#>      cip2                          cip2name
#>    <char>                            <char>
#> 1:     04 Architecture and Related Services
```

## Transforming the source data

*Editing values.*   Omit the periods in the codes and titles.

``` r

# Omit the period separator on the CIP code
DT <- DT[, CIPCode := gsub("[.]", "", CIPCode)]

# Omit the period at the end of each title
DT <- DT[, CIPTitle := gsub("[.]", "", CIPTitle)]

# Verify the result
filter_cip("131209", cip = DT)
#>    CIPFamily CIPCode                                      CIPTitle
#>       <char>  <char>                                        <char>
#> 1:        13  131209 Kindergarten/Preschool Education and Teaching
```

*Split the data frame.*   Count the number of digits in `CIPCode`,
expected to be 2, 4, or 6.

``` r

# Add a column
DT[, N_digits := str_length(CIPCode)]

# View result
str(DT, strict.width = "cut", give.attr = FALSE, vec.len = 12)
#> Classes 'data.table' and 'data.frame':   2318 obs. of  4 variables:
#>  $ CIPFamily: chr  "01" "01" "01" "01" "01" "01" "01" "01" "01" "01" "01" "01"..
#>  $ CIPCode  : chr  "01" "0100" "010000" "0101" "010101" "010102" "010103" "01"..
#>  $ CIPTitle : chr  "AGRICULTURE, AGRICULTURE OPERATIONS, AND RELATED SCIENCES"..
#>  $ N_digits : int  2 4 6 4 6 6 6 6 6 6 6 4 6 6 6 6 4 6 6 6 6 6 6 6 6 6 4 6 4 6..

# Confirm 2, 4, or 6 digits
unique(DT$N_digits)
#> [1] 2 4 6
```

Create a separate data frame for 2-digit codes and names, keyed by
`CIPFamily`.

``` r

# Unique 2-digit codes and names
DT2 <- DT[N_digits == 2, .(CIPFamily, 
                             cip2 = CIPCode, 
                             cip2name = CIPTitle)]
# View the result
str(DT2, strict.width = "cut", give.attr = FALSE, vec.len = 12)
#> Classes 'data.table' and 'data.frame':   48 obs. of  3 variables:
#>  $ CIPFamily: chr  "01" "03" "04" "05" "09" "10" "11" "12" "13" "14" "15" "16"..
#>  $ cip2     : chr  "01" "03" "04" "05" "09" "10" "11" "12" "13" "14" "15" "16"..
#>  $ cip2name : chr  "AGRICULTURE, AGRICULTURE OPERATIONS, AND RELATED SCIENCES"..
```

Repeat for the 4-digit codes and names. Extract the first two digits of
the 4-digit code to compare to `CIPFamily` (also 2-digits)

``` r

# Unique 4-digit codes and names, with cip2 codes derived from cip4
DT4 <- DT[N_digits == 4, .(CIPFamily, 
                             cip2 = substr(CIPCode, 1, 2), 
                             cip4 = CIPCode, 
                             cip4name = CIPTitle)]
# View the result
str(DT4, strict.width = "cut", give.attr = FALSE)
#> Classes 'data.table' and 'data.frame':   422 obs. of  4 variables:
#>  $ CIPFamily: chr  "01" "01" "01" "01" ...
#>  $ cip2     : chr  "01" "01" "01" "01" ...
#>  $ cip4     : chr  "0100" "0101" "0102" "0103" ...
#>  $ cip4name : chr  "Agriculture, General" "Agricultural Business and Manageme"..
```

Repeat for the 6-digit codes and names, extracting both 2- and 4-digit
codes for comparison and joining later.

``` r

# Unique 6-digit codes and names, with cip2 and cip4 codes derived from cip6
DT6 <- DT[N_digits == 6, .(CIPFamily, 
                             cip2 = substr(CIPCode, 1, 2), 
                             cip4 = substr(CIPCode, 1, 4), 
                             cip6 = CIPCode, 
                             cip6name = CIPTitle)]
# View the result
str(DT6, strict.width = "cut", give.attr = FALSE, vec.len = 12)
#> Classes 'data.table' and 'data.frame':   1848 obs. of  5 variables:
#>  $ CIPFamily: chr  "01" "01" "01" "01" "01" "01" "01" "01" "01" "01" "01" "01"..
#>  $ cip2     : chr  "01" "01" "01" "01" "01" "01" "01" "01" "01" "01" "01" "01"..
#>  $ cip4     : chr  "0100" "0101" "0101" "0101" "0101" "0101" "0101" "0101" "0"..
#>  $ cip6     : chr  "010000" "010101" "010102" "010103" "010104" "010105" "010"..
#>  $ cip6name : chr  "Agriculture, General" "Agricultural Business and Manageme"..
```

Compare the 2-digit codes in each data frame. If the data were correctly
entered, this check for equality should all be TRUE.

``` r

# This check for 2-digit equality should all be TRUE
all.equal(DT2$CIPFamily, DT2$cip2)
#> [1] TRUE
all.equal(DT4$CIPFamily, DT4$cip2)
#> [1] TRUE
all.equal(DT6$CIPFamily, DT6$cip2)
#> [1] TRUE
```

*Editing.*   Convert the 2-digit names from all-caps to title-case. Here
we use two functions from the stringr package.

``` r

# Convert to title case
DT2[, cip2name := str_to_title(cip2name)]

# Use lowercase "and"
DT2[, cip2name := str_replace_all(cip2name, "And", "and")]

# View result
DT2[, .(cip2, cip2name)]
#>       cip2                                                      cip2name
#>     <char>                                                        <char>
#>  1:     01     Agriculture, Agriculture Operations, and Related Sciences
#>  2:     03                            Natural Resources and Conservation
#>  3:     04                             Architecture and Related Services
#>  4:     05             Area, Ethnic, Cultural, Gender, and Group Studies
#>  5:     09               Communication, Journalism, and Related Programs
#> ---                                                                     
#> 44:     51                       Health Professions and Related Programs
#> 45:     52 Business, Management, Marketing, and Related Support Services
#> 46:     53               High School/Secondary Diplomas and Certificates
#> 47:     54                                                       History
#> 48:     60                                            Residency Programs
```

*Combine.*   Next, select the columns we want for the joining
operations.

``` r

# Select 6-digit columns
cols_we_want <- c("cip2", "cip4", "cip6", "cip6name")
DT6 <- DT6[, ..cols_we_want]

# Select 4-digit columns
cols_we_want <- c("cip2", "cip4", "cip4name")
DT4 <- DT4[, ..cols_we_want]

# Select 2-digit columns
cols_we_want <- c("cip2", "cip2name")
DT2 <- DT2[, ..cols_we_want]
```

Now, left-join `cip4` to `cip6`, matching on the 2- and 4-digit code
columns. Reuse the object name `DT` for our new working data frame.

``` r

# Join `cip4` to `cip6` , overwrite earlier DT
DT <- DT4[DT6, on = c("cip2", "cip4")]
```

Now, left-join `cip2` to the result, matching on the 2-digit code
columns.

``` r

# Left join `cip2` to `DT` from above
DT <- DT2[DT, on = c("cip2")]

# Ensure row order
setorderv(DT, c("cip6"))

# View the result
DT
#>         cip2                                                  cip2name   cip4
#>       <char>                                                    <char> <char>
#>    1:     01 Agriculture, Agriculture Operations, and Related Sciences   0100
#>    2:     01 Agriculture, Agriculture Operations, and Related Sciences   0101
#>    3:     01 Agriculture, Agriculture Operations, and Related Sciences   0101
#>    4:     01 Agriculture, Agriculture Operations, and Related Sciences   0101
#>    5:     01 Agriculture, Agriculture Operations, and Related Sciences   0101
#>   ---                                                                        
#> 1844:     60                                        Residency Programs   6005
#> 1845:     60                                        Residency Programs   6005
#> 1846:     60                                        Residency Programs   6005
#> 1847:     60                                        Residency Programs   6006
#> 1848:     60                                        Residency Programs   6006
#>                                                     cip4name   cip6
#>                                                       <char> <char>
#>    1:                                   Agriculture, General 010000
#>    2:                   Agricultural Business and Management 010101
#>    3:                   Agricultural Business and Management 010102
#>    4:                   Agricultural Business and Management 010103
#>    5:                   Agricultural Business and Management 010104
#>   ---                                                              
#> 1844: Medical Residency Programs - Subspecialty Certificates 600583
#> 1845: Medical Residency Programs - Subspecialty Certificates 600584
#> 1846: Medical Residency Programs - Subspecialty Certificates 600599
#> 1847:                  Podiatric Medicine Residency Programs 600601
#> 1848:                  Podiatric Medicine Residency Programs 600602
#>                                                            cip6name
#>                                                              <char>
#>    1:                                          Agriculture, General
#>    2:                 Agricultural Business and Management, General
#>    3:                 Agribusiness/Agricultural Business Operations
#>    4:                                        Agricultural Economics
#>    5:                                Farm/Farm and Ranch Management
#>   ---                                                              
#> 1844:       Vascular and Interventional Radiology Residency Program
#> 1845:                          Vascular Neurology Residency Program
#> 1846: Medical Residency Programs - Subspecialty Certificates, Other
#> 1847:         Podiatric Medicine and Surgery - 24 Residency Program
#> 1848:         Podiatric Medicine and Surgery - 36 Residency Program
```

*Reality check.*   If we’ve joined correctly, the following logical
checks should yield all TRUE (no FALSE) results.

``` r

# The first 4 digits of every cip6 should match cip4
unique(substr(DT$cip6, 1, 4) == DT$cip4)
#> [1] TRUE

# The first 2 digits of every cip6 should match cip2
unique(substr(DT$cip6, 1, 2) == DT$cip2)
#> [1] TRUE

# The first 2 digits of every cip4 should match cip2
unique(substr(DT$cip4, 1, 2) == DT$cip2)
#> [1] TRUE
```

## Undecided or unspecified programs

Lastly, we add a row to the CIP data to includes one non-IPEDS code
(999999) for Undecided or Unspecified, instances in which institutions
reported no program information or that students were not enrolled in a
program.

``` r

# Create a data table with one row
txt_99 <- "Undecided/Unspecified (non-IPEDS)"
row_99 <- data.table(cip2 = "99", 
                     cip4 = "9999", 
                     cip6 = "999999", 
                     cip2name = txt_99, 
                     cip4name = txt_99, 
                     cip6name = txt_99)

# Bind the new row to the working data table
DT <- rbindlist(list(DT, row_99), use.names = TRUE)

# View the result
DT
#>         cip2                                                  cip2name   cip4
#>       <char>                                                    <char> <char>
#>    1:     01 Agriculture, Agriculture Operations, and Related Sciences   0100
#>    2:     01 Agriculture, Agriculture Operations, and Related Sciences   0101
#>    3:     01 Agriculture, Agriculture Operations, and Related Sciences   0101
#>    4:     01 Agriculture, Agriculture Operations, and Related Sciences   0101
#>    5:     01 Agriculture, Agriculture Operations, and Related Sciences   0101
#>   ---                                                                        
#> 1845:     60                                        Residency Programs   6005
#> 1846:     60                                        Residency Programs   6005
#> 1847:     60                                        Residency Programs   6006
#> 1848:     60                                        Residency Programs   6006
#> 1849:     99                         Undecided/Unspecified (non-IPEDS)   9999
#>                                                     cip4name   cip6
#>                                                       <char> <char>
#>    1:                                   Agriculture, General 010000
#>    2:                   Agricultural Business and Management 010101
#>    3:                   Agricultural Business and Management 010102
#>    4:                   Agricultural Business and Management 010103
#>    5:                   Agricultural Business and Management 010104
#>   ---                                                              
#> 1845: Medical Residency Programs - Subspecialty Certificates 600584
#> 1846: Medical Residency Programs - Subspecialty Certificates 600599
#> 1847:                  Podiatric Medicine Residency Programs 600601
#> 1848:                  Podiatric Medicine Residency Programs 600602
#> 1849:                      Undecided/Unspecified (non-IPEDS) 999999
#>                                                            cip6name
#>                                                              <char>
#>    1:                                          Agriculture, General
#>    2:                 Agricultural Business and Management, General
#>    3:                 Agribusiness/Agricultural Business Operations
#>    4:                                        Agricultural Economics
#>    5:                                Farm/Farm and Ranch Management
#>   ---                                                              
#> 1845:                          Vascular Neurology Residency Program
#> 1846: Medical Residency Programs - Subspecialty Certificates, Other
#> 1847:         Podiatric Medicine and Surgery - 24 Residency Program
#> 1848:         Podiatric Medicine and Surgery - 36 Residency Program
#> 1849:                             Undecided/Unspecified (non-IPEDS)
```

*Verify prepared data.*   `cip2010`, included with midfieldr, contains
the CIP data frame developed above. Here we verify that the two data
frames have the same content.

``` r

# Demonstrate equivalence
check_equiv_frames(DT, cip2010)
#> [1] TRUE
```

## Usage

To use the alternative CIP data set included with midfieldr, use
`cip2010` as the value of the `cip` argument. For example,

``` r

# Using the midfieldr default
filter_cip("^1408", cip = cip)
#>      cip2    cip2name   cip4          cip4name   cip6
#>    <char>      <char> <char>            <char> <char>
#> 1:     14 Engineering   1408 Civil Engineering 140801
#> 2:     14 Engineering   1408 Civil Engineering 140802
#> 3:     14 Engineering   1408 Civil Engineering 140803
#> 4:     14 Engineering   1408 Civil Engineering 140804
#> 5:     14 Engineering   1408 Civil Engineering 140805
#> 6:     14 Engineering   1408 Civil Engineering 140899
#>                                  cip6name
#>                                    <char>
#> 1:             Civil Engineering, General
#> 2:               Geotechnical Engineering
#> 3:                 Structural Engineering
#> 4: Transportation and Highway Engineering
#> 5:            Water Resources Engineering
#> 6:               Civil Engineering, Other


# Using the alternate cip
filter_cip("^1408", cip = cip2010)
#>      cip2    cip2name   cip4          cip4name   cip6
#>    <char>      <char> <char>            <char> <char>
#> 1:     14 Engineering   1408 Civil Engineering 140801
#> 2:     14 Engineering   1408 Civil Engineering 140802
#> 3:     14 Engineering   1408 Civil Engineering 140803
#> 4:     14 Engineering   1408 Civil Engineering 140804
#> 5:     14 Engineering   1408 Civil Engineering 140805
#> 6:     14 Engineering   1408 Civil Engineering 140899
#>                                         cip6name
#>                                           <char>
#> 1:                    Civil Engineering, General
#> 2: Geotechnical and Geoenvironmental Engineering
#> 3:                        Structural Engineering
#> 4:        Transportation and Highway Engineering
#> 5:                   Water Resources Engineering
#> 6:                      Civil Engineering, Other
```

Here we see an instance of a minor program title difference between the
two datasets. The other program names in this major are identical.

- 140802 Geotechnical Engineering (`cip`)
- 140802 Geotechnical and Geoenvironmental Engineering (`cip2010`)

------------------------------------------------------------------------

[◁
Programs](https://midfieldr.github.io/midfieldr/articles/art-040-programs.md)
   [▲ top of page](#top)    [Blocs
▷](https://midfieldr.github.io/midfieldr/articles/art-050-blocs.md)

------------------------------------------------------------------------

## References

NCES. 2026. *IPEDS Classification of Instructional Programs (CIP)*.
National Center for Education Statistics.
<https://nces.ed.gov/ipeds/cipcode/>.

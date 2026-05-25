# Alternative CIPs

Transforming primary-source program data from the US Integrated
Postsecondary Education Data System (IPEDS) to the CIP data structure
used by midfieldr.

As of this writing (2026–05), the 2020 and 2010 (and earlier) versions
of the US Classification of Instructional Programs (CIP) codes are
downloadable from the IPEDS website ([NCES 2026](#ref-cipcode:2026))
under file names:

- `CIPCode2020.csv`
- `CIPCode2010.csv`

In this article, we demonstrate transforming the data in the 2010 source
file into the form required by midfieldr, resulting in the new data set
`cip2010` included with the latest version of midfieldr. The procedure
could be used to perform a similar transformation of `CIPCode2020.csv`
as well.

## Goals

The data set `cip` included with the earliest version of midfieldr is
based on the IPEDS 2010 CIP data. However, `cip` content is not
identical to the `cip2010` content. There are some typographical
differences and the original `cip` data has fewer rows, thus fewer
6-digit codes.

If for any reason the legacy `cip` data set fails to meet a user’s
needs, an alternative is to use the 2010 or 2020 primary-source data
files from IPEDS. In this article, we demonstrate how to transform such
data to the CIP format usable by the midfieldr tools.

If you are writing your own script to follow along, we use these
packages in this article:

``` r

# Load packages
library(midfieldr)
library(data.table)
```

*Usage.*   To use the alternative CIP data set included with midfieldr,
use `cip2010` as the value of the `cip` argument. For example,

``` r

# Using the default cip
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

## Get started

Assign a new name to the legacy `cip` data set included with midfieldr,
allowing us retain the original data set while using the name `cip` for
the new work.

``` r

# Allows us to use "cip" as an object name  
legacy_cip <- copy(midfieldr::cip)
```

The first step is to download the CSV file from the IPEDs website. After
saving it to a convenient directory, construct a path to that file
(`path_to_csv_file`) and import the data with:

``` r

# Import the 2010 CIP file in data.table format
cip <- fread(path_to_csv_file, colClasses = "character")
```

The
[`dplyr::glimpse()`](https://pillar.r-lib.org/reference/glimpse.html)
function is quite useful for a first impression of the data. (One could
also use base R [`str()`](https://rdrr.io/r/utils/str.html).)

``` r

# View the result
dplyr::glimpse(cip)
#> Rows: 2,318
#> Columns: 8
#> $ CIPFamily       <chr> "01", "01", "01", "01", "01", "01", "01", "01", "01", …
#> $ CIPCode         <chr> "01", "01.00", "01.0000", "01.01", "01.0101", "01.0102…
#> $ Action          <chr> "No substantive changes", "No substantive changes", "N…
#> $ TextChange      <chr> "no", "no", "no", "no", "no", "no", "no", "no", "no", …
#> $ CIPTitle        <chr> "AGRICULTURE, AGRICULTURE OPERATIONS, AND RELATED SCIE…
#> $ CIPDefinition   <chr> "Instructional programs that focus on agriculture and …
#> $ CrossReferences <chr> "", "", "14.0301 - Agricultural Engineering.", "", "",…
#> $ Examples        <chr> "", "", "", "", "", "Examples: - Agricultural Systems …
```

To construct our own CIP data set, we need three columns:

``` r

# Select columns
cols_we_want <- c("CIPFamily", "CIPCode", "CIPTitle")
cip <- cip[, ..cols_we_want]

# View the result
dplyr::glimpse(cip)
#> Rows: 2,318
#> Columns: 3
#> $ CIPFamily <chr> "01", "01", "01", "01", "01", "01", "01", "01", "01", "01", …
#> $ CIPCode   <chr> "01", "01.00", "01.0000", "01.01", "01.0101", "01.0102", "01…
#> $ CIPTitle  <chr> "AGRICULTURE, AGRICULTURE OPERATIONS, AND RELATED SCIENCES."…
```

Closer look at a sample of our primary-source data.

``` r

# Set the seed for reproducibility 
set.seed(202612)

# Extract a sample of 15 rows and reset the seed
x <- cip[sample(100:400, 15)]
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

When constructing the midfieldr legacy CIP data set, some values were
changed from those in the source file, such as removing the decimal
point separator in the 4- and 6-digit codes or replacing slashes (“/”)
with commas (“,”). For example, compare the `13.1209` entry above to its
equivalent in the midfieldr legacy CIP data:

``` r

# CIPCode2010
filter_cip("13.1209", cip = cip)
#>    CIPFamily CIPCode                                       CIPTitle
#>       <char>  <char>                                         <char>
#> 1:        13 13.1209 Kindergarten/Preschool Education and Teaching.

# midfieldr
filter_cip("131209", cip = legacy_cip)[, .(cip2, cip6, cip6name)]
#>      cip2   cip6                                       cip6name
#>    <char> <char>                                         <char>
#> 1:     13 131209 Kindergarten, Preschool Education and Teaching
```

Additionally, source-file 2-digit program names are in all-caps; in
midfieldr all program names are in title-case.

``` r

# CIPCode2010
unique(cip[CIPCode == "04"])[, .(CIPCode, CIPTitle)]
#>    CIPCode                           CIPTitle
#>     <char>                             <char>
#> 1:      04 ARCHITECTURE AND RELATED SERVICES.

# midfieldr
unique(filter_cip("^04", cip = legacy_cip)[, .(cip2, cip2name)])
#>      cip2                          cip2name
#>    <char>                            <char>
#> 1:     04 Architecture and Related Services
```

## Transforming the source data

*Editing.*   Omit the periods in the codes and titles.

``` r

# Omit the period separator on the CIP code
cip <- cip[, CIPCode := gsub("[.]", "", CIPCode)]

# Omit the period at the end of each title
cip <- cip[, CIPTitle := gsub("[.]", "", CIPTitle)]

# Verify the result
filter_cip("131209", cip = cip)
#>    CIPFamily CIPCode                                      CIPTitle
#>       <char>  <char>                                        <char>
#> 1:        13  131209 Kindergarten/Preschool Education and Teaching
```

Count the number of digits in `CIPCode`, expected to be 2, 4, or 6.

``` r

# Add a column
cip[, N_digits := nchar(CIPCode)]

# View result
dplyr::glimpse(cip)
#> Rows: 2,318
#> Columns: 4
#> $ CIPFamily <chr> "01", "01", "01", "01", "01", "01", "01", "01", "01", "01", …
#> $ CIPCode   <chr> "01", "0100", "010000", "0101", "010101", "010102", "010103"…
#> $ CIPTitle  <chr> "AGRICULTURE, AGRICULTURE OPERATIONS, AND RELATED SCIENCES",…
#> $ N_digits  <int> 2, 4, 6, 4, 6, 6, 6, 6, 6, 6, 6, 4, 6, 6, 6, 6, 4, 6, 6, 6, …

# Confirm 2, 4, or 6 digits
unique(cip$N_digits)
#> [1] 2 4 6
```

*Split*   Create a separate data frame for 2-digit codes and names,
keyed by `CIPFamily`.

``` r

# Unique 2-digit codes and names
cip2 <- cip[N_digits == 2, .(CIPFamily, 
                             cip2 = CIPCode, 
                             cip2name = CIPTitle)]
# View the result
dplyr::glimpse(cip2)
#> Rows: 48
#> Columns: 3
#> $ CIPFamily <chr> "01", "03", "04", "05", "09", "10", "11", "12", "13", "14", …
#> $ cip2      <chr> "01", "03", "04", "05", "09", "10", "11", "12", "13", "14", …
#> $ cip2name  <chr> "AGRICULTURE, AGRICULTURE OPERATIONS, AND RELATED SCIENCES",…
```

Repeat for the 4-digit codes and names and add a 2-digit code extracted
from the `CIPCode` column we can compare to `CIPFamily` to ensure they
agree.

``` r

# Unique 4-digit codes and names, with cip2 codes derived from cip4
cip4 <- cip[N_digits == 4, .(CIPFamily, 
                             cip2 = substr(CIPCode, 1, 2), 
                             cip4 = CIPCode, 
                             cip4name = CIPTitle)]
# View the result
dplyr::glimpse(cip4)
#> Rows: 422
#> Columns: 4
#> $ CIPFamily <chr> "01", "01", "01", "01", "01", "01", "01", "01", "01", "01", …
#> $ cip2      <chr> "01", "01", "01", "01", "01", "01", "01", "01", "01", "01", …
#> $ cip4      <chr> "0100", "0101", "0102", "0103", "0104", "0105", "0106", "010…
#> $ cip4name  <chr> "Agriculture, General", "Agricultural Business and Managemen…
```

Repeat for the 6-digit codes and names.

``` r

# Unique 6-digit codes and names, with cip2 and cip4 codes derived from cip6
cip6 <- cip[N_digits == 6, .(CIPFamily, 
                             cip2 = substr(CIPCode, 1, 2), 
                             cip4 = substr(CIPCode, 1, 4), 
                             cip6 = CIPCode, 
                             cip6name = CIPTitle)]
# View the result
dplyr::glimpse(cip6)
#> Rows: 1,848
#> Columns: 5
#> $ CIPFamily <chr> "01", "01", "01", "01", "01", "01", "01", "01", "01", "01", …
#> $ cip2      <chr> "01", "01", "01", "01", "01", "01", "01", "01", "01", "01", …
#> $ cip4      <chr> "0100", "0101", "0101", "0101", "0101", "0101", "0101", "010…
#> $ cip6      <chr> "010000", "010101", "010102", "010103", "010104", "010105", …
#> $ cip6name  <chr> "Agriculture, General", "Agricultural Business and Managemen…
```

Compare the 2-digit codes in each data frame. If the data were correctly
entered, this check for equality should all be TRUE.

``` r

# This check for 2-digit equality should all be TRUE
all.equal(cip2$CIPFamily, cip2$cip2)
#> [1] TRUE
all.equal(cip4$CIPFamily, cip4$cip2)
#> [1] TRUE
all.equal(cip6$CIPFamily, cip6$cip2)
#> [1] TRUE
```

*Editing.*   Convert the 2-digit names from all-caps to title-case. Here
we use two functions from the stringr package.

``` r

library(stringr)

# Convert to title case
cip2[, cip2name := str_to_title(cip2name)]

# Use lowercase "and"
cip2[, cip2name := str_replace_all(cip2name, "And", "and")]

# View result
cip2[, .(cip2, cip2name)]
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
cip6 <- cip6[, ..cols_we_want]

# Select 4-digit columns
cols_we_want <- c("cip2", "cip4", "cip4name")
cip4 <- cip4[, ..cols_we_want]

# Select 2-digit columns
cols_we_want <- c("cip2", "cip2name")
cip2 <- cip2[, ..cols_we_want]
```

Now, left-join `cip4` to `cip6`, matching on the 2- and 4-digit code
columns.

``` r

# Join `cip4` to `cip6` 
cip <- cip4[cip6, on = c("cip2", "cip4")]
```

Now, left-join `cip2` to the result, matching on the 2-digit code
columns.

``` r

# Left join `cip2` to `cip` from above
cip <- cip2[cip, on = c("cip2")]

# Ensure row order and examine the result
setorderv(cip, c("cip6"))
cip
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

## Program undecided or unspecified

Lastly, we add a row to the CIP data to includes one non-IPEDS code
(999999) for Undecided or Unspecified, instances in which institutions
reported no program information or that students were not enrolled in a
program.

``` r

name_99 <- "Undecided/Unspecified (non-IPEDS)"
row_99  <- data.table(cip2 = "99", 
                            cip4 = "9999", 
                            cip6 = "999999", 
                            cip2name = name_99, 
                            cip4name = name_99, 
                            cip6name = name_99)


cip <- rbindlist(list(cip, row_99), use.names = TRUE)
cip
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
check_equiv_frames(cip, cip2010)
#> [1] TRUE
```

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

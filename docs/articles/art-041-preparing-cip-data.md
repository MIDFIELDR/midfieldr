# Preparing CIP data

In this article, we document creating a Classification of Instructional
Programs (CIP) dataset using primary source data from the US Integrated
Postsecondary Education Data System (IPEDS).

## Introduction

As of this writing (2026–09–30), the IPEDS website ([NCES,
2026](#ref-cipcode:2026)) provides downloadable CSV files for the 2010
and 2020 CIP data via their “Resources” tab under the file names:

- `CIPCode2010.csv`
- `CIPCode2020.csv`

In this article, we document our procedure for downloading and
converting `CIPCode2010.csv` data into the midfieldr-friendly `cip2010`
dataset that loads with midfieldr.

``` r

library("midfieldr")
cip2010
#>                                                    cip6name   cip6
#>                                                      <char> <char>
#>    1:                                  Agriculture, General 010000
#>    2:         Agricultural Business and Management, General 010101
#>    3:         Agribusiness/Agricultural Business Operations 010102
#>   ---                                                             
#> 1847: Podiatric Medicine and Surgery - 24 Residency Program 600601
#> 1848: Podiatric Medicine and Surgery - 36 Residency Program 600602
#> 1849:                     Undecided/Unspecified (non-IPEDS) 999999
#>                                    cip4name   cip4
#>                                      <char> <char>
#>    1:                  Agriculture, General   0100
#>    2:  Agricultural Business and Management   0101
#>    3:  Agricultural Business and Management   0101
#>   ---                                             
#> 1847: Podiatric Medicine Residency Programs   6006
#> 1848: Podiatric Medicine Residency Programs   6006
#> 1849:     Undecided/Unspecified (non-IPEDS)   9999
#>                                                        cip2name   cip2
#>                                                          <char> <char>
#>    1: Agriculture, Agriculture Operations, and Related Sciences     01
#>    2: Agriculture, Agriculture Operations, and Related Sciences     01
#>    3: Agriculture, Agriculture Operations, and Related Sciences     01
#>   ---                                                                 
#> 1847:                                        Residency Programs     60
#> 1848:                                        Residency Programs     60
#> 1849:                         Undecided/Unspecified (non-IPEDS)     99
```

The original midfieldr dataset `cip` was also based on the 2010 CIP data
but with 267 fewer rows, the majority of which (225 rows) are medical or
dental residencies—programs that were not germane to the original
MIDFIELD project. The new data set `cip2010` restores those missing
rows.

Should the need arise for the more recent 2020 CIP data, the procedure
documented here could be used to convert the `CIPCode2020.csv` data into
a midfieldr-friendly `cip2020` dataset.

## Examine the raw data

Because we set some options as well as the random number seed, we save
their existing settings to be restored at the end.

``` r

backup_options <- options()
backup_seed <- NULL
if (exists(".Random.seed")) backup_seed <- .Random.seed

library("midfieldr")
library("data.table")
library("stringr")
```

The CSV files are available for download from IPEDS
([2026](#ref-cipcode:2026)). Save the file to a convenient directory.
Construct a path (in quotes) to that file, substitute your path for the
placeholder `path_to_csv_file,` and import the data.

``` r

# import data
DT <- fread(path_to_csv_file, colClasses = "character")

# result
look_at(DT)
#> Classes 'data.table' and 'data.frame':   2318 obs. of  8 variables:
#>  $ CIPFamily      : chr  "01" "01" "01" "01" ...
#>  $ CIPCode        : chr  "01" "01.00" "01.0000" "01.01" ...
#>  $ Action         : chr  "No substantive changes" "No substantive changes" "N"..
#>  $ TextChange     : chr  "no" "no" "no" "no" ...
#>  $ CIPTitle       : chr  "AGRICULTURE, AGRICULTURE OPERATIONS, AND RELATED SC"..
#>  $ CIPDefinition  : chr  "Instructional programs that focus on agriculture an"..
#>  $ CrossReferences: chr  "" "" "14.0301 - Agricultural Engineering." "" ...
#>  $ Examples       : chr  "" "" "" "" ...
```

To construct a midfieldr-style data set, we need three columns:

``` r

cols_we_want <- c("CIPFamily", "CIPCode", "CIPTitle")
DT <- DT[, ..cols_we_want]

look_at(DT)
#> Classes 'data.table' and 'data.frame':   2318 obs. of  3 variables:
#>  $ CIPFamily: chr  "01" "01" "01" "01" ...
#>  $ CIPCode  : chr  "01" "01.00" "01.0000" "01.01" ...
#>  $ CIPTitle : chr  "AGRICULTURE, AGRICULTURE OPERATIONS, AND RELATED SCIENCES"..
```

Closer look at a sample of our primary-source data.

``` r

# set the seed for reproducibility
set.seed(202612)

# sample 15 rows and order by the CIP code
x <- DT[sample(100:400, 15)]
setorderv(x, "CIPCode")

# result
x
#>     CIPFamily CIPCode                                             CIPTitle
#>        <char>  <char>                                               <char>
#>  1:        04      04                   ARCHITECTURE AND RELATED SERVICES.
#>  2:        04   04.10                             Real Estate Development.
#>  3:        05 05.0117                                      Baltic Studies.
#>  4:        09 09.0102                    Mass Communication/Media Studies.
#>  5:        10   10.02 Audiovisual Communications Technologies/Technicians.
#>  6:        10 10.0302                                 Printing Management.
#> ---                                                                       
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
filter_programs(DT, "13.1209")
#>    CIPFamily CIPCode                                       CIPTitle
#>       <char>  <char>                                         <char>
#> 1:        13 13.1209 Kindergarten/Preschool Education and Teaching.

# midfieldr default
filter_programs(cip, "131209")[, .(cip2, cip6, cip6name)]
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

## Transforming the raw data

### *Omit periods*

Omit the periods in the codes and titles.

``` r

DT <- DT[, CIPCode := gsub("[.]", "", CIPCode)]
DT <- DT[, CIPTitle := gsub("[.]", "", CIPTitle)]

# confirm result
filter_programs(DT, "131209")
#>    CIPFamily CIPCode                                      CIPTitle
#>       <char>  <char>                                        <char>
#> 1:        13  131209 Kindergarten/Preschool Education and Teaching
```

### *Split the data frame*

Here we split the data frame into 2-, 4-, and 6-digit subsets. Start by
counting the number of digits in `CIPCode`, expected to be 2, 4, or 6.

``` r

# add a column of digit counts
DT[, N_digits := str_length(CIPCode)]

# confirm 2, 4, or 6 digits
unique(DT$N_digits)
#> [1] 2 4 6

# result
look_at(DT)
#> Classes 'data.table' and 'data.frame':   2318 obs. of  4 variables:
#>  $ CIPFamily: chr  "01" "01" "01" "01" ...
#>  $ CIPCode  : chr  "01" "0100" "010000" "0101" ...
#>  $ CIPTitle : chr  "AGRICULTURE, AGRICULTURE OPERATIONS, AND RELATED SCIENCES"..
#>  $ N_digits : int  2 4 6 4 6 6 6 6 6 6 ...
```

Create a separate data frame for 2-digit codes and names. We will use
the new `cip2` variable to check our results—it should be a duplicate of
`CIPFamily.`

``` r

DT2 <- DT[N_digits == 2, .(CIPFamily,
  cip2 = CIPCode,
  cip2name = CIPTitle
)]

look_at(DT2)
#> Classes 'data.table' and 'data.frame':   48 obs. of  3 variables:
#>  $ CIPFamily: chr  "01" "03" "04" "05" ...
#>  $ cip2     : chr  "01" "03" "04" "05" ...
#>  $ cip2name : chr  "AGRICULTURE, AGRICULTURE OPERATIONS, AND RELATED SCIENCES"..
```

Repeat for the 4-digit codes and names. Extract the first two digits of
`CIPCode` to compare to `CIPFamily.`

``` r

DT4 <- DT[N_digits == 4, .(CIPFamily,
  cip2 = substr(CIPCode, 1, 2),
  cip4 = CIPCode,
  cip4name = CIPTitle
)]

look_at(DT4)
#> Classes 'data.table' and 'data.frame':   422 obs. of  4 variables:
#>  $ CIPFamily: chr  "01" "01" "01" "01" ...
#>  $ cip2     : chr  "01" "01" "01" "01" ...
#>  $ cip4     : chr  "0100" "0101" "0102" "0103" ...
#>  $ cip4name : chr  "Agriculture, General" "Agricultural Business and Manageme"..
```

Repeat for the 6-digit codes and names.

``` r

DT6 <- DT[N_digits == 6, .(CIPFamily,
  cip2 = substr(CIPCode, 1, 2),
  cip4 = substr(CIPCode, 1, 4),
  cip6 = CIPCode,
  cip6name = CIPTitle
)]

look_at(DT6)
#> Classes 'data.table' and 'data.frame':   1848 obs. of  5 variables:
#>  $ CIPFamily: chr  "01" "01" "01" "01" ...
#>  $ cip2     : chr  "01" "01" "01" "01" ...
#>  $ cip4     : chr  "0100" "0101" "0101" "0101" ...
#>  $ cip6     : chr  "010000" "010101" "010102" "010103" ...
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

### *Editing*

Convert the 2-digit names from all-caps to title-case. Here we use two
functions from the stringr package.

``` r

DT2[, cip2name := str_to_title(cip2name)]
DT2[, cip2name := str_replace_all(cip2name, "And", "and")]

DT2[, .(cip2, cip2name)]
#>       cip2                                                      cip2name
#>     <char>                                                        <char>
#>  1:     01     Agriculture, Agriculture Operations, and Related Sciences
#>  2:     03                            Natural Resources and Conservation
#>  3:     04                             Architecture and Related Services
#>  4:     05             Area, Ethnic, Cultural, Gender, and Group Studies
#>  5:     09               Communication, Journalism, and Related Programs
#>  6:     10  Communications Technologies/Technicians and Support Services
#> ---                                                                     
#> 43:     50                                    Visual and Performing Arts
#> 44:     51                       Health Professions and Related Programs
#> 45:     52 Business, Management, Marketing, and Related Support Services
#> 46:     53               High School/Secondary Diplomas and Certificates
#> 47:     54                                                       History
#> 48:     60                                            Residency Programs
```

### *Rejoin data frames*

Select the columns we want for the joining operations.

``` r

cols_we_want <- c("cip2", "cip4", "cip6", "cip6name")
DT6 <- DT6[, ..cols_we_want]

cols_we_want <- c("cip2", "cip4", "cip4name")
DT4 <- DT4[, ..cols_we_want]

cols_we_want <- c("cip2", "cip2name")
DT2 <- DT2[, ..cols_we_want]
```

Left-join `cip4` to `cip6`, matching on the 2- and 4-digit code columns.
Reuse the object name `DT` for our new working data frame. Left-join
`cip2` to the result, matching on the 2-digit code columns.

``` r

DT <- DT4[DT6, on = c("cip2", "cip4")]

DT <- DT2[DT, on = c("cip2")]
```

Order rows and columns.

``` r

setorderv(DT, c("cip6"))
setcolorder(DT, c("cip6name", "cip6", "cip4name", "cip4", "cip2name", "cip2"))

DT
#>                                                            cip6name   cip6
#>                                                              <char> <char>
#>    1:                                          Agriculture, General 010000
#>    2:                 Agricultural Business and Management, General 010101
#>    3:                 Agribusiness/Agricultural Business Operations 010102
#>    4:                                        Agricultural Economics 010103
#>    5:                                Farm/Farm and Ranch Management 010104
#>    6:          Agricultural/Farm Supplies Retailing and Wholesaling 010105
#>   ---                                                                     
#> 1843:            Undersea and Hyperbaric Medicine Residency Program 600582
#> 1844:       Vascular and Interventional Radiology Residency Program 600583
#> 1845:                          Vascular Neurology Residency Program 600584
#> 1846: Medical Residency Programs - Subspecialty Certificates, Other 600599
#> 1847:         Podiatric Medicine and Surgery - 24 Residency Program 600601
#> 1848:         Podiatric Medicine and Surgery - 36 Residency Program 600602
#>                                                     cip4name   cip4
#>                                                       <char> <char>
#>    1:                                   Agriculture, General   0100
#>    2:                   Agricultural Business and Management   0101
#>    3:                   Agricultural Business and Management   0101
#>    4:                   Agricultural Business and Management   0101
#>    5:                   Agricultural Business and Management   0101
#>    6:                   Agricultural Business and Management   0101
#>   ---                                                              
#> 1843: Medical Residency Programs - Subspecialty Certificates   6005
#> 1844: Medical Residency Programs - Subspecialty Certificates   6005
#> 1845: Medical Residency Programs - Subspecialty Certificates   6005
#> 1846: Medical Residency Programs - Subspecialty Certificates   6005
#> 1847:                  Podiatric Medicine Residency Programs   6006
#> 1848:                  Podiatric Medicine Residency Programs   6006
#>                                                        cip2name   cip2
#>                                                          <char> <char>
#>    1: Agriculture, Agriculture Operations, and Related Sciences     01
#>    2: Agriculture, Agriculture Operations, and Related Sciences     01
#>    3: Agriculture, Agriculture Operations, and Related Sciences     01
#>    4: Agriculture, Agriculture Operations, and Related Sciences     01
#>    5: Agriculture, Agriculture Operations, and Related Sciences     01
#>    6: Agriculture, Agriculture Operations, and Related Sciences     01
#>   ---                                                                 
#> 1843:                                        Residency Programs     60
#> 1844:                                        Residency Programs     60
#> 1845:                                        Residency Programs     60
#> 1846:                                        Residency Programs     60
#> 1847:                                        Residency Programs     60
#> 1848:                                        Residency Programs     60
```

If we’ve joined correctly, the following logical checks should yield
`TRUE` in all cases.

``` r

# cip4(first 2 digits) should match cip2
unique(substr(DT$cip4, 1, 2) == DT$cip2) == TRUE
#> [1] TRUE

# cip6(first 2 digits) should match cip2
unique(substr(DT$cip6, 1, 2) == DT$cip2) == TRUE
#> [1] TRUE

# cip6(first 4 digits) should match cip4
unique(substr(DT$cip6, 1, 4) == DT$cip4) == TRUE
#> [1] TRUE
```

### Unspecified programs

Lastly, we add a row to the CIP data to includes one non-IPEDS code
(999999) for Undecided or Unspecified, instances in which institutions
reported no program information or that students were not enrolled in a
program.

Create a data frame with one row.

``` r

txt_99 <- "Undecided/Unspecified (non-IPEDS)"
row_99 <- data.table(
  cip2 = "99",
  cip4 = "9999",
  cip6 = "999999",
  cip2name = txt_99,
  cip4name = txt_99,
  cip6name = txt_99
)
```

Row-bind to our working data frame.

``` r

DT <- rbindlist(list(DT, row_99), use.names = TRUE)
DT
#>                                                            cip6name   cip6
#>                                                              <char> <char>
#>    1:                                          Agriculture, General 010000
#>    2:                 Agricultural Business and Management, General 010101
#>    3:                 Agribusiness/Agricultural Business Operations 010102
#>    4:                                        Agricultural Economics 010103
#>    5:                                Farm/Farm and Ranch Management 010104
#>    6:          Agricultural/Farm Supplies Retailing and Wholesaling 010105
#>   ---                                                                     
#> 1844:       Vascular and Interventional Radiology Residency Program 600583
#> 1845:                          Vascular Neurology Residency Program 600584
#> 1846: Medical Residency Programs - Subspecialty Certificates, Other 600599
#> 1847:         Podiatric Medicine and Surgery - 24 Residency Program 600601
#> 1848:         Podiatric Medicine and Surgery - 36 Residency Program 600602
#> 1849:                             Undecided/Unspecified (non-IPEDS) 999999
#>                                                     cip4name   cip4
#>                                                       <char> <char>
#>    1:                                   Agriculture, General   0100
#>    2:                   Agricultural Business and Management   0101
#>    3:                   Agricultural Business and Management   0101
#>    4:                   Agricultural Business and Management   0101
#>    5:                   Agricultural Business and Management   0101
#>    6:                   Agricultural Business and Management   0101
#>   ---                                                              
#> 1844: Medical Residency Programs - Subspecialty Certificates   6005
#> 1845: Medical Residency Programs - Subspecialty Certificates   6005
#> 1846: Medical Residency Programs - Subspecialty Certificates   6005
#> 1847:                  Podiatric Medicine Residency Programs   6006
#> 1848:                  Podiatric Medicine Residency Programs   6006
#> 1849:                      Undecided/Unspecified (non-IPEDS)   9999
#>                                                        cip2name   cip2
#>                                                          <char> <char>
#>    1: Agriculture, Agriculture Operations, and Related Sciences     01
#>    2: Agriculture, Agriculture Operations, and Related Sciences     01
#>    3: Agriculture, Agriculture Operations, and Related Sciences     01
#>    4: Agriculture, Agriculture Operations, and Related Sciences     01
#>    5: Agriculture, Agriculture Operations, and Related Sciences     01
#>    6: Agriculture, Agriculture Operations, and Related Sciences     01
#>   ---                                                                 
#> 1844:                                        Residency Programs     60
#> 1845:                                        Residency Programs     60
#> 1846:                                        Residency Programs     60
#> 1847:                                        Residency Programs     60
#> 1848:                                        Residency Programs     60
#> 1849:                         Undecided/Unspecified (non-IPEDS)     99
```

Here, we verify that the CIP dataset just completed is identical to the
`cip2010` dataset that loads with midfieldr.

``` r

check_equiv_frames(DT, cip2010)
#> [1] TRUE
```

## Usage

To use the alternative CIP data set included with midfieldr, use
`cip2010` as the value of the first argument in `filter_programs().`
Compare, for example,

``` r

filter_programs(cip, "^1408")[, .(cip6name, cip6)]
#>                                  cip6name   cip6
#>                                    <char> <char>
#> 1:             Civil Engineering, General 140801
#> 2:               Geotechnical Engineering 140802
#> 3:                 Structural Engineering 140803
#> 4: Transportation and Highway Engineering 140804
#> 5:            Water Resources Engineering 140805
#> 6:               Civil Engineering, Other 140899

filter_programs(cip2010, "^1408")[, .(cip6name, cip6)]
#>                                         cip6name   cip6
#>                                           <char> <char>
#> 1:                    Civil Engineering, General 140801
#> 2: Geotechnical and Geoenvironmental Engineering 140802
#> 3:                        Structural Engineering 140803
#> 4:        Transportation and Highway Engineering 140804
#> 5:                   Water Resources Engineering 140805
#> 6:                      Civil Engineering, Other 140899
```

Here we see an instance of a minor difference in program names between
the two datasets.

- `cip:` 140802 Geotechnical Engineering
- `cip2010:` 140802 Geotechnical and Geoenvironmental Engineering

Alternatively, one can simply rename the alternate dataset for the
convenience of the shorter name and overwrite `cip.`

``` r

cip <- copy(cip2010)
check_equiv_frames(cip, cip2010)
#> [1] TRUE
```

The originals can be recovered as follows,

``` r

data(list = c("cip", "cip2010"), 
     package = "midfieldr", 
     overwrite = TRUE)
```

And the two datasets are no longer equivalent. Using the example from
above,

``` r

check_equiv_frames(cip, cip2010)
#> [1] FALSE

filter_programs(cip, "^1408")[, .(cip6name, cip6)]
#>                                  cip6name   cip6
#>                                    <char> <char>
#> 1:             Civil Engineering, General 140801
#> 2:               Geotechnical Engineering 140802
#> 3:                 Structural Engineering 140803
#> 4: Transportation and Highway Engineering 140804
#> 5:            Water Resources Engineering 140805
#> 6:               Civil Engineering, Other 140899

filter_programs(cip2010, "^1408")[, .(cip6name, cip6)]
#>                                         cip6name   cip6
#>                                           <char> <char>
#> 1:                    Civil Engineering, General 140801
#> 2: Geotechnical and Geoenvironmental Engineering 140802
#> 3:                        Structural Engineering 140803
#> 4:        Transportation and Highway Engineering 140804
#> 5:                   Water Resources Engineering 140805
#> 6:                      Civil Engineering, Other 140899
```

## Wrap up

Restore options and random number generator to their original settings.

``` r

if (!is.null(backup_seed)) .Random.seed <- backup_seed
options(backup_options)
```

## References

NCES. (2026). *IPEDS Classification of Instructional Programs (CIP)*.
National Center for Education Statistics.
<https://nces.ed.gov/ipeds/cipcode/>

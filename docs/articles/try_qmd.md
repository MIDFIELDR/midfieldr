# Try a QMD script

### Hello

``` r

data(student, term, degree)
```

- data.table
- dplyr

``` r

student_DT <- copy(student)
term_DT <- copy(term)
degree_DT <- copy(degree)
```

``` r

student_TB <- as_tibble(student)
term_TB <- as_tibble(term)
degree_TB <- as_tibble(degree)
```

``` r

class(student)
```

    ## [1] "data.table" "data.frame"

``` r

class(student_DT)
```

    ## [1] "data.table" "data.frame"

``` r

class(student_TB)
```

    ## [1] "tbl_df"     "tbl"        "data.frame"

``` r

check_equiv_frames(student_DT, student_TB)
```

    ## [1] TRUE

## Population

The baseline population used for most studies consists of degree-seeking
students whose records satisfy the data sufficiency requirement.

### Degree-seeking

By design, the `student` data table contains all (and only)
degree-seeking students. Thus we start with those IDs.

- data.table
- dplyr

``` r

DT <- student_DT[, .(mcid)]
```

``` r

TB <- student_DT %>%
  select(mcid)
```

``` r

DT
```

    ##                  mcid
    ##                <char>
    ##     1: MCID3111142225
    ##     2: MCID3111142283
    ##     3: MCID3111142290
    ##     4: MCID3111142294
    ##     5: MCID3111142299
    ##    ---               
    ## 97551: MCID3112898886
    ## 97552: MCID3112898890
    ## 97553: MCID3112898894
    ## 97554: MCID3112898895
    ## 97555: MCID3112898940

``` r

check_equiv_frames(DT, TB)
```

    ## [1] TRUE

### Data sufficiency

We use
[`timely_term()`](https://midfieldr.github.io/midfieldr/reference/timely_term.md)
to determine the timely completion term for the degree-seeking students
and add columns to the data frame to support those findings.

- data.table
- dplyr

``` r

DT <- timely_term(DT, midf_table = term_DT)
DT
```

    ##                  mcid entry_term   entry_level adj_span timely_term
    ##                <char>     <char>        <char>    <num>      <char>
    ##     1: MCID3111142225      19881 01 First-year        6       19933
    ##     2: MCID3111142283      19881 01 First-year        6       19933
    ##     3: MCID3111142290      19881 01 First-year        6       19933
    ##     4: MCID3111142294      19881 01 First-year        6       19933
    ##     5: MCID3111142299      19881 01 First-year        6       19933
    ##    ---                                                             
    ## 97551: MCID3112898886      20181 01 First-year        6       20233
    ## 97552: MCID3112898890      20181 01 First-year        6       20233
    ## 97553: MCID3112898894      20181 01 First-year        6       20233
    ## 97554: MCID3112898895      20181 01 First-year        6       20233
    ## 97555: MCID3112898940      20181 01 First-year        6       20233

``` r

TB <- timely_term(TB, midf_table = term_TB)
TB
```

    ##                  mcid entry_term   entry_level adj_span timely_term
    ##                <char>     <char>        <char>    <num>      <char>
    ##     1: MCID3111142225      19881 01 First-year        6       19933
    ##     2: MCID3111142283      19881 01 First-year        6       19933
    ##     3: MCID3111142290      19881 01 First-year        6       19933
    ##     4: MCID3111142294      19881 01 First-year        6       19933
    ##     5: MCID3111142299      19881 01 First-year        6       19933
    ##    ---                                                             
    ## 97551: MCID3112898886      20181 01 First-year        6       20233
    ## 97552: MCID3112898890      20181 01 First-year        6       20233
    ## 97553: MCID3112898894      20181 01 First-year        6       20233
    ## 97554: MCID3112898895      20181 01 First-year        6       20233
    ## 97555: MCID3112898940      20181 01 First-year        6       20233

``` r

DT[order(entry_level)]
```

    ##                  mcid entry_term    entry_level adj_span timely_term
    ##                <char>     <char>         <char>    <num>      <char>
    ##     1: MCID3111142225      19881  01 First-year        6       19933
    ##     2: MCID3111142283      19881  01 First-year        6       19933
    ##     3: MCID3111142290      19881  01 First-year        6       19933
    ##     4: MCID3111142294      19881  01 First-year        6       19933
    ##     5: MCID3111142299      19881  01 First-year        6       19933
    ##    ---                                                              
    ## 97551: MCID3111785973      20011  03 Third-year        4       20043
    ## 97552: MCID3111820703      20011  03 Third-year        4       20043
    ## 97553: MCID3111858641      20013  03 Third-year        4       20051
    ## 97554: MCID3111860641      20013  03 Third-year        4       20051
    ## 97555: MCID3111602161      19991 04 Fourth-year        3       20013

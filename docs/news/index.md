# Changelog

## midfieldr 1.0.3.9xxx

**Current development version**

New features

- New function
  [`add_term_cluster()`](https://midfieldr.github.io/midfieldr/reference/add_term_cluster.md)
  to identify rows of post-baccalaureate terms to exclude.
- New function
  [`select_record_cols()`](https://midfieldr.github.io/midfieldr/reference/select_record_cols.md)
  to replace deprecated
  [`select_required()`](https://midfieldr.github.io/midfieldr/reference/midfieldr-deprecated.md).
  Refines the column selection even further.
- New function
  [`filter_cip_rows()`](https://midfieldr.github.io/midfieldr/reference/filter_cip_rows.md)
  to replace deprecated
  [`filter_cip()`](https://midfieldr.github.io/midfieldr/reference/midfieldr-deprecated.md).
- New utilities
  [`look_at()`](https://midfieldr.github.io/midfieldr/reference/look_at.md),
  [`catch_error()`](https://midfieldr.github.io/midfieldr/reference/catch_error.md),
  and
  [`sort_uniq()`](https://midfieldr.github.io/midfieldr/reference/sort_uniq.md)
  that wrap base R functions with our preferred arguments.
- Add data set `cip2010`, constructed from a recent download of the
  source file (`CIPCode2010.csv`) from NCES. Has the same data structure
  as the existing `cip` dataset, but with more rows.
- Add attempt in functions to preserve data frame attributes for classes
  `data.frame`, `data.table`, and `tbl_df`.

Minor improvements

- New versions of toy data and case study data for consistency with
  midfielddata.
- Revise README for brevity. Use toy data to illustrate usage.

Bug fixes

- In vignettes, fixed `.SD[]` where finding the first instance of a term
  should return more than one row, e.g., graduating with a double
  degree.
- This same fix added two rows to the `study_observations` built-in data
  set.

## version 1.0.3

2026–05 CRAN release

- Noted the transfer of the research database to ASEE
- Convert vignettes to non-vignette articles available on the website.
- Add re-export of wrapr
  [`check_equiv_frames()`](https://winvector.github.io/wrapr//reference/check_equiv_frames.html)
  to replace `same_content()`
- Add composite column keys of the `course` data table to
  [`select_required()`](https://midfieldr.github.io/midfieldr/reference/midfieldr-deprecated.md)
- Add datasets `grade_scale` and `sat_act_scale`

## version 1.0.2

2024–05

- Edit argument descriptions and correct typos.
- Update the midfieldr-package.R file
- No change in functionality.

## version 1.0.1

2023–07, initial CRAN submission

- Significant changes from earlier versions, no backwards compatibility,
  prompting version number change to 1.0.0.
- Edit practice data values for consistency with research data values
- Initial round of runtime assertions and unit tests complete
- Make function names and arguments internally consistent
- Edit functions to use data.table functionality
- Remove dependency on dplyr and related packages
- Replace Travis CI with GitHub Actions for CI
- Switch to package tinytest for unit testing
- Completely overhaul midfieldr functions

## version 0.1.0

2018–06, initial development version public on GitHub

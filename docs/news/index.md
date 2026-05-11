# Changelog

## midfieldr (development version)

## midfieldr 1.0.3 / 2026–05–10

- Convert vignettes to non-vignette articles available on the website.
  This allowed us to omit dependency on the non-mainstream midfielddata
  repository.
- Replace `same_content()` with re-export of wrapr
  [`check_equiv_frames()`](https://winvector.github.io/wrapr//reference/check_equiv_frames.html)
- Add composite column keys to
  [`select_required()`](https://midfieldr.github.io/midfieldr/reference/select_required.md)
  for course table
- Add `grade_scale` and `sat_act_scale` datasets

## midfieldr 1.0.2 / 2024–05–16

- Edit argument descriptions and correct typos.
- Update the midfieldr-package.R file
- No change in functionality.

## midfieldr 1.0.1 / 2023–07–08

Initial CRAN submission

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

## midfieldr 0.1.0 / 2018–06

- Initial development version public on GitHub

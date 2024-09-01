## midfieldr 1.0.2.900x / development version

- Replace `same_content()` with re-export of wrapr `check_equiv_frames()` 
- Add composite column keys to `select_required()` for course table
- Add `grade_scale` and `sat_act_scale` datasets
- Add definition of degree-seeking to relevant vignettes
- Edit case study introduction. Clarify some definitions. 
- Add 'Suggests' package 'gt' for vignette tables

## midfieldr 1.0.2 / 2024--05--16

- Edit argument descriptions and correct typos.
- Update the midfieldr-package.R file
- No change in functionality.

## midfieldr 1.0.1 / 2023--07--08

Initial CRAN submission

## midfieldr 1.0.0.9030 / 2022--12

- Cleanup the data-raw file, embed all figure code in the vignettes
- Edit for consistent figure dimensions
- Minor text edits in vignettes

## midfieldr 1.0.0.9029 / 2022-12

- Revise to accommodate new data sample in midfielddata
- Rework arguments of `filter_cip()` for ease of use
- Add man/rmd/ for shared .Rmd fragments 
- Revise README and pkgdown settings

## midfieldr 1.0.0.9028 / 2022--11

- Rename `filter_search()` to `filter_cip()` to better capture its purpose. Made `cip` the default data frame to search.
- Edit all vignettes for consistent organization and prose.  
- Finished first complete draft of "Graduation rate" vignette. 
- Add `same_content()` convenience function. 
- Add "Stickiness" vignette
- Add "Groupings" vignette. 

## midfieldr 1.0.0.9027 / 2022--10

- Separate the vignettes for FYE and starters. 
- To starters, add the case for non-FYE institutions.
- Edit vignettes for consistent organization and prose. 
- Add `select_required()`. 
- Add planning and blocs vignettes. 

## midfieldr 1.0.0.9026 / 2022--09

- Add FYE function and vignette.
- Revise multiway function name.
- Add order_multiway() examples.
- Add initial graduation rate vignette. 
- Add README to tests directory.
- Consistent comments and R code chunk commands.

## midfieldr 1.0.0.9025 / 2021--07

- Editing some functions names and data names to be more descriptive.  
- Change name of built-in `fye_start` data set to `fye_predicted_start`. 
- New `order_multiway_categories()` to replace `condition_multiway()`. Revised 
  argument names. 
- New `preprocess_fye()` to replace `condition_fye()`. 

## midfieldr 1.0.0.9024 / 2021--07

- Revise `add_completion_status()`, changing the three possible values to "timely", "late", or NA. Drop the `completion` column (same information available in the `term_degree` column). 
- Revise vignettes for consistent format.

## midfieldr 1.0.0.9023 / 2021--07

- Updated `condition_multiway()`, unit tests, and multiway vignette.

## midfieldr 1.0.0.9022 / 2021--06--29

- Revise or add vignettes for data sufficiency, degree seeking (inner joins), programs, completion, and demographics (left outer joins).
- Correction to `condition_multiway()` for alphabetical ordering, revise unit tests.
- Remove dependency on Rdpack.

## midfieldr 1.0.0.9021 / 2021--06

- The `midfield_student` argument, in functions in which it appears, is assigned the default value `student` instead of NULL. The argument can be  omitted unless the intended data frame is called something other than `student`. 
- Similarly, the `midfield_course`, `midfield_term`, and `midfield_degree` arguments, where they occur, are assigned the default values `course`, `term`, and `degree`. 
- Reorganize the logical flow of the data processing in the case study and vignettes to reflect our latest thinking on the order in which filters are applied.
- Functions return all supporting variables, delete the optional "details" arguments.
- Edit function names and variable names, update unit tests.
- Temporarily remove vignettes that have not been updated.
- Make inner joins explicit, delete `add_filter_match()`.
- Revise data sufficiency to include lower limit exclusions.
- Make left-outer joins explicit, delete `add_race_sex()`.

## midfieldr 1.0.0.9020 / 2021--06

Significant changes from earlier versions, no backwards compatibility, 
prompting version number change to 1.0.0.

- Change names of practice data tables to match the names of the research data
- Edit practice data values for consistency with research data values 
- Revise built-in data sets for use in vignettes and Rd examples
- Switch to wrapr coalesce `%?%` for assigning default arguments
- Initial round of runtime assertions and unit tests complete
- Make function names and arguments internally consistent 
- Edit functions to depend on data.table functionality 
- Make MIDFIELD data arguments explicit in functions 
- Remove dependency on dplyr and related packages 
- Replace Travis CI with GitHub Actions for CI
- Use package checkmate for runtime assertions 
- Remove dependency on installing midfielddata 
- Switch to package tinytest for unit testing 
- Separate case study from detailed vignettes
- Completely overhaul midfieldr functions  
- Update README and midfielddata README
- Revise vignettes to use new functions 


## midfieldr 0.1.0 / 2018--06

- Initial development version public on GitHub
  
<!-- major.minor.patch.dev -->
<!-- MAJOR version when you make incompatible API changes ->
<!-- MINOR version add functionality in a backwards-compatible manner ->
<!-- PATCH version backwards-compatible bug fixes ->

<!-- ### New features -->

<!-- ### Minor improvements -->

<!-- ### Bug fixes -->

<!-- ### Deprecated -->

<!-- ### Defunct -->




## midfieldr 1.0.0.9022 / 2021-07

- Add the degree seeking (inner joins) vignette
- Complete the data sufficiency vignette
- Remove dependency on Rdpack


## midfieldr 1.0.0.9021 / 2021-06

- The `midfield_student` argument, in functions in which it appears, is assigned the default value `student` instead of NULL. The argument can be  omitted unless the intended data frame is called something other than `student`. 
- Similarly, the `midfield_course`, `midfield_term`, and `midfield_degree` arguments, where they occur, are assigned the default values `course`, `term`, and `degree`. 
- Reorganize the logical flow of the data processing in the case study and vignettes to reflect our latest thinking on the order in which filters are applied
- Functions return all supporting variables, delete the optional "details" arguments
- Edit function names and variable names, update unit tests
- Temporarily remove vignettes that have not been updated
- Make inner joins explicit, delete `add_filter_match()`
- Revise data sufficiency to include lower limit exclusions
- Make left-outer joins explicit, delete `add_race_sex()`

## midfieldr 1.0.0.9020 / 2021-06

Significant changes from earlier versions, no backwards compatibility, 
prompting version number change to 1.0.0

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


## midfieldr 0.1.0 / 2018-06

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


## midfieldr 1.0.0.9021 / 2022-07

- Eliminate the named-argument requirement for functions using `student`, 
  `term`, and `degree` by assigning them as default arguments. Alternate 
  names can still be used at he user's discretion. 
- Revise data sufficiency to include lower limit exclusions
- Functions return all supporting variables
- Edit function names and variable names
- Reorganize case study and vignettes 

## midfieldr 1.0.0.9020 / 2021-07

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





## midfieldr 1.0.0.9001 / 2020-06-15

Changes incompatible with earlier versions. 

- For functions that operate on a data frame and return a data frame, the data frame is now the first argument---conforming to conventional coding practice and facilitating the use of pipe operators (`%>%`). For example, the new `cip_filter(data = cip, series)` replaces the old `cip_filter(series, reference = cip)`.  
- `cip6_select()` replaces `cip_label()`. Both functions add a custom program label for grouping, summarizing, and graphing, but the new function removes columns of 2-digit and 4-digit codes and names. 
- `ever_filter(data, filter_by)` revised names for arguments and reordered  

Additional improvements 

- `cip_filter(data, series, except)` includes a new `except` argument to exclude rows that include detected strings. 
- `cip6_select(data, program)` can accommodate variable names in `data` different from the default `cip`. 
- `cip6_select(program = NULL)` assigns the `cip4name` values to the `program` variable. The old `cip_label()` NULL result was the 6-digit names. 
- `cip6_select(program = "named_series")` is a new option for the program argument that assigns the appropriate named series to the `program` values. 
- Content links and session information added to each vignette   





## midfieldr 0.1.0.9003 / 2019-06-14

- Corrected a testing problem. Moved some test data from sysdata to the testhat directory. 
- Edit README per workshop feedback 

## midfieldr 0.1.0.9002 / 2018-07-20

- Add logo to README page 

## midfieldr 0.1.0.9001 / 2018-07-15

- Add Getting started vignette 
- Edit Readme 

## midfieldr 0.1.0.9000 / 2018-07-03

- Add starter_filter() 
- Add graduation rate vignette


## midfieldr 0.1.0 / 2018-06-20

- Development version public on GitHub
  
<!-- major.minor.patch.dev -->
<!-- MAJOR version when you make incompatible API changes ->
<!-- MINOR version add functionality in a backwards-compatible manner ->
<!-- PATCH version backwards-compatible bug fixes ->

<!-- ### New features -->

<!-- ### Minor improvements -->

<!-- ### Bug fixes -->

<!-- ### Deprecated -->

<!-- ### Defunct -->


## midfieldr 1.0.0.9003 / 2020-08

Predicted starting programs for FYE students and vignette

- `fye_mi_prep()`  
- `fye_start` data  
- `rep_start` data

Use `midfieldr.R` to bind names of column names in the four data sets in midfielddata 

## midfieldr 1.0.0.9002 / 2020-08

Feasible completion and vignette

- `feasible_subset()` 
- `rep_ever_fc` data  

## midfieldr 1.0.0.9001 / 2020-07

Changes incompatible with earlier versions. The scope of the revisions prompted the version number change to 1.0.0. 

- For functions that operate on a data frame and return a data frame, the data frame is now the first argument---conforming to conventional coding practice and facilitating the use of pipe operators (`%>%`) 
- `filter_by_text()` replaces `cip_filter()` with argument edits   
- `filter_by_cip()` replaces `ever_filter()` and `grad_filter()` with argument edits 
- `filter_by_id()` replaces `race_sex_join()` with argument edits 
- `order_multiway()` replaces `multiway_order()` 

Additional changes 

- dplyr/tidyr/stringr dependencies removed 
- All data carpentry in data.table and base R syntax 
- Functions attempt to preserve data frame extensions such as tibble and maintain compatibility with the magrittr pipe 
- `filter_by_text()` includes a new `drop_any` argument to  drop rows in which any matches or partial matches are detected 
- Deleted `theme_midfield()` to reduce dependencies 
- Session information added 
- Vignettes updated with function revisions and improvements in response to feedback from workshop attendees 
- Updated tests 


## midfieldr 0.1.0.9003 / 2019-06

- Corrected a testing problem. Moved some test data from sysdata to the testthat directory. 
- Edit README per workshop feedback 


## midfieldr 0.1.0 / 2018-06

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





## midfieldr 1.0.0.9001 / 2020-07-29

Changes incompatible with earlier versions. The scope of the revisions prompted the version number change to 1.0.0. 

- For functions that operate on a data frame and return a data frame, the data frame is now the first argument---conforming to conventional coding practice and facilitating the use of pipe operators (`%>%`). For example, the new `get_cip(data, keep_any)` replaces the old `cip_filter(series, reference)`.  
- `label_programs()` replaces `cip_label()` with edited arguments. 
- `get_enrollees()` replaces `ever_filter()` with edited arguments. 
- `get_graduates()` replaces `grad_filter()` with edited arguments.  
- `get_race_sex()` replaces `race_sex_join()` with edited arguments.  
- `order_multiway()` replaces `multiway_order()`. 

Additional changes 

- dplyr/tidyr/stringr dependencies removed. All data carpentry in data.table and base R. 
- Functions attempt to preserve data frame extensions such as tibble and maintain compatibility with the magrittr pipe. 
- Added `completion_feasible()` function. 
- `get_cip()` includes a new `drop_any` argument to  drop rows in which any matches or partial matches are detected.
- Deleted `theme_midfield()` to reduce dependencies. 
- Session information added.   
- Vignettes updated with function revisions and improvements in response to feedback from workshop attendees. 
- Updated tests.





## midfieldr 0.1.0.9003 / 2019-06-14

- Corrected a testing problem. Moved some test data from sysdata to the testthat directory. 
- Edit README per workshop feedback 


## midfieldr 0.1.0.9001 / 2018-07-15

- Using midfieldr vignette 


## midfieldr 0.1.0.9000 / 2018-07-03

- starter_filter() 
- Graduation rate vignette


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

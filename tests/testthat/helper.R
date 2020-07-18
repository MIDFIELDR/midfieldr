# ctrl-shift-L to load internal functions

# for using rprojroot
get_my_path <- function(filename) {
  rprojroot::find_testthat_root_file(
    "testing-data", filename
  )
}

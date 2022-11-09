# Default character vector for selecting columns
default_cols<- c("mcid", "institution", "race", "sex", "^term", "cip6", "level")

# Create one string separated by OR
search_pattern <- paste(default_cols, collapse = "|")

# Find names of columns matching or partially matching 
x <- select_required(toy_student) 
names(x)
grepl(search_pattern, names(x))

x <- select_required(toy_term) 
names(x)
grepl(search_pattern, names(x))

x <- select_required(toy_degree) 
names(x)
grepl(search_pattern, names(x))

x <- select_required(toy_course) 
names(x)
grepl(search_pattern, names(x))

# Adding search terms
x <- select_required(toy_course, select_add = c("abbrev", "number", "grade")) 
names(x)




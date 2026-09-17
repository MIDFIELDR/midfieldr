# Construct a sample data frame
mcid <- c("mc_01", "mc_02", "mc_03")
term <- c("19911", "19912", "19913")
x <- data.frame(mcid, term)

# In the following, column names "var" and "var.i" 
# represent identical names except for the suffix ".i"
 
# No effect if columns are unique
x
x <- select_unique_cols(x)
x

# Desired effect: drop new "var.i" if it duplicates existing "var"
x$term.1 <- x$term
x
x <- select_unique_cols(x)
x

# Retain "var.i" when "var" does not exist
x <- data.frame(mcid, term.1 = term)
x
x <- select_unique_cols(x)
x

# The leftmost of the redundant columns is retained
x$term <- term
x
x <- select_unique_cols(x)
x

# Redundancy is checked for the dot-separator only
x <- data.frame(mcid, term, term_1 = term, term.1 = term)
x
x <- select_unique_cols(x)
x

# When a midfieldr function adds a variable, e.g., `bacc_term`, and
# a subsequent operation adds it again, `bacc_term.1`, the second 
# addition is usually expected to be redundant and dropped.
x$term_1 <- NULL
x$bacc_term <- c("19951", "19951", "19951")
x$bacc_term.1 <- c("19951", "19951", "19951")
x
x <- select_unique_cols(x)
x

# However, if the suffixed column remains, then the two columns 
# have different values---likely indicating an error in the 
# operations leading up to this point. 
x$bacc_term.1 <- c("19953", "19951", "19951")
x
x <- select_unique_cols(x)
x

# Construct a sample data frame
mcid <- paste0("mc_", c("01", "02", "03"))
term <- c("19911", "19912", "19913")
dframe <- data.frame(mcid, term)
dframe
 
# No effect if all columns are distinct
select_unique_cols(dframe)

# No effect if names are distinct even if values are the same
x <- dframe
x$case <- x$term
x
select_unique_cols(x)

# Suffix-variable remains if there is no root-variable
x$case <- NULL
x$temp.1 <- c("abc", "def", "ghi")
x
select_unique_cols(x)

# Suffix-variable remains if values different from root-variable
x$temp.1 <- NULL
x$case.1 <- c("abc", "def", "ghi")
x
select_unique_cols(x)

# Suffix-variable dropped if otherwise identical to root-variable
x$case.1 <- NULL
x$term.1 <- x$term
x
select_unique_cols(x)

# Multiple redundant columns are dropped 
x$term.1 <- x$term
x$term.abc <- x$term
x
select_unique_cols(x)

# If a midfieldr function introduces a column with a 
# suffix ".1", ".2", etc., this points to a potential 
# error. The two columns with the same root name 
# are expected to be identical.
x <- dframe
x$term.1 <- c("19922", "19912", "19913")
x
select_unique_cols(x)

# Names with other separators are treated as unique
x$term.1 <- NULL
x$term_1 <- x$term
x
select_unique_cols(x)

# In removing a redundant column, the leftmost is retained
x <- data.frame(mcid.1 = mcid, term, mcid)
x
select_unique_cols(x)

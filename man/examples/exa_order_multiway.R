# Reconfigure built-in data set
DT <- case_results[grepl("^Elec|^Mech", program)]
DT <- DT[grepl("^Asian|^Black|^Hispanic|^White", people)]
DT

# Order factor levels by median
DT1 <- data.table::copy(DT)
DT1 <- DT1[, c("ever", "grad") := NULL]
mw1 <- order_multiway(DT1, 
                      quantity = "stick", 
                      categories = c("program", "people"))
data.table::setorderv(mw1, c("program_median", "people_median"))
mw1

# Levels in increasing order
levels(mw1$program)
levels(mw1$people)

# No change if added columns are redundant
mw1a <- order_multiway(mw1, 
                       quantity = "stick", 
                       categories = c("program", "people"))
check_equiv_frames(mw1, mw1a)

# Retain the `ratio_of` variables and order by percentage
mw2 <- order_multiway(DT, 
                      quantity = "stick", 
                      categories = c("program", "people"), 
                      method = "percent", 
                      ratio_of = c("grad", "ever"))
data.table::setorderv(mw2, c("program_metric", "people_metric"))
mw2

# Order of factor levels depends on the method. Here, for example, 
# program levels are the same for median and percent methods, 
all.equal(levels(mw1$program), levels(mw2$program))

# but people levels do not have the same order. 
all.equal(levels(mw1$people), levels(mw2$people))
levels(mw1$people)
levels(mw2$people)

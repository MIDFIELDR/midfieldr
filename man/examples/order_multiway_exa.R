# Subset of built-in data set
dframe <- study_results[program == "EE" | program == "ME"]
dframe[, people := paste(race, sex)]
dframe[, c("race", "sex") := NULL]
data.table::setcolorder(dframe, c("program", "people"))

# Class before ordering
class(dframe$program)
class(dframe$people)

# Class and levels after ordering
mw1 <- order_multiway(dframe, 
                      quantity = "stick", 
                      categories = c("program", "people"))
class(mw1$program)
levels(mw1$program)
class(mw1$people)
levels(mw1$people)

# Display category medians 
mw1

# Existing factors (if any) are re-ordered
mw2 <- dframe
mw2$program <- factor(mw2$program, levels = c("ME", "EE"))

# Levels before conditioning
levels(mw2$program) 

# Levels after conditioning
mw2 <- order_multiway(dframe, 
                      quantity = "stick", 
                      categories = c("program", "people"))
levels(mw2$program) 

# Ordering using percent method
order_multiway(dframe, 
               quantity = "stick", 
               categories = c("program", "people"), 
               method = "percent", 
               ratio_of = c("grad", "ever"))

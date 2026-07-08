# Reconfigure built-in data set
DT <- study_results[program == "EE" | program == "ME"]
DT <- DT[race %chin% c("Asian", "Black", "Hispanic", "White")]
DT[, people := paste(race, sex)]
DT[, c("race", "sex") := NULL]
data.table::setnames(DT, 
         old = c("program", "graduates", "ever_enrolled", "stickiness"), 
         new = c("prgm", "grad", "ever", "stk"))
DT[]

# Factor levels ordered by median
mw1 <- order_multiway(DT, 
                      quantity = "stk", 
                      categories = c("prgm", "people"))
data.table::setorderv(mw1, c("prgm_median", "people_median"))

# The unused variables `ever` and `grad` are dropped
mw1

# Levels in same increasing order as shown above
levels(mw1$prgm)
levels(mw1$people)

# Ordering using percent method
mw2 <-order_multiway(DT, 
               quantity = "stk", 
               categories = c("prgm", "people"), 
               method = "percent", 
               ratio_of = c("grad", "ever"))
data.table::setorderv(mw2, c("prgm_stk", "people_stk"))

# The two ratio_of variables `ever` and `grad` are retained
mw2

# Levels in same increasing order as shown above
levels(mw2$prgm)
levels(mw2$people)

# Order of factor levels depends on the method. Here, for example, 
# program levels are the same for median and percent methods, 
all.equal(levels(mw1$prgm), levels(mw2$prgm))

# but people levels do not have the same order. 
all.equal(levels(mw1$people), levels(mw2$people))
levels(mw1$people)
levels(mw2$people)

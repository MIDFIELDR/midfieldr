# Construct example data frame
catg1 <- rep(c("urban", "rural", "suburb", "village"), each = 2)
catg2 <- rep(c("men", "women"), times = 4)
value <- c(0.22, 0.14, 0.43, 0.58, 0.81, 0.46, 0.15, 0.20)
dframe <- data.frame(catg1, catg2, value)
dframe


# Class before conditioning
class(dframe$catg1)
class(dframe$catg2)


# Class and levels after conditioning
mw1 <- condition_multiway(dframe)
class(mw1$catg1)
levels(mw1$catg1)
class(mw1$catg2)
levels(mw1$catg2)


# Existing factors (if any) are re-ordered
mw2 <- dframe
mw2$catg1 <- factor(mw2$catg1,
                       levels = c("rural", "suburb", "urban", "village"))
levels(mw2$catg1) # levels before conditioning
mw2 <- condition_multiway(mw2)
levels(mw2$catg1) # levels after conditioning


# Report median values
mw <- condition_multiway(dframe, details = TRUE)
mw

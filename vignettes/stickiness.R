## ----echo = FALSE, opts.label = 'dopurl'---------------------------------
# use the dopurl hook to make these values available for the inline
# expressions in the next paragraph during R CMD check. Causes this code
# chunk to be written to vignettes/*.R
n_prog <- length(unique(stickiness$program))
n_sex <- length(unique(stickiness$sex))
n_race <- length(unique(stickiness$race))
n_comb <- n_prog * n_sex * n_race
n_obs <- dim(stickiness)[[1]]


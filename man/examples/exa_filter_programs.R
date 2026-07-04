# Subset using keywords
filter_programs(cip, pattern = "history")

# Subset using codes
filter_programs(cip, pattern = "^54")

# Multiple passes to narrow the results
first_pass <- filter_programs(cip, "math")
first_pass[, .(cip6name, cip6)]

second_pass <- filter_programs(first_pass, c("bio", "educ"), negate = TRUE)
second_pass[, .(cip6name, cip6)]

third_pass <- filter_programs(second_pass, c("^27", "^30"))
third_pass[, .(cip6name, cip6)]

# Multiple passes by chaining
chain_pass <- cip |>
    filter_programs("math") |>
    filter_programs(c("bio", "educ"), negate = TRUE) |>
    filter_programs(c("^27", "^30"))
chain_pass[, .(cip6name, cip6)]

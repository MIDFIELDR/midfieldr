# Subset using keywords
filter_programs(cip, pattern = "history")

# Subset using codes
filter_programs(cip, pattern = "^54")

# Multiple passes to narrow the results
first_pass <- filter_programs(cip, "math")[, .(cip6name, cip6)]
first_pass

second_pass <- filter_programs(first_pass, c("bio", "educ"), negate = TRUE)
second_pass

third_pass <- filter_programs(second_pass, c("^27", "^30"))
third_pass
 

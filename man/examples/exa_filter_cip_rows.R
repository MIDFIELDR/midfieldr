# Subset using keywords
filter_cip_rows(cip, pattern = "history")

# Subset using codes
filter_cip_rows(cip, pattern = "^54")

# Multiple passes to narrow the results
first_pass <- filter_cip_rows(cip, "math")[, .(cip6name, cip6)]
first_pass

second_pass <- filter_cip_rows(first_pass, c("bio", "educ"), negate = TRUE)
second_pass

third_pass <- filter_cip_rows(second_pass, c("^27", "^30"))
third_pass
 

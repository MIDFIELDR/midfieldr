# Subset using keywords
filter_cip(cip, keep_text = "engineering")


# drop_text argument, when used, must be named
filter_cip(cip, "civil engineering", drop_text = "technology")


# Subset using numerical codes
filter_cip(cip, keep_text = c("050125", "160501"))


# subset using regular expressions
filter_cip(cip, keep_text = "^54")
filter_cip(cip, keep_text = c("^1407", "^1408"))


# Select columns
filter_cip(cip,
  keep_text = "^54",
  select = c("cip6", "cip4name")
)


# Multiple passes to narrow the results
first_pass <- filter_cip(cip, "civil")
second_pass <- filter_cip(first_pass, "engineering")
filter_cip(second_pass, drop_text = "technology")


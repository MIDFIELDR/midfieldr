# Subset using keywords
filter_search(cip, keep_text = "engineering")


# drop_text argument, when used, must be named
filter_search(cip, "civil engineering", drop_text = "technology")


# Subset using numerical codes
filter_search(cip, keep_text = c("050125", "160501"))


# subset using regular expressions
filter_search(cip, keep_text = "^54")
filter_search(cip, keep_text = c("^1407", "^1408"))


# Select columns
filter_search(cip,
  keep_text = "^54",
  select = c("cip6", "cip4name")
)


# Multiple passes to narrow the results
first_pass <- filter_search(cip, "civil")
second_pass <- filter_search(first_pass, "engineering")
filter_search(second_pass, drop_text = "technology")


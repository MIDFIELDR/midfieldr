# packages used
library("midfieldr")
library("midfielddata")
library("dplyr")
library("stringr")
library("ggplot2")
library("seplyr")

# CIP information saved from an earlier vignette
program_group <- exa_programs

# variable names for grouping, summarizing, and joining
grouping_variables <- c("program", "race", "sex")

# extract the 6-digit CIPs as a search series
program_series <- program_group[["cip6"]] %>%
        unique() %>%
        sort()

# count students ever enrolled in programs
ever_enrolled <- get_enrollees(midfieldterms, codes = program_series) %>%
	race_sex_join() %>%
	left_join(., program_group, by = "cip6") %>%
	group_summarize(., grouping_variables, "ever" = n())

# count students graduating from programs
graduated <- get_graduates(midfielddegrees, codes = program_series) %>%
	race_sex_join() %>%
	left_join(., program_group, by = "cip6") %>%
	group_summarize(., grouping_variables, "grad" = n())

# tally stickiness, by group
stickiness <- left_join(ever_enrolled, graduated, by = grouping_variables) %>%
	filter(ever > 5) %>%
	mutate(stick = round(grad / ever, 3))

# prepare data for graph
stickiness_mw <- stickiness %>%
	filter(!race %in% c("Unknown", "International", "Other")) %>%
	filter(!sex %in% "Unknown") %>%
	mutate(race_sex = str_c(race, sex, sep = " ")) %>%
	select(program, race_sex, stick) %>%
	order_multiway()

# graph
ggplot(stickiness_mw, aes(x = stick, y = race_sex)) +
	facet_wrap(vars(program), ncol = 1, as.table = FALSE) +
	geom_point(na.rm = TRUE) +
	labs(x = "Stickiness", y = "") +
	theme_midfield()

# packages used
library("midfieldr")
library("midfielddata")
suppressPackageStartupMessages(library("data.table"))

# Load the data tables
data(student, term, degree, package = c("midfielddata"))

# Filter for engineering programs
setDF(term)
DT <- term[startsWith(term$cip6, "14"),
           c("mcid", "institution", "cip6"),
           drop = FALSE]
DT <- unique(DT)

# Ensure students are degree-seeking
# DT <- filter_match(DT, match_to = student, by_col = "mcid")
# setDF(DT)


# Inner join using three columns of term
y <- unique(student[, .(mcid)])
DT <- y[DT, on = .(mcid), nomatch = NULL]
setDF(DT)




# Estimate timely completion terms
DT <- add_timely_term(DT, midfield_term = term)
setDF(DT)

# Determine graduation status
DT <- add_completion_timely(DT, midfield_degree = degree)
setDF(DT)
DT$grad_status <- ifelse(DT$completion_timely, "grad", "non-grad")

# Apply the data sufficiency criterion
DT <- add_data_sufficiency(DT, midfield_term = term)
setDF(DT)
DT <- DT[DT$data_sufficiency == TRUE, , drop = FALSE]

# Obtain race/ethnicity and sex
# DT <- add_race_sex(DT, midfield_student = student)
# Left-outer join race-sex
cols_to_join <- student[, .(mcid, race, sex)]
DT <- cols_to_join[DT, on = .(mcid)]
setDF(DT)

# Count by grouping variables
result <- as.data.frame(with(DT, table(race, sex, grad_status)))
colnames(result)[colnames(result) == "Freq"] <- "N"
result



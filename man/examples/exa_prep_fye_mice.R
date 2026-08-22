library(data.table)

# Student A enrolls in FYE (140102) followed by Mechanical Engng 
# (141901). The FYE proxy is Mechanical Engng (141901), abbreviated "ME".
one_student <- data.table(mcid = "A", race = "unknown", sex = "unknown")
term_excerpt <- data.table(
    mcid = "A", 
    institution = "Institution J",
    term = c("20013", "20021"), 
    program = c("FYE", "ME"),
    cip6 = c("140102", "141901")
)
one_student
term_excerpt
prep_fye_mice(one_student, term_excerpt)

# Student B enrolls in FYE (140102) followed by History (540101). 
# The FYE proxy is NA.
one_student <- data.table(mcid = "B", race = "unknown", sex = "unknown")
term_excerpt <- data.table(
    mcid = "B", 
    institution = "Institution J",
    term = c("20013", "20021"), 
    program = c("FYE", "History"),
    cip6 = c("140102", "540101")
)
one_student
term_excerpt
prep_fye_mice(one_student, term_excerpt)

# Student C enrolls in FYE (140102) but drops out of the database.
# The FYE proxy is NA.
one_student <- data.table(mcid = "C", race = "unknown", sex = "unknown")
term_excerpt <- data.table(
    mcid = "C", 
    institution = "Institution J",
    term = c("20013", "20021"), 
    program = c("FYE", "FYE"),
    cip6 = c("140102", "140102")
)
one_student
term_excerpt
prep_fye_mice(one_student, term_excerpt)

# Student D starts in History (540101), switches to FYE for two terms, 
# followed by ME (141901). The FYE proxy is ME (141901).
one_student <- data.table(mcid = "D", race = "unknown", sex = "unknown")
term_excerpt <- data.table(mcid = "D", 
                           institution = "Institution J",
                           term = c("20013", "20021", "20023", "20031"), 
                           program = c("History", "FYE", "FYE", "ME"),
                           cip6 = c("540101", "140102", "140102", "141901"))
one_student
term_excerpt
prep_fye_mice(one_student, term_excerpt)

# Student E is similar to Student D except they switched out of FYE 
# (140102) to History (540101), then returned to FYE followed by ME
# (141901). The FYE proxy is ME (141901).
one_student <- data.table(mcid = "E", race = "unknown", sex = "unknown")
term_excerpt <- data.table(
    mcid = "E", 
    institution = "Institution J",
    term = c("20011", "20013", "20021", "20023", "20031"), 
    program = c("FYE", "History", "History", "FYE", "ME"),
    cip6 = c("140102", "540101", "540101", "140102", "141901")
)
one_student
term_excerpt
prep_fye_mice(one_student, term_excerpt)

# Student F enrolls in FYE at Institution C that uses an alternate CIP
# code (140101), followed by ME (141901), so we have to specify a 
# non-default FYE CIP code. The FYE proxy is ME (141901).
one_student <- data.table(mcid = "F", race = "unknown", sex = "unknown")
term_excerpt <- data.table(
    mcid = "F", 
    institution = "Univ ABC",
    term = c("20013", "20021"), 
    program = c("FYE", "ME"),
    cip6 = c("140101", "141901")
)
fye_cip <- data.table(institution = "Univ ABC", fye_cip6 = "140101")
one_student
term_excerpt
fye_cip
prep_fye_mice(one_student, term_excerpt, fye_cip)

# Using datasets with multiple students
prep_fye_mice(toy_student, toy_term)[order(proxy)]

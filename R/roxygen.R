# R code used for documentation


param_dots <- "Not used for passing values; forces subsequent arguments to be
        referable only by name."

dframe <- "Data frame or data frame extension (e.g., data.table or tibble)."

midfield_x <- function(x) {
  paste0("MIDFIELD  ", x, "  dataset (data frame or data frame extension).")
}


# Variable names used in data.R

var_abbrev <- '\\item{`abbrev`}{Character. Course alphabetical identifier,
                e.g. "ENGR", "MATH", "ENGL."}'

var_act_comp <- "\\item{`act_comp`}{Numeric. ACT composite test score
                (or NA).}"

var_coop <- '\\item{`coop`}{Character. Cooperative education term, possible
            values are "Yes", "No."}'

var_course <- '\\item{`course`}{Character. Course name, e.g., "Astrophysics
                III", "Calculus For Social Science And Business", "Corp
                Financial Rprtng 1", "Environmental Sanitation II", "Fitness
                and Wellness", "Introductory Astronomy 2", "Our Changing
                Environment", etc.}'

var_age_desc <- '\\item{`age_desc`}{Character. Age group, possible values
                are "25 and Older", "Under 25."}'

var_bloc <- "\\item{`bloc`}{Character. A group of student-level data dealt
            with as a unit, e.g., starters, students ever-enrolled,
            graduates, etc.}"

var_cip6 <- "\\item{`cip6`}{Character. The 6-digit CIP code of the program in which
            a student is enrolled in a term.}"

var_cip6_degree <- "\\item{`cip6`}{Character. The 6-digit CIP code of the program
                    that the student completes in this term.}"

var_cip6_term <- "\\item{`cip6`}{Character. The 6-digit CIP code of the program in
                which a student is enrolled in this term.}"

var_degree <- '\\item{`degree`}{Character. Type of degree awarded, e.g.,
                 "Bachelor of Arts in Geography", "Bachelor of Science
                 in Finance," etc.}'

var_discipline_midfield <- '\\item{`discipline_midfield`}{Character. A variable
                              for grouping courses by academic discipline
                              assigned by the pre-2023 MIDFIELD data curator, e.g.,
                               "Anthropology", "Business", "Computer Science",
                             "Engineering", "Language and Literature",
                              "Mathematics", "Visual and Performing Arts", etc.}'

var_ever_enrolled <- "\\item{`ever_enrolled`}{Numerical. The number of students
                        ever enrolled in a program.}"

var_faculty_rank <- '\\item{`faculty_rank`}{Character. The academic rank of the
                       person teaching the course, e.g., "Assistant Professor",
                       "Associate Professor", "Graduate Assistant",
                       "Visiting Faculty", etc.}'

var_gpa_cumul <- "\\item{`gpa_cumul`}{Numeric. Cumulative grade point average.}"

var_gpa_term <- "\\item{`gpa_term`}{Numeric. Term grade point average.}"

var_grade <- '\\item{`grade`}{Character. Course grade, e.g., "A+", "A", "A-", "B+",
                "I", "NG", etc.}'

var_graduates <- "\\item{`graduates`}{Numerical. Number of students completing
                    a program.}"

var_high_school <- '\\item{`high_school`}{Character. Code for the last high
                      school attended before admission (or NA), e.g., "060075",
                      "210512", "431800", "502195", etc.}'

var_home_zip <- '\\item{`home_zip`}{Character. Home ZIP code (or NA),
                   e.g., "02056", "20170", "51301", "80129", etc.}'

var_hours_course <- "\\item{`hours_course`}{Numeric. Number of credit-hours
                       for successful course completion.}"

var_hours_cumul <- "\\item{`hours_cumul`}{Numeric, cumulative credit hours
                      earned.}"

var_hours_cumul_attempt <- "\\item{`hours_cumul_attempt`}{Numeric. Cumulative
                              credit hours attempted.}"

var_hours_term <- "\\item{`hours_term`}{Numeric. Credit hours earned
                     in the term.}"

var_hours_term_attempt <- "\\item{`hours_term_attempt`}{Numeric. Credit
                             hours attempted in the term.}"

var_hours_transfer <- "\\item{`hours_transfer`}{Numeric. Number of credit
                         hours transferred (or NA).}"

var_institution <- '\\item{`institution`}{Character. The anonymized name of
                    the institution the student attended in a given term, e.g.,
                    "Institution A", "Institution B", etc.}'

var_level <- '\\item{`level`}{Character. Academic level of the student at the
                end of this term, e.g., "01 First-Year", "02-Second Year", etc.}'

var_mcid <- '\\item{`mcid`}{Character. Anonymized student identifier
               that connects the four data tables, e.g., "MCID3111142897."}'

var_number <- '\\item{`number`}{Character. Course numeric identifier, e.g.
                 "101", "3429."}'

var_program <- "\\item{`program`}{Character. Academic program label.}"

var_proxy <- "\\item{`proxy`}{Character. The 6-digit CIP code of the estimated
                proxy program.}"

var_race <- '\\item{`race`}{Character. Race/ethnicity as self-reported
               by the student, e.g., "Asian", "Black", "Hispanic", etc.}'

var_sat_math <- "\\item{`sat_math`}{Numeric. SAT mathematics test score
                   (or NA).}"

var_sat_verbal <- "\\item{`sat_verbal`}{Numeric. SAT reading test score
                     (or NA).}"

var_section <- '\\item{`section`}{Character. Course section identifier, from
                  one to four characters, e.g., "1", "2", "01", "14", "001",
                  "040", "785", "H02", "R01", "300E", "888R", etc.}'

var_sex <- '\\item{`sex`}{Character. Sex as self-reported by the student,
              possible values are "Female", "Male", and "Unknown."}'

var_standing <- '\\item{`standing`}{Character. Academic standing during the
                  reported term, e.g., "Good Standing", "Academic Warning", etc.}'

var_term <- "\\item{`term`}{Character. Academic year and term the student
                            attended, encoded `YYYYT.`}"

var_term_course <- "\\item{`term_course`}{Character. Academic year and term,
                      encoded `YYYYT.`}"

var_term_degree <- "\\item{`term_degree`}{Character. Academic year and term
                      in which a student completes their program, encoded
                      `YYYYT.`}"

var_transfer <- '\\item{`transfer`}{Character. Transfer status, possible
                   values are "First-Time in College", "First-Time Transfer."}'

var_type <- '\\item{`type`}{Character. Predominant delivery method for this
               section, e.g., "Blended", "Distance Education", "Face-to-Face",
               "Online", etc.}'

var_us_citizen <- '\\item{`us_citizen`}{Character. US citizenship, possible
                                        values are "No", "Yes."}'

var_stickiness <- "\\item{`stickiness`}{Numerical. Program stickiness, the
                     ratio of the number of graduates to the number ever
                     enrolled, in percent.}"

# R code used for documentation

param_dots <- "Not used for passing values; forces subsequent arguments to be
        referable only by name."

# ---------------------------------

dframe_order_multiway <- 'Data frame containing a single quantitative value
        (or response) for every combination of levels of two categorical
        variables. Categories may be class character or factor. Two additional
        numeric columns are required when using the "percent" ordering method.'

midfield_student_prep_fye_mice <- "MIDFIELD `student` data table or
        equivalent with required variables `mcid`, `race`, and `sex.`"

midfield_term_prep_fye_mice <- "MIDFIELD `term` data table or equivalent
        with required variables `mcid`, `institution`, `term`, and `cip6.`"

preserve_class <- "\n\nAn attempt is made to return data frames of the same
        class as the input, so a data.table input should produce a data.table
        output, a tibble input should produce a tibble output, etc. Grouped
        tibbles, however, are returned as data.frames. To help ensure a tibble
        output, try ungrouping a tibble before using it as an input argument."

return_data_frame <- "A data frame in `data.table` format with the following
        properties: rows are preserved; columns are preserved with the exception
        that columns added by the function overwrite existing columns of the
        same name (if any); grouping structures are not preserved. The added
        columns are:"

return_order_multiway <- "A data frame in `data.table` format with
        the following properties: rows are preserved; columns specified by
        `categories` are converted to factors and ordered; the column specified
        by `quantity` is converted to type double; other columns are preserved
        with the exception that columns added by the function overwrite existing
        columns of the same name (if any); grouping structures are not preserved.
        The added columns are:"

return_prep_fye_mice <- "A data frame in `data.table` format conditioned for
        later use as an input to the mice R package for multiple imputation. The
        data frame comprises one row for every FYE student, first-term and
        migrator. Grouping structures are not preserved. The columns returned
        are:"

return_term_wrt_degree <- "A data frame with the following properties:
        rows are preserved; two new columns are added or overwrite existing
        columns of the same name; all other columns are preserved; grouping
        structures are not preserved."

return_same_class <- "The function attempts to return a data frame of the same
        class as that of the input, such as the `data.table/data.frame` class
        of data.table, the `tbl_df/tbl/data.frame` class of tibble, or the
        `data.frame` class of base R."


# Variable names in data sets

var_abbrev <- "\\item{`abbrev`}{Character, course alphabetical identifier,
                  e.g. ENGR, MATH, ENGL. Key column.}"

var_act_comp <- "\\item{`act_comp`}{Numeric, ACT composite test score
                 (or `NA`).}"

var_coop <- "\\item{`coop`}{Character, cooperative education term, possible
             values are `Yes`, `No`.}"

var_course <- "\\item{`course`}{Character, course name, e.g., `Astrophysics
                III`, `Calculus For Social Science And Business`, `Corp
                Financial Rprtng 1`, `Environmental Sanitation II`, `Fitness
                and Wellness`, `Introductory Astronomy 2`, `Our Changing
                Environment`, etc.}"

var_age_desc <- "\\item{`age_desc`}{Character, age group, possible values
                 are `25 and Older`, `Under 25`.}"

var_bloc <- "\\item{`bloc`}{Character, indicating the grouping
                  (`ever_enrolled` or `graduates`) to which an observation
                  belongs.}"

var_cip6 <- "\\item{`cip6`}{Character, 6-digit CIP code of program in which
                   a student is enrolled in a term.}"

var_cip6_degree <- "\\item{`cip6`}{Character, 6-digit CIP code of program in
                   which a student is enrolled in a term. Key column.}"

var_cip6_term <- "\\item{`cip6`}{Character, 6-digit CIP code of program in
                   which a student is enrolled in a term, e.g., `090101`,
                   `141201`, `260901`, `420101`, etc.}"

var_degree <- "\\item{`degree`}{Character, type of degree awarded, e.g.,
                     Bachelor of Arts in Geography, Bachelor of Science
                     in Finance, etc.}"

var_discipline_midfield <- "\\item{`discipline_midfield`}{Character, a variable
                             for grouping courses by academic discipline
                             assigned by the pre-2023 MIDFIELD data curator, e.g.,
                             `Anthropology`, `Business`, `Computer Science`,
                             `Engineering`, `Language and Literature`,
                             `Mathematics`,`Visual and Performing Arts`, etc.}"

var_ever_enrolled <- "\\item{`ever_enrolled`}{Numerical, number of students
                   ever enrolled in a program.}"

var_faculty_rank <- "\\item{`faculty_rank`}{Character, academic rank of the
                     person teaching the course, e.g., `Assistant Professor`,
                     `Associate Professor`, `Graduate Assistant`,
                     `Visiting Faculty`, etc.}"

var_gpa_cumul <- "\\item{`gpa_cumul`}{Numeric, cumulative grade point average.}"

var_gpa_term <- "\\item{`gpa_term`}{Numeric, term grade point average.}"

var_grade <- "\\item{`grade`}{Character, course grade, e.g., A+, A, A-, B+,
                   I, NG, etc.}"

var_graduates <- "\\item{`graduates`}{Numerical, number of students completing
                  a program.}"

var_high_school <- "\\item{`high_school`}{Character, code for the last high
                    school attended before admission (or `NA`), e.g., `060075`,
                    `210512`, `431800`, `502195`, etc.}"

var_home_zip <- "\\item{`home_zip`}{Character, home ZIP code (or `NA`),
                 e.g., `02056`, `20170`, `51301`, `80129`, etc.}"

var_hours_course <- "\\item{`hours_course`}{Numeric, number of credit-hours
                    for successful course completion.}"

var_hours_cumul <- "\\item{`hours_cumul`}{Numeric, cumulative credit hours
                     earned.}"

var_hours_cumul_attempt <- "\\item{`hours_cumul_attempt`}{Numeric, cumulative
                            credit hours attempted.}"

var_hours_term <- "\\item{`hours_term`}{Numeric, credit hours earned
                    in the term.}"

var_hours_term_attempt <- "\\item{`hours_term_attempt`}{Numeric, credit
                            hours attempted in the term.}"

var_hours_transfer <- "\\item{`hours_transfer`}{Numeric, number of credit
                hours transferred (or NA).}"

var_institution <- "\\item{`institution`}{Character, de-identified institution
                   name, e.g., Institution A, Institution B, etc.}"

var_level <- "\\item{`level`}{Character, 01 Freshman, 02 Sophomore, etc.
                   The equivalent values in the current practice data are 01
                   First-Year, 02-Second Year, etc.}"

var_mcid <- "\\item{`mcid`}{Character, de-identified student ID. Key column.}"

var_number <- "\\item{`number`}{Character, course numeric identifier, e.g.
                   101, 3429. Key column.}"

var_program <- "\\item{`program`}{Character, academic program label.}"

var_proxy <- "\\item{`proxy`}{Character, 6-digit CIP code of the estimated
                  proxy program.}"

var_race <- "\\item{`race`}{Character, race/ethnicity as self-reported
                  by the student, e.g., Asian, Black, Hispanic, etc.}"

var_sat_math <- "\\item{`sat_math`}{Numeric, SAT mathematics test score
                  (or `NA`).}"

var_sat_verbal <- "\\item{`sat_verbal`}{Numeric, SAT reading test score
                  (or `NA`).}"

var_section <- "\\item{`section`}{Character, course section identifier, from
                 one to four characters, e.g., `1`, `2`, `01`, `14`, `001`,
                 `040`, `785`, `H02`, `R01`, `300E`, `888R`, etc.}"

var_sex <- "\\item{`sex`}{Character, sex as self-reported by the student,
                  possible values are Female, Male, and Unknown.}"

var_standing <- "\\item{`standing`}{Character, academic standing, e.g.,
                 `Good Standing`, `Academic Warning`, etc.}"

var_term <- "\\item{`term`}{Character, academic year and term, format YYYYT.
                  Key column.}"

var_term_course <- "\\item{`term_course`}{Character, academic year and term,
                  format YYYYT. Key column.}"

var_term_degree <- "\\item{`term_degree`}{Character, academic year and term
                  in which a student completes their program, format YYYYT.}"

var_transfer <- "\\item{`transfer`}{Character, transfer status, possible
                 values are `First-Time in College`, `First-Time Transfer`.}"

var_type <- "\\item{`type`}{Character, predominant delivery method for this
              section, e.g., `Blended`, `Distance Education`, `Face-to-Face`,
              `Online`, etc.}"

var_us_citizen <- "\\item{`us_citizen`}{Character, US citizenship, possible
                   values are `No`, `Yes`.}"

var_stickiness <- "\\item{`stickiness`}{Numerical, program stickiness, the
                  ratio of `graduates` to `ever_enrolled`, in percent.}"

# Same information and ignore row order, column order
x <- toy_student[order(mcid), .(mcid, institution)]
y <- toy_student[order(institution), .(institution, mcid)]
same_content(x, y)

# Different number of rows
x <- toy_student[1:10]
y <- toy_student[1:11]
same_content(x, y)

# Different column names
x <- toy_student[, .(mcid)]
y <- toy_student[, .(institution)]
same_content(x, y)

# Different number of columns and column names
x <- toy_student[, .(mcid)]
y <- toy_student[, .(mcid, institution)]
same_content(x, y)

# Different number of rows, number of columns, and column names
x <- toy_student
y <- toy_term
same_content(x, y)

# Different row content
x <- toy_student[1:10]
y <- toy_student[2:11]
same_content(x, y)

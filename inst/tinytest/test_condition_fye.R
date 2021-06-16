test_condition_fye <- function() {

    library(data.table)
    options(datatable.print.class = TRUE)

    expect_equal(1L, 1L)

    invisible(NULL)
}

test_condition_fye()

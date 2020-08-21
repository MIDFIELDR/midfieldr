context("subset_ipeds")

# get_my_path() for data in the testing directory
# ctrl-shift-L to load internal functions

load(file = get_my_path("subset_students.rda"))
load(file = get_my_path("subset_terms.rda"))
load(file = get_my_path("subset_degrees.rda"))

# create the correct "r2" for the first test

# ck1 <- subset_students[, .(id, cip6, term_enter, transfer)]
# setnames(ck1, old = "cip6", new = "cip_enter")
# ck2 <- subset_terms[, .(id, term)]
# ck3 <- subset_degrees[, .(id, cip6, term_degree)]
# setnames(ck3, old = "cip6", new = "cip_degree")
#
# DT <- merge(ck1, ck2, by = "id", all.x = TRUE)
# DT <- merge(DT, ck3, by = "id", all.x = TRUE)
# DT <- DT[transfer != "Y"]
#
# # now we can select the last term by id
# DT <- DT[, .SD[term == max(term)], by = id]
# DT <- unique(DT)
# DT <- DT[grepl("^14", DT$cip_enter)]
# DT <- merge(DT, fye_start, by = "id", all.x = TRUE)
# rows_to_update <- DT$cip_enter %in% c("14XXXX", "14YYYY")
# DT[rows_to_update, cip_enter := start]
#
# # term_degree - span years = term_sum
# # term_enter must be no less than term_sum
# DT <- DT[, span := -12]
# DT <- term_add(DT, term_col = "term_degree", n_col = "span")
# rows_we_discount <- DT$term_enter < DT$term_sum
# DT[rows_we_discount, cip_degree := NA_character_]
#
# # discount degree if start and degree CIP not the same
# rows_we_discount <- DT$cip_enter != DT$cip_degree
# DT[rows_we_discount, cip_degree := NA_character_]
# # output
# DT[is.na(cip_degree), ipeds_grad := "N"]
# DT[!is.na(cip_degree), ipeds_grad := "Y"]
# DT[, term := NULL]
# DT[, transfer := NULL]
# DT[, cip_degree := NULL]
# DT[, start := NULL]
# DT[, term_enter := NULL]
# DT[, term_degree := NULL]
# DT[, span := NULL]
# DT[, term_sum := NULL]
# DT <- DT[order(id)]
# setnames(DT, old = "cip_enter", new = "start")
# # this is r2
# cat(wrapr::draw_frame(DT))

alt_start <- subset_students[, .(id, cip6)]
alt_start <- alt_start[grepl("^14", alt_start$cip6)]
alt_start <- merge(alt_start, fye_start, by = "id", all.x = TRUE)
rows_to_update <- is.na(alt_start$start)
alt_start <- alt_start[rows_to_update, start := cip6]
alt_start[, cip6 := NULL]
alt_start <- alt_start[order(id)]

test_that("Results are correct", {
    r1 <- subset_ipeds(starters = alt_start,
                       data_students = subset_students,
                       data_terms = subset_terms,
                       data_degrees = subset_degrees)
    r2 <- wrapr::build_frame(
        "id"           , "start" , "ipeds_grad" |
            "MID26016706", "140801", "Y"          |
            "MID26055335", "140701", "Y"          |
            "MID26062050", "140701", "N"          |
            "MID26067807", "141901", "Y"          |
            "MID26359104", "141901", "Y"          |
            "MID26359115", "141901", "N"          |
            "MID26360012", "143501", "N"          |
            "MID26360287", "141901", "N"          |
            "MID26360469", "142801", "N"          |
            "MID26361543", "141001", "Y"          |
            "MID26361588", "140201", "Y"          |
            "MID26361824", "141901", "Y"          |
            "MID26361916", "140701", "N"          |
            "MID26362268", "141901", "Y"          |
            "MID26363507", "141001", "N"          |
            "MID26366480", "140901", "N"          |
            "MID26368204", "143501", "Y"          |
            "MID26371808", "141901", "N"          |
            "MID26373318", "140801", "N"          |
            "MID26383557", "141001", "N"          |
            "MID26383660", "143501", "Y"          |
            "MID26384177", "143501", "Y"          |
            "MID26384832", "141001", "N"          |
            "MID26385262", "140801", "N"          )
    data.table::setDT(r2)
    expect_equal(r1, r2)
})
test_that("Required variables are present", {
    # span is a number
    expect_error(
        subset_ipeds(starters = alt_start,
                     span = "6"),
        "`span` must be of class numeric"
    )
    # starters requires columns id, start
    alt <- copy(alt_start)
    alt$id <- NULL
    expect_error(
        subset_ipeds(starters = alt),
        "Column name `id` required"
    )
    alt <- copy(alt_start)
    alt$start <- NULL
    expect_error(
        subset_ipeds(starters = alt),
        "Column name `start` required"
    )
   # data_students requires columns id, term_enter, transfer
    alt <- copy(subset_students)
    alt$id <- NULL
    expect_error(
        subset_ipeds(starters = alt_start,
                     data_students = alt),
        "Column name `id` required"
    )
    alt <- copy(subset_students)
    alt$term_enter <- NULL
    expect_error(
        subset_ipeds(starters = alt_start,
                     data_students = alt),
        "Column name `term_enter` required"
    )
    alt <- copy(subset_students)
    alt$transfer <- NULL
    expect_error(
        subset_ipeds(starters = alt_start,
                     data_students = alt),
        "Column name `transfer` required"
    )
    # data_terms requires columns id, cip6, term
    alt <- copy(subset_terms)
    alt$id <- NULL
    expect_error(
        subset_ipeds(starters = alt_start,
                     data_terms = alt),
        "Column name `id` required"
    )
    alt <- copy(subset_terms)
    alt$cip6 <- NULL
    expect_error(
        subset_ipeds(starters = alt_start,
                     data_terms = alt),
        "Column name `cip6` required"
    )
    alt <- copy(subset_terms)
    alt$term <- NULL
    expect_error(
        subset_ipeds(starters = alt_start,
                     data_terms = alt),
        "Column name `term` required"
    )
    # data_degrees requires columns id, cip6, term_degree
    alt <- copy(subset_degrees)
    alt$id <- NULL
    expect_error(
        subset_ipeds(starters = alt_start,
                     data_degrees = alt),
        "Column name `id` required"
    )
    alt <- copy(subset_degrees)
    alt$cip6 <- NULL
    expect_error(
        subset_ipeds(starters = alt_start,
                     data_degrees = alt),
        "Column name `cip6` required"
    )
    alt <- copy(subset_degrees)
    alt$term_degree <- NULL
    expect_error(
        subset_ipeds(starters = alt_start,
                     data_degrees = alt),
        "Column name `term_degree` required"
    )
})
test_that("Input data frames are correct class", {
    test_df <- copy(subset_students)
    not_df  <- test_df$id
    setnames(test_df, old = "cip6", new = "start")
    expect_error(
        subset_ipeds(starters = not_df),
        "`starters` must be of class data.frame"
    )
    expect_error(
        subset_ipeds(starters = test_df,
                     data_students = not_df),
        "`data_students` must be of class data.frame"
    )
    expect_error(
        subset_ipeds(starters = test_df,
                     data_terms = not_df),
        "`data_terms` must be of class data.frame"
    )
    expect_error(
        subset_ipeds(starters = test_df,
                     data_degrees = not_df),
        "`data_degrees` must be of class data.frame"
    )
})

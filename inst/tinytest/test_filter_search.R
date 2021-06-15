test_filter_search <- function() {

    library(data.table)
    options(datatable.print.class = TRUE)

    # create test case
    # music_cip <- filter_search(
    #     cip,
    #     keep_text = "^5009",
    #     drop_text = c("500902", "500903", "500904", "500905", "500909", "500911"),
    #     select    = c("cip4", "cip4name", "cip6", "cip6name")
    #     )
    # cat(wrapr::draw_frame(music_cip))

    # test case
    music_cip <- wrapr::build_frame(
          "cip4"  , "cip4name", "cip6"  , "cip6name"               |
            "5009", "Music"   , "500901", "Music, General"         |
            "5009", "Music"   , "500906", "Conducting"             |
            "5009", "Music"   , "500907", "Piano and Organ"        |
            "5009", "Music"   , "500908", "Voice and Opera"        |
            "5009", "Music"   , "500910", "Jazz, Jazz Studies"     |
            "5009", "Music"   , "500912", "Music Pedagogy"         |
            "5009", "Music"   , "500913", "Music Technology"       |
            "5009", "Music"   , "500914", "Brass Instruments"      |
            "5009", "Music"   , "500915", "Woodwind Instruments"   |
            "5009", "Music"   , "500916", "Percussion Instruments" |
            "5009", "Music"   , "500999", "Music, Other")
    setDT(music_cip)

    # various answers
    select_these <- c("cip4", "cip4name")
    music_codes <- music_cip[, cip6]
    ans <- wrapr::build_frame(
        "cip4", "cip4name" |
            "5009",  "Music"
    )
    setDT(ans)

    # Result is correct
    expect_equal(ans,
                 filter_search(music_cip, select = select_these))

    # Select produces correct columns
    expect_equal(select_these,
                 colnames(filter_search(music_cip, select = select_these)))

    # First two arguments do not have to be named if ordered correctly
    expect_equal(
        filter_search(keep_text = c("500913"), dframe = music_cip),
        filter_search(music_cip, c("500913"))
    )

    # Data returned unaltered if keep_text and drop_text are NULL
    expect_equal(
        filter_search(music_cip, keep_text = NULL, drop_text = NULL),
        music_cip,
    )

    # Result is empty if drop_text is all-inclusive
    expect_error(
        filter_search(music_cip,
                      drop_text = music_codes),
        paste("The search result is empty. Either 'keep_text' terms were not",
              "found or 'drop_text' eliminated every row.")
    )

    # Result is empty if keep_text is misspelled and therefore not found
    expect_error(
        filter_search(music_cip, keep_text = "Brasss"),
        paste("The search result is empty. Either 'keep_text' terms were not",
              "found or 'drop_text' eliminated every row.")
    )

    # Message if some keep_text not found
    incorrect_cip_text <- c("Bogus", "111111")
    expect_message(
        filter_search(music_cip, keep_text = c(music_codes, incorrect_cip_text)),
        "Can't find these terms: Bogus, 111111"
    )

    # Non-character columns coerced to text
    DT <- copy(music_cip[, .(cip4name, cip6)])
    DT[, x_dbl  := as.numeric(cip6)/100]
    DT[, x_int  := .I]
    DT[, x_lgcl := TRUE]

    expect_equal(DT, filter_search(DT, "Music"))
    expect_equal(DT[x_int == 11L], filter_search(DT, "11"))
    expect_equivalent(DT, filter_search(DT, "TRUE"))

    # function output not printed
    invisible(NULL)
}

test_filter_search()

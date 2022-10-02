test_filter_search <- function() {

    # usage
    # filter_search(dframe,
    #               keep_text = NULL,
    #               ...,
    #               drop_text = NULL,
    #               select = NULL)

    # Needed for tinytest::build_install_test()
    suppressPackageStartupMessages(library("data.table"))

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
                 unique(filter_search(music_cip, select = select_these)))

    # Arguments before ... do not have to be named if ordered correctly
    expect_equal(
        filter_search(keep_text = c("500913"), dframe = music_cip),
        filter_search(music_cip, c("500913"))
    )

    # Data returned unaltered if keep_text and drop_text are NULL
    expect_equal(
        filter_search(music_cip, keep_text = "Conducting", select = "cip6"),
        music_cip[cip6name =="Conducting", .(cip6)]
    )

    # Correct result if search terms found in columns not selected for return
    setkey(music_cip, NULL)
    expect_equal(
        filter_search(music_cip, keep_text = NULL, drop_text = NULL),
        music_cip
    )

    # Data returned unaltered if no arguments do anything
    expect_equal(
        filter_search(music_cip,
                      keep_text = NULL,
                      drop_text = NULL,
                      select = NULL),
        music_cip
    )

    # Select alone produces correct columns
    expect_equal(select_these,
                 colnames(filter_search(music_cip, select = select_these)))

    # Result is empty if drop_text is all-inclusive
    expect_error(
        filter_search(music_cip, drop_text = music_codes),
    )

    # Result is empty if keep_text is misspelled and therefore not found
    expect_error(
        filter_search(music_cip, keep_text = "Brasss")
    )

    # Message if some keep_text not found
    incorrect_cip_text <- c("Bogus", "111111")
    expect_message(
        filter_search(music_cip,
                      keep_text = c(music_codes, incorrect_cip_text))
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







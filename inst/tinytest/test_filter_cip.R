test_filter_cip <- function() {

    # usage
    # filter_cip(keep_text = NULL,
    #            ...,
    #            drop_text = NULL,
    #            cip = NULL, 
    #            select = NULL)
    
    # uncomment for internal manual testing
    # library(tinytest)
    
    # Needed for tinytest::build_install_test()
    library("data.table")

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
    expect_equal(unique(filter_cip(cip = music_cip, select = select_these)), ans)

    # Arguments before ... do not have to be named if ordered correctly
    expect_equal(
        filter_cip(keep_text = c("500913"), cip = music_cip),
        filter_cip(c("500913"), cip = music_cip)
    )

    # Correct result with keep and select
    expect_equal(
        filter_cip(keep_text = "Conducting", cip = music_cip, select = "cip6"),
        music_cip[cip6name =="Conducting", .(cip6)]
    )

    # Data returned unaltered if no arguments do anything
    expect_equal(filter_cip(cip = music_cip), setkey(music_cip, NULL))

    # Select alone produces correct columns
    expect_equal(colnames(filter_cip(cip = music_cip, select = select_these)),
                 select_these)

    # Result is empty if drop_text is all-inclusive
    expect_error(
        filter_cip(cip = music_cip, drop_text = music_codes),
    )

    # Result is empty if keep_text is misspelled and therefore not found
    expect_error(
        filter_cip(keep_text = "Brasss", cip = music_cip)
    )

    # Message if some keep_text not found
    incorrect_cip_text <- c("Bogus", "111111")
    expect_message(
        filter_cip(keep_text = c(music_codes, incorrect_cip_text), cip = music_cip)
    )

    # Non-character columns coerced to text
    DT <- copy(music_cip[, .(cip4name, cip6)])
    DT[, x_dbl  := as.numeric(cip6)/100]
    DT[, x_int  := .I]
    DT[, x_lgcl := TRUE]

    # expect_equal(filter_cip("Music", cip = DT))
    expect_equal(filter_cip("11", cip = DT), DT[x_int == 11L])
    expect_equivalent(filter_cip("TRUE", cip = DT), DT)

    # Default `cip`
    expect_equal(
        filter_cip("500913"),
        filter_cip(keep_text = c("500913"), cip = cip)
    )
    
    # function output not printed
    invisible(NULL)
}

test_filter_cip()







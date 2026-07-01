
# function used in the test
expect_class_preserved <- function(x, text, fnc) {
    
    run_check <- function(x, text, fnc) {
        z <- fnc(x, text)
        expect_equal(class(x), class(z))
    }
    
    # runs 3 checks: data.frame, tibble, data.table
    x <- copy(x)
    
    x <- as.data.frame(x)
    run_check(x, text, fnc)
    
    setattr(x, "class", c("tbl_df", "tbl", "data.frame"))
    run_check(x, text, fnc)
    
    x <- as.data.table(x)
    run_check(x, text, fnc)
    
    rm(x)
}

test_filter_programs <- function() {

    # usage
    # filter_programs(dframe,
    #             pattern, 
    #             ..., 
    #             negate = FALSE)
    
    # Needed for tinytest::build_install_test()
    suppressPackageStartupMessages(require("data.table"))

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
    music_codes <- music_cip[, cip6]
    ans <- wrapr::build_frame(
        "cip4", "cip4name" |
            "5009",  "Music"
    )
    setDT(ans)

    
    # ---------- start tests
    
    # check that class is preserved function
    expect_class_preserved(cip, "^14", filter_programs)
    

    # Arguments before ... do not have to be named if ordered correctly
    expect_equal(
        filter_programs(pattern = "500913", dframe = music_cip),
        filter_programs(music_cip, "500913")
    )

    # Error if no pattern
    expect_error(filter_programs(dframe = music_cip))


    

    # Non-character columns coerced to text
    DT <- copy(music_cip[, .(cip4name, cip6)])
    DT[, x_dbl  := as.numeric(cip6)/100]
    DT[, x_int  := .I]
    DT[, x_lgcl := TRUE]

    # expect_equal(filter_programs("Music", cip = DT))
    expect_equal(filter_programs("11", dframe = DT), DT[x_int == 11L])
    expect_equivalent(filter_programs("TRUE", dframe = DT), DT)

    
    # function output not printed
    invisible(NULL)
}

test_filter_programs()







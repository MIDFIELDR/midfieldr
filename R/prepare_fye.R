#' @import data.table
NULL

#' Prepare FYE data for multiple imputation
#'
#' Filter first-year-engineering (FYE) students and prepare variables for
#' predicting unknown starting majors. The prepared variables are institution,
#' race, and sex (predictors) and cip6 (with missing values to be imputed). The
#' function returns a data frame formatted for multiple imputation using
#' the mice package.
#'
#' Some US institutions have first year engineering (FYE) programs, typically
#' a common first year curriculum that is a prerequisite for declaring
#' an engineering major. FYE programs are problematic for some persistence
#' metrics. For example, in the conventional graduation rate metric, the only
#' students who count as graduates are those who complete the same
#' program in which they were admitted. But students cannot graduate in FYE;
#' instead, upon completing FYE, they transition to a degree-granting
#' engineering program.
#'
#' Therefore, to include FYE students in any persistence metric requiring a
#' degree-granting "starting" program, we have to predict the engineering
#' program the FYE student would have declared had they not been required to
#' enroll in FYE. \code{predict_fye()} sorts students into two categories:
#'
#' \enumerate{
#' \item{Students who complete an FYE and declare an engineering major.
#'     This is the easy case--at the student's first opportunity, they
#'     enrolled in an engineering program of their choosing. We use that
#'     program as the predicted  starting program.}
#' \item{Students who, after FYE, do not declare an engineering major.
#'     This is the more complicated case---the data provide no information
#'     regarding what engineering program the student would have declared
#'     originally had the institution not required them to enroll in FYE.
#'     For these students, we treat the starting program as missing data be
#'     predicted using multiple imputation.}
#' }
#'
#' The function extracts all terms for all FYE students from \code{mdata}.
#' In cases where students enter FYE, change programs, and re-enter FYE, only
#' the first group of FYE terms is considered. Any programs before FYE are
#' ignored. The first (if any) post-FYE program is identified. If the program
#' is in engineering, the CIP is retained as their predicted starting major.
#' If not, the CIP is replaced with NA to be treated as missing data for the
#' imputation.
#'
#' Lastly, the predictor variables (institution, race, sex) and the imputed
#' variable (cip6) are converted to unordered factors. The resulting data
#' frame is ready for use as input for the mice package.
#'
#' @param dframe data frame of all degree-seeking engineering students in the
#'        database, with required variables \code{mcid}, \code{race},
#'        and \code{sex}
#' @param ... not used, forces later arguments to be used by name
#' @param mdata MIDFIELD term data, default \code{midfielddata::term},
#'        with required variables \code{mcid}, \code{institution},
#'        \code{term}, and \code{cip6}
#' @param fye_codes character vector of 6-digit CIP codes to
#'        identify FYE programs
#'
#' @return A \code{data.table} with the following properties:
#' \itemize{
#'     \item One row for every FYE student
#'     \item Columns for ID, institution, race, sex, and CIP code, all
#'     except ID converted to factors.
#' }
#'
#' @family functions
#' @export
#' @examples
#' # TBD
prepare_fye <- function(dframe,
                        ...,
                        mdata = NULL,
                        fye_codes = NULL) {

    wrapr::stop_if_dot_args(
        substitute(list(...)), "Arguments after ... must be named,"
    )

    # default arguments if NULL
    mdata <- mdata %||% midfielddata::term
    fye_codes <- fye_codes %||% c("140102")

    # bind names due to NSE notes in R CMD check
    next_cip6 <- NULL
    next_cip2 <- NULL
    cip2 <- NULL

    # check arguments
    assert_explicit(dframe)
    assert_class(dframe, "data.frame")
    assert_class(mdata, "data.frame")
    assert_class(fye_codes, "character")

    # The dframe argument is modified "by reference." Thus changing its value
    # inside the function immediately changes its value in the calling frame
    # --- a data.table feature designed for fast data manipulation,
    # especially for data that occupies a lot of memory.
    setDT(dframe)
    setDT(mdata)

    # existence of required columns
    assert_required_column(dframe, "mcid")
    assert_required_column(dframe, "race")
    assert_required_column(dframe, "sex")

    assert_required_column(mdata, "mcid")
    assert_required_column(mdata, "institution")
    assert_required_column(mdata, "term")
    assert_required_column(mdata, "cip6")

    # class of required columns
    assert_class(dframe[, mcid], "character")
    assert_class(dframe[, race], "character")
    assert_class(dframe[, sex], "character")

    assert_class(mdata[, mcid], "character")
    assert_class(mdata[, institution], "character")
    assert_class(mdata[, term], "character")
    assert_class(mdata[, cip6], "character")

    # all degree-seeking engineering students
    latest_id <- dframe[, unique(mcid)]

    # degree-seeking engr and an FYE term
    rows_we_want <- mdata$mcid %chin% latest_id & mdata$cip6 %chin% fye_codes
    fye <- mdata[rows_we_want, .(mcid, institution)]

    # fye has ID and institution columns
    fye <- unique(fye)

    # join, result has FYE ID, institution, race, sex
    fye <- merge(fye, dframe, by = "mcid", all.x = TRUE)

    # update IDs
    latest_id <- fye[, unique(mcid)]

    # for these IDs, extract all their terms
    # cols_we_want <- c("mcid", "term", "cip6")
    # rows_we_want <- mdata$mcid %chin% latest_id
    # DT <- mdata[rows_we_want, cols_we_want, with = FALSE]

    DT <- filter_by_key(dframe = mdata,
                        match_to = fye,
                        key_col = "mcid",
                        select = c("mcid", "term", "cip6"))

    # order rows by setting keys
    setkeyv(DT, c("mcid", "term"))

    # determine the CIP in the immediately following term, keyed by ID
    DT[, next_cip6 := shift(.SD, n = 1, fill = NA, type = "lead"),
       by = "mcid",
       .SDcols = "cip6"]

    # omit rows for which the next term is FYE
    DT <- DT[!next_cip6 %chin% fye_codes]

    # omit rows in which consecutive CIPs are identical
    DT <- DT[cip6 != next_cip6]

    # add 2-digit codes
    DT[, `:=` (cip2 = substr(cip6, 1, 2),
               next_cip2 = substr(next_cip6, 1, 2)
    )]

    # at least one of the cip2 must be engineering
    DT <- DT[cip2 == "14" | next_cip2 == "14"]

    # keep rows in which the cip6 (term, not next term) is FYE
    DT <- DT[cip6 %chin% fye_codes]

    # keep the first term instance (some students enter FYE twice)
    DT <- DT[, .SD[1], by = "mcid"]

    # subset to retain those who transition to engr major after FYE
    DT <- DT[next_cip2 == "14"]

    # assign predicted engr major to replace FYE code
    DT[, cip6 := next_cip6]

    # drop unneeded columns
    DT <- DT[, .(mcid, cip6)]

    # fye currently has ID, institution, race, sex
    # join to original, introduces NA to cip6
    fye <- merge(fye, DT, by = "mcid", all.x = TRUE)

    # predictor variables and target variables to factors
    fye[, `:=` (institution = as.factor(institution),
                cip6 = as.factor(cip6),
                race = as.factor(race),
                sex = as.factor(sex)
    )]

    # reorder columns
    setcolorder(fye, c("mcid", "institution", "race", "sex", "cip6"))

    # reorder rows
    keys <- c("institution", "cip6", "sex", "race")
    setkeyv(fye, keys)

    # undo keys
    setkey(fye, NULL)

    # enable printing (see data.table FAQ 2.23)
    fye[]
}




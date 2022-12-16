
#' Subset rows that include matches to search strings
#'
#' Subset a CIP data frame, retaining rows that match or partially match a
#' vector of character strings. Columns are not subset unless selected in an
#' optional argument.
#'
#' Search terms can include regular expressions. Uses `grepl()``, therefore
#' non-character columns (if any) that can be coerced to character are also
#' searched for matches. Columns are subset by the values in `select` after the
#' search concludes.
#'
#' If none of the optional arguments are specified, the function returns the
#' original data frame.
#'
#' @param keep_text Character vector of search text for retaining rows, 
#'        not case-sensitive. Can be empty if `drop_text` is used. 
#' @param ... Not used, force later arguments to be used by name
#' @param drop_text Optional character vector of search text for dropping
#'        rows, default NULL.
#' @param cip Data frame to be searched. Default `cip`.
#' @param select Optional character vector of column names to return,
#'        default all columns.
#' @return A `data.table` subset of `cip` with the following properties:
#' \itemize{
#'     \item Rows matching elements of `keep_text`` but excluding rows
#'           matching elements of `drop_text`.
#'     \item All columns or those specified by `select`.
#'     \item Grouping structures are not preserved.
#' }
#'
#'
#' @family filter_*
#'
#'
#' @example man/examples/filter_cip_exa.R
#'
#'
#' @export
#'
#'
filter_cip <- function(keep_text = NULL,
                       ...,
                       drop_text = NULL,
                       cip = NULL, 
                       select = NULL) {
    
    # assert arguments after dots used by name
    wrapr::stop_if_dot_args(
        substitute(list(...)),
        paste(
            "Arguments after ... must be named.\n",
            "* Did you forget to write `drop_text = ` or `select = `?\n *"
        )
    )
    
    # optional arguments
    cipx   <- cip %?% midfieldr::cip
    dframe <- copy(cipx)
    select <- select %?% names(dframe)
    
    # remove all keys
    on.exit(setkey(dframe, NULL))
    
    # required argument
    qassert(dframe, "d+")
    
    # return if no work is being done
    if (identical(select, names(dframe)) &
        is.null(keep_text) &
        is.null(drop_text)) {
        setkey(dframe, NULL)
        return(dframe)
    }
    
    # assertions for optional arguments
    qassert(select, "s+") # missing is OK
    if (!is.null(keep_text)) qassert(keep_text, "s+")
    if (!is.null(drop_text)) qassert(drop_text, "s+")
    
    # input modified (or not) by reference
    setDT(dframe)
    
    # required columns
    # NA
    # class of required columns
    # NA
    # bind names due to NSE notes in R CMD check
    cip <- NULL
    
    # do the work
    dframe <- filter_char_frame(
        dframe = dframe,
        keep_text = keep_text,
        drop_text = drop_text
    )
    
    # stop if all rows have been eliminated
    if (abs(nrow(dframe) - 0) < .Machine$double.eps^0.5) {
        stop(
            paste(
                "The search result is empty. Possible causes are:\n",
                "* 'cip' contained no matches to terms in 'keep_text'.\n",
                "* 'drop_text' eliminated all remaining rows."
            ),
            call. = FALSE
        )
    }
    
    # message if a search term was not found
    # data frame with as many columns as there are keep_text terms
    # as many rows as there are being searched in data
    df <- data.frame(matrix("", nrow = nrow(dframe), ncol = length(keep_text)))
    names(df) <- keep_text
    
    for (j in seq_along(keep_text)) {
        df[, j] <- apply(dframe, 1, function(i) {
            any(grepl(keep_text[j], i, ignore.case = TRUE))
        })
    }
    
    # the sum is 0 for all FALSE in a column for that search term
    sumTF <- colSums(df)
    not_found <- sumTF[!sapply(sumTF, as.logical)]
    if (length(not_found) > 0) {
        message(paste(
            "Can't find these terms:",
            paste(names(not_found), collapse = ", ")
        ))
    }
    
    # subset columns
    dframe <- dframe[, .SD, .SDcols = select]
    
    # enable printing (see data.table FAQ 2.23)
    dframe[]
}

# ------------------------------------------------------------------------

# Subset rows of character data frame by matching keep_texts

# dframe      data frame of character variables
# keep_text   character vector of search keep_texts for retaining rows
# drop_text   character vector of search keep_texts for dropping rows

filter_char_frame <- function(dframe,
                              keep_text = NULL,
                              drop_text = NULL) {
  DT <- as.data.table(dframe)

  # filter to keep rows
  if (length(keep_text) > 0) {
    keep_text <- paste0(keep_text, collapse = "|")
    DT <- DT[apply(DT, 1, function(i) {
      any(grepl(keep_text, i, ignore.case = TRUE))
    }), ]
  }

  # filter to drop rows
  if (length(drop_text) > 0) {
    drop_text <- paste0(drop_text, collapse = "|")
    DT <- DT[apply(DT, 1, function(j) {
      !any(grepl(drop_text, j, ignore.case = TRUE))
    }), ]
  }

  # works by reference
  return(DT)
}

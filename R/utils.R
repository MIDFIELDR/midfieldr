
# all internal (utility) functions

# ------------------------------------------------------------------------

#' Vignette table
#'
#' Prints a data frame as an HTML table in a vignette. Uses knitr::kable
#' and kableExtra::kable_styling to adjust font size. Function is exported
#' to simplify use in vignettes.
#'
#' @param x data frame
#' @param font_size (optional) in points, 11 pt default
#' @param caption (optional) character
#'
#' @keywords internal
#' @export
#'
kable2html <- function(x, font_size = NULL, caption = NULL) {
  font_size <- font_size %||% 11
  kable_in <- knitr::kable(x, format = "html", caption = caption)
  kableExtra::kable_styling(kable_input = kable_in, font_size = font_size)
}

# ------------------------------------------------------------------------

#' Verify class of argument
#'
#' @param x object
#' @param y character string of required class
#'
#' @noRd
#'
assert_class <- function(x, y) {
  if (!is.null(x)) {
    if (!inherits(x, what = y)) {
      stop("`", deparse(substitute(x)), "` must be of class ",
        paste0(y, collapse = ", "),
        call. = FALSE
      )
    }
  }
}

# ------------------------------------------------------------------------

#' Verify that an argument is explicit, not NULL
#'
#' @param x object
#'
#' @noRd
#'
assert_explicit <- function(x) {
  if (is.null(x)) {
    stop("Explicit `", deparse(substitute(x)), "` argument required",
      call. = FALSE
    )
  }
}

# ------------------------------------------------------------------------

#' Verify required column name exists
#'
#' @param data data frame
#' @param col column name to be verified
#'
#' @noRd
#'
assert_required_column <- function(data, col) {
  assert_class(data, "data.frame")
  assert_class(col, "character")
  if (!col %in% names(data)) {
    stop("Column name `", col, "` required",
      call. = FALSE
    )
  }
}

# ------------------------------------------------------------------------

#' Assign default arguments in functions
#'
#' Infix operator. If 'a' is NULL, assign default 'b'.
#' a <- a %||% b
#'
#' @param a object that might be NULL
#' @param b default argument in case of NULL
#'
#' @noRd
#'
`%||%` <- function(a, b) {
  if (!is.null(a) && length(a) > 0) a else b
}

# ------------------------------------------------------------------------

#' Subset rows of character data frame by matching patterns
#'
#' @param data data frame of character variables
#' @param keep_text character vector of search patterns for retaining rows
#' @param drop_text character vector of search patterns for dropping rows
#'
#' @noRd
#'
filter_char_frame <- function(data, keep_text = NULL, drop_text = NULL) {

  # check arguments
  assert_explicit(data)
  assert_class(data, "data.frame")
  assert_class(keep_text, "character")
  assert_class(drop_text, "character")

  # to preserve data.frame, data.table, or tibble
  dat_class <- get_df_class(data)
  DT <- data.table::as.data.table(data)

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
  revive_class(DT, dat_class)
}

# ------------------------------------------------------------------------

#' Get the class of a data frame
#'
#' Used as argument in revive_class()
#'
#' @param x data.frame, tibble, or data.table
#'
#' @noRd
#'
get_df_class <- function(x) {

  # argument check
  assert_class(x, "data.frame")

  class_x <- class(x)
  if (sum(class_x %in% "data.table") > 0) {
    df_class <- "data.table"
  } else if (sum(class_x %in% c("tbl_df", "tbl")) > 0) {
    df_class <- "tbl"
  } else {
    df_class <- "data.frame"
  }
  return(df_class)
}

# ------------------------------------------------------------------------

#' Revive the class of a data frame
#'
#' In midfieldr functions, resets the class of a data frame: tibble,
#' data.frame, or data.table
#'
#' @param x data.frame, tibble, or data.table
#' @param df_class character "data.frame", "tbl", or "data.table"
#'
#' @noRd
#'
revive_class <- function(x, df_class) {

  # argument check
  assert_class(x, "data.frame")

  if (df_class == "tbl") {
    data.table::setattr(x, "class", c("tbl_df", "tbl", "data.frame"))
  } else if (df_class == "data.table") {
    x <- data.table::as.data.table(x)
  } else {
    x <- as.data.frame(x)
  }
  return(x)
}

# ------------------------------------------------------------------------

#' Get the class of a data frame column
#'
#' @param x data.frame, tibble, or data.table
#'
#' @noRd
#'
get_col_class <- function(x) {

  # argument check
  assert_class(x, "data.frame")

  col_class <- sapply(x, FUN = class)
  col_class <- as.data.frame(col_class)
  col_class$col_name <- row.names(col_class)
  row.names(col_class) <- NULL
  return(col_class)
}

# ------------------------------------------------------------------------

#' Unique rows in a data.table using keys
#'
#' @param DT data.table
#' @param cols character vector of column names as keys
#'
#' @noRd
#'
unique_by_keys <- function(DT, cols = NULL) {

  # argument check
  assert_class(DT, "data.frame")

  if (is.null(cols)) {
    cols <- names(DT)
  } else {
    cols <- cols
  }

  # argument check
  assert_class(cols, "character")

  data.table::setkeyv(DT, cols)
  DT <- subset(unique(DT))
  data.table::setkey(DT, NULL)
}

# ------------------------------------------------------------------------

#' Access midfielddegrees for feasible completion analysis
#'
#' Returns degrees column with "grad" and "nongrad"
#'
#' @param data degrees data
#'
#' @noRd
#'
fc_degrees <- function(data) {

  # defaults if NULL
  data <- data %||% copy(midfielddata::midfielddegrees)

  # argument check
  assert_class(data, "data.frame")

  # bind names
  degree <- NULL

  # label all grads and nongrads
  nongrad_rows <- is.na(data$degree)
  data[nongrad_rows, degree := "nongrad"]
  data[!nongrad_rows, degree := "grad"]
}

# ------------------------------------------------------------------------

#' Access midfieldstudents for feasible completion analysis
#'
#' Returns students' entering terms and transfer credit hours
#'
#' @param data students data
#' @param id character vector of student IDs
#'
#' @noRd
#'
fc_students <- function(data, id) {

  # defaults if NULL
  data <- data %||% copy(midfielddata::midfieldstudents)

  # argument check
  assert_class(data, "data.frame")
  assert_class(id, "character")

  # obtain transfer status
  transfer_data <- filter_by_id(
    data,
    keep_id = id,
    keep_col = c("id", "term_enter", "hours_transfer"),
    unique_row = TRUE
  )
}

# ------------------------------------------------------------------------

#' Access midfieldterms for feasible completion analysis
#'
#' Returns matriculation limit and median hours per term of graduating
#' students by institution
#'
#' @param data data frame
#' @param span numeric scalar, number of years to define feasibility, default
#' is 6 years
#' @param all_id character vector of student IDs
#'
#' @noRd
#'
fc_terms <- function(data, span, all_id) {

  # defaults if NULL
  data <- data %||% copy(midfielddata::midfieldterms)
  span <- span %||% 6

  # argument check
  assert_class(data, "data.frame")
  assert_class(span, "numeric")
  assert_class(all_id, "character")

  # bind names
  delta <- NULL
  med_hr_per_term <- NULL
  institution <- NULL
  matric_limit <- NULL
  id <- NULL
  hours_term <- NULL

  # gather institution data range for matriculation limit
  fc_inst <- term_range(data)

  # subtract span from max term
  fc_inst[, delta := -span * 2]
  fc_inst <- term_add(fc_inst, term_col = "max_term", n_col = "delta")

  # matriculation limit
  data.table::setnames(fc_inst, old = "term_sum", new = "matric_limit")
  fc_inst <- fc_inst[, .(institution, matric_limit)]

  # median hours/term of graduates by institution
  grads <- data[id %in% all_id, .(institution, hours_term)]
  hr_per_term <- grads[,
                       .(med_hr_per_term = stats::median(hours_term)),
                       by = institution]
  # join to inst data
  fc_inst <- hr_per_term[fc_inst, on = "institution"]
}



# ------------------------------------------------------------------------

#' Derive equivalent transfer terms for feasible completion analysis
#'
#' Returns data frame prepared for advancing the matriculation limit
#'
#' @param fc_data data frame
#' @param terms_transfer_max numeric scalar, the term equivalent of the
#' maximum number of transfer credit hours, default is 4 terms
#'
#' @noRd
#'
fc_advance_matric <- function(fc_data, terms_transfer_max) {

  # defaults if NULL
  terms_transfer_max <- terms_transfer_max %||% 4

  # argument check
  assert_class(fc_data, "data.frame")
  assert_class(terms_transfer_max, "numeric")

  # bind names
  terms_transfer <- NULL
  hours_transfer <- NULL
  med_hr_per_term <- NULL
  matric_limit <- NULL
  term_sum <- NULL

  # NAs to zero
  data.table::setnafill(fc_data,
                        type = "const",
                        fill = 0,
                        cols = c("hours_transfer")
  )

  # convert transfer hours to terms
  fc_data[, terms_transfer := floor(hours_transfer / med_hr_per_term)]

  # max transfer
  fc_data[
    terms_transfer > terms_transfer_max,
    terms_transfer := terms_transfer_max
  ]

  # advance matriculation limit by transfer terms
  fc_data <- term_add(fc_data,
                       term_col = "matric_limit",
                       n_col = "terms_transfer"
  )
  fc_data[, matric_limit := term_sum]
}








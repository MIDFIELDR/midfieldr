#' @importFrom dplyr group_by_ summarize n
#' @importFrom magrittr %>%
#' @importFrom tidyr spread gather
#' @importFrom rlang sym :=
#' @importFrom utils tail
NULL

#' Group and summarize a count of students
#'
#' Counts the number of students grouped by all the variables in \code{data}. The count is assigned the variable name in \code{count_label}. If the variables \code{sex}, \code{race}, or \code{institution} are present, the function fills a zero for a missing count at every intersection of these variables.
#'
#' @param data A data frame of unique students
#'
#' @param count_label An optional name for the count variable. Default is \code{n}.
#'
#' @return Data frame with a count of observations at the intersections of all variables in the \code{data} input data frame.
#'
#' @export
count_and_fill <- function(data, count_label = NULL) {
	if (is.null(count_label)) {
		count_label <- "n"
	}
	var_enq <- rlang::sym(count_label)
	data <- data %>%
		dplyr::group_by_(.dots = names(data)) %>%
		dplyr::summarize(!!var_enq := n()) # := from rlang
	var_names <- names(data)

	# assign zeros where a group is absent
	if ("race" %in% var_names) {
		col_idx <- grep("race", var_names)
		data <- data[ , c(seq_along(var_names)[-col_idx], col_idx)] %>%
			arrange(race)
		race_1 <- unique(data$race)[1]
		race_n <- utils::tail(unique(data$race), n = 1)
		data <- data %>%
			tidyr::spread(race, !!var_enq, fill = 0) %>%
			tidyr::gather(race, !!var_enq, race_1:race_n)
	}
	if ("sex" %in% var_names) {
		col_idx <- grep("sex", var_names)
		data <- data[ , c(seq_along(var_names)[-col_idx], col_idx)] %>%
			arrange(sex)
		sex_1 <- unique(data$sex)[1]
		sex_n <- utils::tail(unique(data$sex), n = 1)
		data <- data %>%
			tidyr::spread(sex, !!var_enq, fill = 0) %>%
			tidyr::gather(sex, !!var_enq, sex_1:sex_n)
	}
	if ("institution" %in% var_names) {
		col_idx <- grep("institution", var_names)
		data <- data[ , c(seq_along(var_names)[-col_idx], col_idx)] %>%
			arrange(institution)
		inst_1 <- unique(data$institution)[1]
		inst_n <- utils::tail(unique(data$institution), n = 1)
		data <- data %>%
			tidyr::spread(institution, !!var_enq, fill = 0) %>%
			tidyr::gather(institution, !!var_enq, inst_1:inst_n)
	}
	return(data)
}
"count_and_fill"

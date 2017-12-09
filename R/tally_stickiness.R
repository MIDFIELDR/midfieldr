#' @importFrom dplyr mutate group_by summarise full_join arrange ungroup n desc
#' @importFrom magrittr %>%
#' @importFrom stringr str_sub
NULL

#' Tally the "stickiness" of a program
#'
#' Stickiness is a persistence metric: the ratio of the number of students graduating in a program to the number of students ever enrolled in the program. This function groups and summarizes numbers of students by peer group (ethnicity and sex) and program (determined by the specified group of CIP codes), and computes the resulting stickiness.
#'
#' Tallying stickiness entails three steps: 1) group and summarize the number of graduates; 2) group and summarize the number of students ever enrolled in a program; 3) join the two summaries and compute stickiness.
#'
#' @param grad A data frame of unique students graduating in a set of programs. Gathered from the \code{degree} dataset using \code{gather_grad()}. The set of CIP codes should be the same as those used to create the \code{ever} data frame. The required variables in the \code{grad} data frame are GCIP, ETHNIC, and SEX.
#'
#' @param ever A data frame of unique students ever enrolled in a set of programs. Gathered from the \code{term} dataset using \code{gather_ever()}. The set of CIP codes should be the same as those used to create the \code{grad} data frame. The required variables in the \code{ever} data frame are TCIP, ETHNIC, and SEX.
#'
#' @param type An integer (2, 4, or 6) representing the CIP taxonomy level. The default is 4-digits.
#'
#' @param grad_min The smallest number of graduates in a peer group consistent with protecting student confidentiality. The default is 10.
#'
#' @return A data frame with variables CIP, ETHNIC, SEX, GRAD (the aggregate number of graduates), EVER (the aggregate number of students ever enrolled), and STICK (the resulting stickiness in percent).
#'
#' A stickiness of zero indicates that members of a peer group were enrolled in a program at one time but none graduated. A peer group missing from the results indicates that none were ever enrolled in that program.
#'
#' @export
tally_stickiness <- function(grad, ever, type = NULL, grad_min = NULL) {

	stopifnot(is.data.frame(grad))
	stopifnot("GCIP"   %in% names(grad))
	stopifnot("ETHNIC" %in% names(grad))
	stopifnot("SEX"    %in% names(grad))

	stopifnot(is.data.frame(ever))
	stopifnot("TCIP"   %in% names(ever))
	stopifnot("ETHNIC" %in% names(ever))
	stopifnot("SEX"    %in% names(ever))

	# default is the 4-digit CIP
	if (is.null(type)) {type = 4}

	# default cell size min is 10
	if (is.null(grad_min)) {grad_min = 10}

	grad_count <- grad %>%
		mutate(CIP = str_sub(GCIP, 1, type)) %>%
		group_by(CIP, ETHNIC, SEX) %>%
		summarise(GRAD = n())

	ever_count <- ever %>%
		mutate(CIP = str_sub(TCIP, 1, type)) %>%
		group_by(CIP, ETHNIC, SEX) %>%
		summarise(EVER = n())

	# full_join puts NA in GRAD if EVER exists but not GRAD
	stickiness <- full_join(grad_count, ever_count, by = c("CIP", "ETHNIC", "SEX"))

	# recode NA in GRAD to zero creating stickiness = zero for that group
	stickiness$GRAD[is.na(stickiness$GRAD)] <- 0

	# compute stickiness
	# After grouping and summarizing, if a population has fewer than 10 students, we exclude that population to protect student confidentiality.
	stickiness <- stickiness %>%
		mutate(STICK = round(GRAD / EVER * 100, 1)) %>%
		arrange(CIP, SEX, ETHNIC) %>%
		ungroup() %>%
		filter(GRAD >= grad_min)

	return(stickiness)

}
"tally_stickiness"

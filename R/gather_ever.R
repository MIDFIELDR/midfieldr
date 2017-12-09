#' @importFrom dplyr filter mutate bind_rows select rename
#' @importFrom magrittr %>%
#' @importFrom stringr str_length str_sub
NULL

#' Gather students ever enrolled in a program
#'
#' Gather students ever enrolled in a program using specified CIP program codes. Used to compute the stickiness metric.
#'
#' @param cip A data frame created using \code{filter_cip()}.
#'
#' @return A data frame of unique students
#'
#' @export
gather_ever <- function(cip){

	stopifnot(is.data.frame(cip))

	# separate cip into 2, 4, 6-digit chunks
	cip2 <- filter(cip, str_length(CIP) == 2)
	cip4 <- filter(cip, str_length(CIP) == 4)
	cip6 <- filter(cip, str_length(CIP) == 6)

	# create GCIP level 4 and level 2
	term <- term %>%
		mutate(TCIP_6 = TCIP) %>%
		mutate(TCIP_4 = str_sub(TCIP, 1, 4)) %>%
		mutate(TCIP_2 = str_sub(TCIP, 1, 2))

	# ensure the new columns have the right number of digits
	# in case the original CIP dataset changes
	term <- term %>%
		filter(str_length(TCIP_6) == 6) %>%
		filter(str_length(TCIP_4) == 4) %>%
		filter(str_length(TCIP_2) == 2)

	# now search each level
	ever2 <- filter(term, TCIP_2 %in% cip2$CIP)
	ever4 <- filter(term, TCIP_4 %in% cip4$CIP)
	ever6 <- filter(term, TCIP_6 %in% cip6$CIP)

	# and recombine
	ever <- bind_rows(ever2, ever4, ever6) %>%
		select(-TCIP_2) %>%
		select(-TCIP_4)  %>%
		select(-TCIP_6)

	# omit duplicate terms in same major
  ever <- ever %>%
  	select(MID, TCIP, INSTITUTION) %>%
		unique()

	return(ever)
}
"gather_ever"

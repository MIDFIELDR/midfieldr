#' @importFrom dplyr filter arrange mutate bind_rows select rename group_by ungroup row_number
#' @importFrom magrittr %>%
#' @importFrom stringr str_length str_sub
NULL

#' Gather graduates
#'
#' Gather graduates from the \code{degree} dataset using specified CIP program codes. If in the same term as earning their first bachelor's degree a student also earns a second or third bachelor's degree, the additional degrees appear as additional observations (rows) in the result. The student MID appears once for each degree.
#'
#' @param cip A data frame created using \code{filter_cip()}.
#'
#' @return A data frame of students graduating in the specified programs.
#'
#' @export
gather_grad <- function(cip){

	stopifnot(is.data.frame(cip))

	# separate cip into 2, 4, 6-digit chunks
	cip2 <- filter(cip, str_length(CIP) == 2)
	cip4 <- filter(cip, str_length(CIP) == 4)
	cip6 <- filter(cip, str_length(CIP) == 6)

	# MIDs where the first degree is in a single program
	# In case a student earns a second degree in a later year/term,
	# we group_by and filter to keep only the first degree
	one_degree <- degree %>%
		filter(is.na(GCIP2) & is.na(GCIP3)) %>%
		arrange(MID, GYEAR, GTERM) %>%
		group_by(MID) %>%
		filter(row_number(MID) == 1) %>%
		select(MID, GYEAR, DEGREE, GTERM, INSTITUTION, GCIP, GDESC, GCODE) %>%
		ungroup()

	# MIDs with multiple first bachelors in the same year/term
	multi_degree <- degree %>%
		filter(!is.na(GCIP2) | !is.na(GCIP3)) %>%
		arrange(MID, GYEAR, GTERM) %>%
		group_by(MID) %>%
		filter(row_number(MID) == 1) %>% # again, keep the first term
		ungroup()

	# isolate the first degree
	multi_1 <- multi_degree %>%
		select(MID, GYEAR, DEGREE, GTERM, INSTITUTION, GCIP, GDESC, GCODE)

	# isolate the second degree, rename its variables, omit any NA
	multi_2 <- multi_degree %>%
		select(MID, GYEAR, DEGREE, GTERM, INSTITUTION, GCIP2, GDESC2, GCODE2)  %>%
		rename(GCIP = GCIP2, GDESC = GDESC2, GCODE = GCODE2) %>%
		mutate(DEGREE = "BX2")

	# isolate the third degree, rename its variables, omit any NA
	multi_3 <- multi_degree %>%
		select(MID, GYEAR, DEGREE, GTERM, INSTITUTION, GCIP3, GDESC3, GCODE3)  %>%
		rename(GCIP = GCIP3, GDESC = GDESC3, GCODE = GCODE3) %>%
		mutate(DEGREE = "BX3")

	# recombine rows, now with multiple observation for MIDs with multiple degrees
	# omit any rows with GCIP = NA
	degree <- bind_rows(one_degree, multi_1, multi_2, multi_3) %>%
		arrange(MID, GYEAR, GTERM) %>%
		filter(!is.na(GCIP))
	# concludes handling the multi-degree cases

	# next we prepare for the case where the CIP codes we are using
	# are mixed 2, 4, 6 digits
	# create GCIP level 4 and level 2
	degree <- degree %>%
		mutate(GCIP_6 = GCIP) %>%
		mutate(GCIP_4 = str_sub(GCIP, 1, 4)) %>%
		mutate(GCIP_2 = str_sub(GCIP, 1, 2))

	# ensure the new columns have the right number of digits
	# in case the original CIP dataset changes
	degree <- degree %>%
		filter(str_length(GCIP_6) == 6) %>%
		filter(str_length(GCIP_4) == 4) %>%
		filter(str_length(GCIP_2) == 2)

	# now search each level
	grad2 <- filter(degree, GCIP_2 %in% cip2$CIP)
	grad4 <- filter(degree, GCIP_4 %in% cip4$CIP)
	grad6 <- filter(degree, GCIP_6 %in% cip6$CIP)

	# and recombine
	grad <- bind_rows(grad2, grad4, grad6) %>%
		select(-GCIP_2) %>%
		select(-GCIP_4)  %>%
		select(-GCIP_6)

	# and eliminate any duplicates
	grad <- grad %>%
		unique()

	return(grad)
}
"gather_grad"

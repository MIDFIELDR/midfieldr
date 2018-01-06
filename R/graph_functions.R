#' @importFrom ggplot2 scale_x_log10 theme_minimal theme element_text element_rect unit rel
#' @importFrom scales trans_breaks trans_format math_format
#' @importFrom RColorBrewer brewer.pal
NULL

#' Graph functions
#'
#' Provides a set of customized layers and arguments graphs created with for \code{ggplot2}.
#'
#' \describe{
#'
#' \item{\code{expon_scale_x_log10()}}{Applies the usual \code{scale_x_log10()} function with the scale marked powers of ten the exponent.}
#'
#' \item{\code{midfield_theme()}}{Applies \code{theme_minimal()} with some additional edits.}
#'
#' \item{\code{darkBr} ... \code{minBr}}{Brown color palette. Five hues named \code{darkBr, medBr, lightBr, paleBr, minBr} from the RColorBrewer "BrBG" palette.}
#'
#' \item{\code{darkBG} ... \code{minBG}}{Blue-green color palette. Five hues named \code{darkBG, medBG, lightBG, paleBG, minBG} from the RColorBrewer "BrBG" palette.}
#'
#' \item{\code{darkPR} ... \code{minPR}}{Purple color palette. Five hues named \code{darkPR, medPR, lightPR, palePR, minPR} from the RColorBrewer "PRGn" palette.}
#'
#' \item{\code{darkGn} ... \code{minBr}}{Green color palette. Five hues named  \code{darkGn, medGn, lightGn, paleGn, minGn} from the RColorBrewer "PRGn" palette.}
#'
#' \item{\code{gray9} ... \code{gray1}}{Gray color palette. Nine hues named   \code{gray9, gray8, ... , gray2, gray1} from the RColorBrewer "Greys" palette.}
#'
#' }
#'
#' @return Modifies an existing graph
#' @name graph_functions
#' @aliases NULL
NULL

#' @export
#' @rdname graph_functions
expon_scale_x_log10 <- function(){
	scale_x_log10(breaks = trans_breaks("log10", function(x) 10^x),
								labels = trans_format("log10", math_format(10^.x)),
								minor_breaks = c(10^0 * seq(2, 9),
																 10^1 * seq(2, 9),
																 10^2 * seq(2, 9),
																 10^3 * seq(2, 9),
																 10^4 * seq(2, 9),
																 10^5 * seq(2, 9),
																 10^6 * seq(2, 9))
	)
}

#' @export
#' @rdname graph_functions
midfield_theme <- function() {
theme_minimal(base_size = 10, base_family = "sans") +
	theme(
		plot.title   = element_text(size = rel(1)),
		axis.title   = element_text(size = rel(1)),
		axis.text    = element_text(size = rel(1)),
		legend.title = element_text(size = rel(1)),
		legend.text  = element_text(size = rel(1)),
		strip.text   = element_text(size = rel(1), hjust = 0),
		panel.border = element_rect(fill = "transparent",
																colour = "gray90",
																size = 0.5),
		legend.key.height = unit(0.8, "line"),
		legend.text.align = 0
	)
}

#' @export
#' @rdname graph_functions
darkBr  <- brewer.pal(10, "BrBG")[1]

#' @export
#' @rdname graph_functions
medBr   <- brewer.pal(10, "BrBG")[2]

#' @export
#' @rdname graph_functions
lightBr <- brewer.pal(10, "BrBG")[3]

#' @export
#' @rdname graph_functions
paleBr  <- brewer.pal(10, "BrBG")[4]

#' @export
#' @rdname graph_functions
minBr   <- brewer.pal(10, "BrBG")[5]

#' @export
#' @rdname graph_functions
minBG   <- brewer.pal(10, "BrBG")[6]

#' @export
#' @rdname graph_functions
paleBG  <- brewer.pal(10, "BrBG")[7]

#' @export
#' @rdname graph_functions
lightBG <- brewer.pal(10, "BrBG")[8]

#' @export
#' @rdname graph_functions
medBG   <- brewer.pal(10, "BrBG")[9]

#' @export
#' @rdname graph_functions
darkBG  <- brewer.pal(10, "BrBG")[10]

#' @export
#' @rdname graph_functions
darkPR  <- brewer.pal(10, "PRGn")[1]

#' @export
#' @rdname graph_functions
medPR   <- brewer.pal(10, "PRGn")[2]

#' @export
#' @rdname graph_functions
lightPR <- brewer.pal(10, "PRGn")[3]

#' @export
#' @rdname graph_functions
palePR  <- brewer.pal(10, "PRGn")[4]

#' @export
#' @rdname graph_functions
minPR   <- brewer.pal(10, "PRGn")[5]

#' @export
#' @rdname graph_functions
minGn   <- brewer.pal(10, "PRGn")[6]

#' @export
#' @rdname graph_functions
paleGn  <- brewer.pal(10, "PRGn")[7]

#' @export
#' @rdname graph_functions
lightGn <- brewer.pal(10, "PRGn")[8]

#' @export
#' @rdname graph_functions
medGn   <- brewer.pal(10, "PRGn")[9]

#' @export
#' @rdname graph_functions
darkGn  <- brewer.pal(10, "PRGn")[10]

#' @export
#' @rdname graph_functions
gray1   <- brewer.pal(9,"Greys")[1]

#' @export
#' @rdname graph_functions
gray2   <- brewer.pal(9,"Greys")[2]

#' @export
#' @rdname graph_functions
gray3   <- brewer.pal(9,"Greys")[3]

#' @export
#' @rdname graph_functions
gray4   <- brewer.pal(9,"Greys")[4]

#' @export
#' @rdname graph_functions
gray5   <- brewer.pal(9,"Greys")[5]

#' @export
#' @rdname graph_functions
gray6   <- brewer.pal(9,"Greys")[6]

#' @export
#' @rdname graph_functions
gray7   <- brewer.pal(9,"Greys")[7]

#' @export
#' @rdname graph_functions
gray8   <- brewer.pal(9,"Greys")[8]

#' @export
#' @rdname graph_functions
gray9   <- brewer.pal(9,"Greys")[9]

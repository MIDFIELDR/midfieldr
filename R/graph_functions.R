#' @importFrom ggplot2 scale_x_log10 theme_minimal theme element_text
#' @importFrom ggplot2 element_rect element_line element_blank unit rel
#' @importFrom scales trans_breaks trans_format math_format
NULL

#' Graph functions
#'
#' Provides a set of customized layers for graphs created with for \code{ggplot2}.
#'
#' \describe{
#'
#' \item{\code{expon_scale_x_log10()}}{Applies the usual \code{scale_x_log10()}
#' function with the scale marked with powers of ten in exponential form and the
#' logarithmic minor grid lines shown.}
#'
#' \item{\code{midfield_theme()}}{Applies \code{theme_minimal()} with some
#' additional edits.}
#' }
#'
#' @return Modifies an existing graph
#' @name graph_functions
#' @aliases NULL
NULL

#' @export
#' @rdname graph_functions
expon_scale_x_log10 <- function() {
	scale_x_log10(
		breaks = trans_breaks("log10", function(x)
			10 ^ x),
		labels = trans_format("log10", math_format(10 ^ .x)),
		minor_breaks = c(
			10 ^ 0 * seq(2, 9),
			10 ^ 1 * seq(2, 9),
			10 ^ 2 * seq(2, 9),
			10 ^ 3 * seq(2, 9),
			10 ^ 4 * seq(2, 9),
			10 ^ 5 * seq(2, 9),
			10 ^ 6 * seq(2, 9)
		)
	)
}

#' @export
#' @rdname graph_functions
midfield_theme <- function() {
	theme_minimal(base_family = "sans") +
		theme(
			plot.title   = element_text(size = 10),
			axis.title   = element_text(size = 10),
			axis.text    = element_text(size = 10),
			legend.title = element_text(size = 10),
			legend.text  = element_text(size = 10),
			strip.text   = element_text(size = 10, hjust = 0),

			axis.line        = element_line(size = 0.4, colour = rcb("pale_Gray")),
			axis.ticks       = element_line(size = 0.4, colour = rcb("pale_Gray")),
			panel.grid.major = element_line(size = 0.4, colour = rcb("pale_Gray")),
			panel.grid.minor = element_line(size = 0.4, colour = rcb("pale_Gray")),

			plot.background = element_blank(),
			panel.border    = element_rect(
				size = 0.4,
				colour = rcb("pale_Gray"),
				fill = NA
			),

			legend.key.height = unit(0.8, "line"),
			legend.text.align = 0
		)
}

#' @importFrom ggplot2 scale_x_log10 theme_minimal theme element_text rel
#' @importFrom ggplot2 element_rect element_line element_blank unit %+replace%
#' @importFrom scales trans_breaks trans_format math_format
NULL

#' Graphics utility functions
#'
#' A set of customized layers for ggplot2 graphs.
#'
#' \describe{
#' \item{\code{scale_x_log10_expon(...)}}{Applies the \code{scale_x_log10(...)}
#'        function from ggplot2 with the scale marked in exponential form
#'        powers of ten and with logarithmic minor grid lines.}
#' \item{\code{theme_midfield(...)}}{Applies \code{theme_minimal(...)} from
#'        ggplot2 with replacements: all text is 10 pt; lines are light
#'        gray (#D9D9D9) and size 0.4.}
#' }
#' @param ... Arguments that pass to the ggplot2 function
#' @param font_size The size assigned to all text in the figure.
#'        The default is 10 pt.
#' @param font_color The color assigned to all text in the figure.
#'        The default is black.
#' @param line_size The size assigned to all lines in the figure.
#'        The default is 0.3.
#' @param line_color The color assigned to all lines in the figure.
#'        The default is a light gray (#BDBDBD).
#' @return Modifies an existing graph.
#' @name utils_graph
#' @family graph_helper
#' @aliases NULL
NULL

#' @export
#' @rdname utils_graph
scale_x_log10_expon <- function(...) {
  scale_x_log10(...,
    breaks = trans_breaks("log10", function(x) 10^x),
    labels = trans_format("log10", math_format(10^.x)),
    minor_breaks = c(
      10^0 * seq(2, 9),
      10^1 * seq(2, 9),
      10^2 * seq(2, 9),
      10^3 * seq(2, 9),
      10^4 * seq(2, 9),
      10^5 * seq(2, 9),
      10^6 * seq(2, 9)
    )
  )
}

#' @export
#' @rdname utils_graph
theme_midfield <- function(font_size = NULL, font_color = NULL,
                           line_size = NULL, line_color = NULL) {
  if (is.null(font_size)) {
    font_size <- 10
  }
  if (is.null(font_color)) {
    font_color <- "black"
  }
  if (is.null(line_size)) {
    line_size <- 0.3
  }
  if (is.null(line_color)) {
    line_color <- rcb("light_Gray")
  }
  theme_minimal(base_family = "sans") +
    theme(
      plot.title = element_text(
        size = font_size,
        face = "plain", color = font_color
      ),
      plot.subtitle = element_text(
        size = font_size,
        face = "plain", color = font_color
      ),
      plot.caption = element_text(
        size = font_size,
        face = "plain", color = font_color
      ),
      axis.title = element_text(
        size = font_size,
        face = "plain", color = font_color
      ),
      axis.text = element_text(
        size = font_size,
        face = "plain", color = font_color
      ),
      legend.title = element_text(
        size = font_size,
        face = "plain", color = font_color
      ),
      legend.text = element_text(
        size = font_size,
        face = "plain", color = font_color
      ),
      strip.text = element_text(
        size = font_size,
        face = "plain", color = font_color,
        hjust = 0
      ),

      axis.line = element_line(
        size = line_size,
        colour = line_color
      ),
      axis.ticks = element_line(
        size = line_size,
        colour = line_color
      ),
      panel.grid.major = element_line(
        size = line_size,
        colour = line_color
      ),
      panel.grid.minor = element_blank(),

      plot.background = element_blank(),
      panel.border = element_rect(
        size = line_size,
        colour = line_color,
        fill = NA
      ),

      legend.key.height = unit(0.8, "line"),
      legend.text.align = 0
    )
}

% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/options.R
\name{sass_options}
\alias{sass_options}
\title{Compiler Options for Sass}
\usage{
sass_options(
  precision = 5,
  output_style = "expanded",
  indented_syntax = FALSE,
  include_path = "",
  source_comments = FALSE,
  indent_type = "space",
  indent_width = 2,
  linefeed = "lf",
  output_path = "",
  source_map_file = "",
  source_map_root = "",
  source_map_embed = FALSE,
  source_map_contents = FALSE,
  omit_source_map_url = FALSE
)
}
\arguments{
\item{precision}{Number of decimal places.}

\item{output_style}{Bracketing and formatting style of the CSS output.
Possible styles: \code{"nested"}, \code{"expanded"}, \code{"compact"}, and
\code{"compressed"}.}

\item{indented_syntax}{Enables the compiler to parse Sass Indented Syntax in
strings. Note that the compiler automatically overrides this option to
\code{TRUE} or \code{FALSE} for files with .sass and .scss file extensions
respectively.}

\item{include_path}{Vector of paths used to resolve \code{@import}. Multiple
paths are possible using a character vector of paths.}

\item{source_comments}{Annotates CSS output with line and file comments from
Sass file for debugging.}

\item{indent_type}{Specifies the indent type as \code{"space"} or
\code{"tab"}.}

\item{indent_width}{Number of tabs or spaces used for indentation. Maximum
10.}

\item{linefeed}{Specifies how new lines should be delimited. Possible values:
\code{"lf"}, \code{"cr"}, \code{"lfcr"}, and \code{"crlf"}.}

\item{output_path}{Specifies the location of the output file. Note: this
option will not write the file on disk. It is only for internal reference
with the source map.}

\item{source_map_file}{Specifies the location for Sass to write the source
map.}

\item{source_map_root}{Value will be included as source root in the source
map information.}

\item{source_map_embed}{Embeds the source map as a data URI.}

\item{source_map_contents}{Includes the contents in the source map
information.}

\item{omit_source_map_url}{Disable the inclusion of source map information in
the output file. Note: must specify \code{output_path} when \code{TRUE}.}
}
\value{
List of Sass compiler options to be used with
  \code{\link{sass}}.
}
\description{
Set compiler options for Sass. Used with \code{\link{sass}}.
}
\examples{
sass(
  "foo { margin: 122px * .3; }",
  options = sass_options(output_style = "compact")
)

}

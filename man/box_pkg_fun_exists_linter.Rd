% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/box_pkg_fun_exists_linter.R
\name{box_pkg_fun_exists_linter}
\alias{box_pkg_fun_exists_linter}
\title{\code{box} library attached function exists and exported by package linter}
\usage{
box_pkg_fun_exists_linter()
}
\value{
A custom linter function for use with \code{r-lib/lintr}
}
\description{
Checks that functions being attached exist and are exported by the package/library being called.
}
\details{
For use in \code{rhino}, see the
\href{https://appsilon.github.io/rhino/articles/explanation/rhino-style-guide.html}{Explanation: Rhino style guide}
to learn about the details.
}
\examples{
# will produce lint
lintr::lint(
  text = "box::use(stringr[function_not_exists],)",
  linter = box_pkg_fun_exists_linter()
)

# okay
lintr::lint(
  text = "box::use(stringr[str_pad],)",
  linter = box_pkg_fun_exists_linter()
)
}

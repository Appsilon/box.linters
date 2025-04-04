% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/box_usage_helper_functions.R
\name{get_object_calls}
\alias{get_object_calls}
\title{Get objects called in current source file.}
\usage{
get_object_calls(xml)
}
\arguments{
\item{xml}{An XML node list}
}
\value{
a list of \code{xml_nodes} and \code{text}.
}
\description{
This ignores objects to the left of \verb{<-}, \code{=}, \verb{\%<-\%} as these are assignments.
}
\keyword{internal}

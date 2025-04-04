% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/box_usage_helper_functions.R
\name{get_deconstructor_objects}
\alias{get_deconstructor_objects}
\title{Get the output object names of the deconstructor (\verb{rhino::\%<-\%}) assignment operator.}
\usage{
get_deconstructor_objects(xml)
}
\arguments{
\item{xml}{An XML node list}
}
\value{
a list of \code{xml_nodes} and \code{text}
}
\description{
This is a naive search for the \code{SYMBOLS} within a \code{c()} as the first expression before
the \verb{\%<-\%}. For example: \code{c(x, y, z) \%<-\% ...}.
}
\keyword{internal}

% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/logret_data.R
\docType{data}
\name{logret_data}
\alias{logret_data}
\title{Example Log Return Time Series}
\format{
A tibble with 7,550 rows and 2 columns:
\describe{
\item{day}{Date of observation (class \code{Date})}
\item{neg_log_ret}{Negative log return (numeric)}
}
}
\usage{
data(logret_data)
}
\description{
A tibble containing daily negative log returns of closing prices for the S&P 500 stock market index.
The observation period spans 20 trading years: 1995-01-01 to 2024-12-31.
}
\details{
The data was obtained using the \code{quantmod} package with \strong{Yahoo Finance} as the source.
}
\keyword{datasets}

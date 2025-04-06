#' Example Temperature Time Series
#'
#' This dataset contains daily temperature measurements in °C from the Hohenpeißenberg
#' weather station in Germany, covering 145 years: 1878-01-01 to 2023-12-31.
#'
#' The data was obtained from the Open Data Server of the German Meteorological Service (Deutscher Wetterdienst, DWD): \url{https://opendata.dwd.de/} and thus, is protected by law. It is reused under the Creative Commons licence CC BY 4.0.
#'
#'
#'
#'
#' @format A tibble with 52,960 rows and 2 columns:
#' \describe{
#'   \item{day}{Date of observation (class \code{Date})}
#'   \item{temp}{Temperature measured in °C (numeric)}
#' }
#'
#' @usage data(temp_data)
#' @keywords datasets
"temp_data"

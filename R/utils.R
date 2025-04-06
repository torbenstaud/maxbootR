#' Helper functions coded in R
#' @importFrom stats optim
#' @noRd

# Create a list of named frequency vectors ("tables") from blocks of a numeric vector
#
# This function splits a numeric vector into consecutive blocks of length \code{l}
# and returns a list of frequency tables (named vectors) for each block.
#
# @param x A numeric vector (typically a block-maxima transformed vector)
# @param l Block size
# @param n Optional total number of observations; defaults to \code{length(x)}
#
# @return A list of named numeric vectors, each representing a frequency table for a block
lTableVec <- function(x, l, n = 0){
  if(n == 0){
    n <- length(x)
  }
  mL <- ceiling(n/l)
  resList <- vector(mode = "list", length = mL)
  if(mL > 1){
    for(indI in seq(1,mL - 1)){
      resList[[indI]] <- table(x[seq((indI -1)*l+1, indI*l)]) # frequency table for block
    }
  }
  resList[[mL]] <- table(x[seq((mL-1)*l+1, n)]) # final (possibly shorter) block
  return(resList)
}

# Maximum likelihood estimation for GEV parameters using numeric input
#
# This function computes the MLE of the Generalized Extreme Value (GEV) distribution
# for a numeric vector using the BFGS optimization method. Starting values are chosen
# via method-of-moments heuristics if not provided.
#
# @param data A numeric vector of observed block maxima
# @param start Optional starting values (location, scale, shape); if \code{NULL}, default values are used
#
# @return An \code{optim} result containing the estimated parameters
gev_mle_cpp <- function(data, start = NULL){
  if (!is.numeric(data) || any(!is.finite(data))) {
    stop("Input data must be numeric and finite.")
  }

  if (is.null(start)) {
    start_scale <- sqrt(6 * var(data))/pi
    start <- c(mean(data) - 0.58 * start_scale,start_scale,  0)
  }

  result <- try({optim(
    par = start,
    fn = function(theta) neg_log_likelihood_gev(theta, data),
    method = "BFGS",
    control = list(maxit = 10**5, fnscale = length(data))
  )}, silent = T)
  return(result)
}

# Maximum likelihood estimation for GEV parameters using table-style (frequency) input
#
# This function performs MLE for the GEV distribution when the input is given
# as a named numeric vector representing frequencies. This is useful when using
# compressed representations like those produced by \code{table()}.
#
# @param data A named numeric vector representing the frequency of observed values
# @param start Optional starting values (location, scale, shape); if \code{NULL}, default values are used
# @param method Optimization method; currently ignored (placeholder for future use)
#
# @return An \code{optim} result containing the estimated parameters
gev_mle_cpp_lvec <- function(data, start = NULL, method = "L-BFGS-B") {
  if (!is.numeric(data) || any(!is.finite(data))) {
    stop("Input data must be numeric and finite.")
  }

  if (is.null(start)) {
    start_scale <- sqrt(6 * varCTabVec(data))/pi
    start <- c(meanCTabVec(data) - 0.58 * start_scale,start_scale,  0)
  }

  resultBfgs <- try({
    optim(
      par = start,
      fn = function(theta) neg_log_likelihood_gev_lvec(theta, data),
      method = "BFGS",
      control = list(maxit = 10**5, fnscale = sum(data))
    )
  }, silent = TRUE)

  if (!inherits(resultBfgs, "try-error")) {
    return(resultBfgs)
  }
}

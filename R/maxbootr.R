#' Bootstrap Estimation for Block Maxima
#'
#' Performs bootstrap resampling for various block maxima estimators (mean, variance, GEV parameters, quantile, return level) using either disjoint or sliding block methods.
#'
#' @param xx A numeric vector or array containing univariate samples. For multivariate cases, samples should be arranged in rows.
#' @param est A string specifying the estimator to apply. Must be one of \code{"mean"}, \code{"var"}, \code{"gev"}, \code{"quantile"}, or \code{"rl"}.
#' @param block_size Integer. Size of each block used in the block maxima extraction.
#' @param B Integer. Number of bootstrap replicates to generate.
#' @param type Type of block bootstrapping: \code{"db"} for disjoint blocks or \code{"sb"} for sliding blocks (internally approximated via circular blocks).
#' @param seed Integer. Seed for reproducibility.
#' @param p Optional numeric value in (0,1). Required if \code{est = "quantile"}.
#' @param annuity Optional numeric value > 1. Required if \code{est = "rl"} for return level estimation.
#'
#' @return A numeric vector with \code{B} rows for scalar estimators. If \code{est = "gev"}, a matrix with \code{B} rows is returned. Each row contains 3 estimated GEV parameters (location, scale, shape).
#'
#' @importFrom stats var
#' @examples
#' set.seed(123)
#' x <- rnorm(100)
#'
#' # Bootstrap mean using sliding blocks
#' boot_mean <- maxbootr(x, est = "mean", block_size = 10, B = 20, type = "sb")
#'
#' # Bootstrap variance using disjoint blocks
#' boot_var <- maxbootr(x, est = "var", block_size = 10, B = 20, type = "db")
#'
#' # Bootstrap 95%-quantile of block maxima using sliding blocks
#' boot_q <- maxbootr(x, est = "quantile", block_size = 10, B = 20, type = "db", p = 0.95)

#' @export
maxbootr <- function(xx, est, block_size, B = 1000, type = "sb", seed = 1,
                     p = NULL, annuity = NULL){

  # Argument checks for estimator type and parameters
  if(!(est %in% c("mean", "var", "gev", "quantile", "rl"))){
    stop("est has to be a valid estimator.")
  }else if(round(seed) != seed || seed <= 0){
    stop("seed must be a positive integer.")
  }else if(round(B) != B || B <= 0){
    stop("B must be a positive integer.")
  }else if(est == "quantile" && (is.null(p)|| !is.numeric(p) || p <= 0 || p >= 1)){
    stop("If est is chosen as quantile, p has to be supplied as a positive value between 0 and 1.")
  }else if(est == "rl" && (is.null(annuity)|| !is.numeric(annuity) || annuity <= 1 )){
    stop("If est is chosen as rl, annuity has to be supplied as a value bigger than 1.")
  }

  # Select estimator function depending on block type
  if(type == "db"){
    est.fun <- switch(
      est,
      mean = function(xx) {mean(xx)},
      var = function(xx) {var(xx)},
      gev = function(xx) {gev_mle_cpp(xx)$par},
      quantile = function(xx) {
        theta <- gev_mle_cpp(xx)$par
        return(evd::qgev(p, loc = theta[1], scale = theta[2], shape = theta[3]))
      },
      rl = function(xx) {
        theta <- gev_mle_cpp(xx)$par
        return(evd::qgev(1 - 1 / annuity, loc = theta[1], scale = theta[2], shape = theta[3]))
      }
    )
  }else if(type == "sb"){
    est.fun <- switch(
      est,
      mean = function(xx) {meanCTabVec(unlist(xx))},
      var = function(xx) {varCTabVec(unlist(xx))},
      gev = function(xx) {gev_mle_cpp_lvec(unlist(xx))$par},
      quantile = function(xx) {
        theta <- gev_mle_cpp_lvec(unlist(xx))$par
        return(evd::qgev(p, loc = theta[1], scale = theta[2], shape = theta[3]))
      },
      rl = function(xx) {
        theta <- gev_mle_cpp_lvec(unlist(xx))$par
        return(evd::qgev(1 - 1 / annuity, loc = theta[1], scale = theta[2], shape = theta[3]))
      }
    )
  }

  n <- length(xx)
  m <- floor(n / block_size)
  m.tr <- n / block_size
  lb.size <- n - m * block_size  # size of the remainder block (if any)

  # Extract block maxima (disjoint or circular/sliding)
  mbs <- switch(type,
                db = blockmax(xx, block_size, type = "db"),
                sb = blockmax(xx, block_size, type = "cb")
  )

  # Set output dimension: 3 for GEV, 1 for others
  if(est == "gev"){
    est.dim <- 3
  }else{
    est.dim <- 1
  }
  res.repl <- matrix(nrow = B, ncol = est.dim)
  set.seed(seed)

  # Bootstrap loop for disjoint blocks
  if(type == "db"){
    vec.prob <- rep(block_size / n, m)
    if (lb.size != 0) {
      vec.prob <- c(vec.prob, lb.size / n)
    }
    for(indB in seq_len(B)){
      res.repl[indB, ] <- est.fun(mbs[
        sample(seq_len(ceiling(m.tr)), ceiling(m.tr), prob = vec.prob, replace = TRUE)
      ])
    }
  }
  # Bootstrap loop for sliding blocks using list-of-tables
  else if(type == "sb"){
    m.tr.sb <- m.tr / 2
    lbb.size <- n - floor(m.tr.sb) * 2 * block_size
    vec.prob <- rep(2 * block_size / n, floor(m.tr.sb))
    if (lbb.size != 0) {
      vec.prob <- append(vec.prob, lb.size / n)
    }
    mbs.all.ltab <- lTableVec(mbs, 2 * block_size)
    for(indB in seq_len(B)){
      mbs.bst.ltab <- mbs.all.ltab[
        sample(seq_len(ceiling(m.tr.sb)), ceiling(m.tr.sb), prob = vec.prob, replace = TRUE)
      ]
      res.repl[indB, ] <- est.fun(mbs.bst.ltab)
    }
  }

  return(res.repl)
}

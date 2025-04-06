#' Compute Block Maxima from a Time Series
#'
#' Extracts block maxima from a univariate numeric vector or matrix using disjoint, sliding, or circular (k-dependent) block schemes.
#'
#' @param xx A numeric vector or matrix. For matrix input, each row is treated as a separate univariate series.
#' @param block_size Positive integer. Size of each block for maxima extraction.
#' @param type Character. Type of block maxima to compute. One of: \code{"db"} (disjoint blocks), \code{"sb"} (sliding blocks), or \code{"cb"} (circular blocks with k offsets).
#' @param k Integer (only used if \code{type = "cb"}). Blocking parameter which controlls the number of blocks contained in a block of blocks. Must be an integer between 1 and \code{floor(length(xx) / block_size)}.
#'
#' @return A numeric vector (if \code{xx} is a vector) or a matrix (if \code{xx} is a matrix). Each entry contains block maxima computed according to the selected method.
#' @examples
#' # Univariate time series example
#' set.seed(42)
#' x <- rnorm(100)
#'
#' # Disjoint blocks of size 10
#' bm_db <- blockmax(x, block_size = 10, type = "db")
#'
#' # Sliding blocks of size 10
#' bm_sb <- blockmax(x, block_size = 10, type = "sb")
#'
#' # Circular blocks of size 10 with blocking parameter k = 2
#' bm_cb <- blockmax(x, block_size = 10, type = "cb", k = 2)
#' @export
blockmax <- function(xx, block_size, type = "sb", k = 2) {
  # ---- Input checks ----
  if(!((is.matrix(xx) || is.vector(xx)) && is.numeric(xx))){
    stop("xx has to be a numeric vector or matrix.")
  } else if(!(type %in% c("db", "sb", "cb"))){
    stop("type has to be `db`, `sb` or `cb`.")
  }

  # Determine whether input is vector or matrix
  xx.type <- ifelse(is.null(dim(xx)), "vec", "arr")

  if(xx.type == "vec"){
    n <- length(xx)
  } else {
    n <- length(xx[1,])
  }

  m <- floor(n / block_size)

  # ---- Parameter validation ----
  if (block_size >= n) {
    stop("Block size is larger than the length of the time series. Please use a smaller block size.")
  } else if (block_size != round(block_size) || block_size <= 0) {
    stop("Block size has to be a positive integer.")
  } else if (k != round(k) || k <= 0) {
    stop("k has to be a positive integer.")
  } else if (sum(is.na(xx)) > 0) {
    stop("Missing values in xx. Please clean the data set.")
  } else if (m < k && type == "cb") {
    warning("There are no k blocks of size block size. The sliding block maxima sample is returned.")
  }

  if (m != n / block_size) {
    warning("The block size does not divide the sample size. The final block is handled dynamically.")
  }

  # ---- Compute block maxima ----
  if(xx.type == "vec"){
    bms <- switch(type,
                  db = dbMaxC(xx, block_size),
                  sb = slidMaxC(xx, block_size),
                  cb = kMaxTrC(xx, block_size, k)
    )
  } else {
    bms <- switch(type,
                  db = aperm(apply(xx, 1, function(yy) dbMaxC(yy, block_size)), c(2,1)),
                  sb = aperm(apply(xx, 1, function(yy) slidMaxC(yy, block_size)), c(2,1)),
                  cb = aperm(apply(xx, 1, function(yy) kMaxTrC(yy, block_size, k)), c(2,1))
    )
  }

  return(bms)
}


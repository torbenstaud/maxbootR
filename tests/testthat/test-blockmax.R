
test_that("test for correct errors and warnings", {
  expect_error(blockmax(c("test"), 4),
               "xx has to be a numeric vector or matrix.")
  expect_error(blockmax(matrix(c(1:3,"test"), nrow = 2), 4),
               "xx has to be a numeric vector or matrix.")
  expect_error(blockmax(1:4, 2, type = "test"),
               "type has to be `db`, `sb` or `cb`.")
  expect_error(blockmax(1:10, 10),
               "Block size is larger than the length of the time series. Please use a smaller block size.")
  expect_error(blockmax(1:4, 0),
               "Block size has to be a positive integer.")
  expect_error(blockmax(1:4, 2.3),
               "Block size has to be a positive integer.")
  expect_error(blockmax(1:4, 2, k = 0),
               "k has to be a positive integer.")
  expect_error(blockmax(1:4, 2, k = 2.3),
               "k has to be a positive integer.")
  expect_warning(blockmax(1:10, block_size = 4),
                 "The block size does not divide the sample size. The final block is handled dynamically.")
  expect_warning(blockmax(1:4, 2, k = 3, type = "cb"),
               "There are no k blocks of size block size. The sliding block maxima sample is returned.")
  expect_error(blockmax(c(1:6, NA), 2, k = 3, type = "cb"),
                 "Missing values in xx. Please clean the data set.")
})

test_that("blockmax returns correct number/dimensions of maxima", {
  xx.vec <- rnorm(100)
  xx.arr <- aperm(replicate(30, rnorm(100)), c(2,1))
  block_size <- 10
  expect_length(blockmax(xx.vec, 10, type = "db"), 10)
  expect_length(blockmax(xx.vec, 10, type = "sb"), 100)
  expect_length(blockmax(xx.vec, 10, type = "cb"), 100)
  expect_equal(dim(blockmax(xx.arr, 10, type = "db")), c(30, 10))
  expect_equal(dim(blockmax(xx.arr, 10, type = "sb")), c(30, 100))
  expect_equal(dim(blockmax(xx.arr, 10, type = "cb")), c(30, 100))
})

test_that("blockmax returns correct values", {
  xx <- c(4, 2, 10, 3, 7, 8, 9, 12, 20, 2)
  block_size <- 2

  expect_equal(blockmax(xx, block_size, type = "db"), c(4, 10, 8, 12, 20))
  expect_equal(blockmax(xx, block_size, type = "sb"),
               c(4, 10, 10, 7, 8, 9, 12, 20, 20, 4))
  expect_equal(blockmax(xx, block_size, type = "cb"),
               c(4, 10, 10, 4, 8, 9, 12, 12, 20, 20))

  expect_equal(suppressWarnings(blockmax(xx, 3, type = "db")), c(10, 8,20, 2))
  expect_equal(suppressWarnings(blockmax(xx, 3, type = "sb")),
               c(10, 10, 10, 8, 9, 12, 20, 20, 20, 4))
  expect_equal(suppressWarnings(blockmax(xx, 3, type = "cb")),
               c(10, 10, 10, 8, 8, 8, 20, 20, 20, 12))


  xx.arr <- matrix(nrow =2, ncol = 10)
  xx.arr[1,] <- xx
  xx.arr[2,] <- c(9, 20, 1, 40, 2, 3, 5.4, 7, 3.4, 7.123)

  expect_equal(blockmax(xx.arr, 5, type = "db"),
               matrix(c(10, 20, 40, 7.123), byrow = T, ncol = 2))
  expected <- matrix(c(10, 10, 12, 20, 20, 20, 20, 20, 20, 10, 40, 40, 40, 40, 7.123, 9, 20, 20, 40, 40), byrow = T, ncol = 10)
  expect_equal(suppressWarnings(blockmax(xx.arr, 6, type = "sb")), expected)

  expected <-
    matrix(c(
      10, 10, 10, 9, 12, 12, 12, 12, 20, 20,
      40, 40, 40, 40, 7, 9, 20, 20, 7.123, 7.123
    ), nrow = 2, byrow = T)
  expect_equal(suppressWarnings(blockmax(xx.arr, 4, type = "cb")), expected)
})

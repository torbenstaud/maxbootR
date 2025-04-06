test_that("test for correct errors and warnings", {
  expect_error(maxbootr(est = "test"),
               "est has to be a valid estimator.")
  expect_error(maxbootr(est = "mean", seed = 0),
               "seed must be a positive integer.")
  expect_error(maxbootr(est = "mean", B = 0),
               "B must be a positive integer.")
  expect_error(maxbootr(1:4, est = "quantile", p = "test"),
               "If est is chosen as quantile, p has to be supplied as a positive value between 0 and 1.")
  expect_error(maxbootr(1:4, est = "quantile"),
               "If est is chosen as quantile, p has to be supplied as a positive value between 0 and 1.")
  expect_error(maxbootr(1:4, est = "quantile", p = 0),
               "If est is chosen as quantile, p has to be supplied as a positive value between 0 and 1.")
  expect_error(maxbootr(1:4, est = "quantile", p = 1),
               "If est is chosen as quantile, p has to be supplied as a positive value between 0 and 1.")
  expect_error(maxbootr(1:4, est = "rl", annuity = 1),
               "If est is chosen as rl, annuity has to be supplied as a value bigger than 1.")
})

test_that("tests for mean estimator", {
  seed <- 2
  xx <- rnorm(400)
  bsize <- 50
  expect_length(maxbootr(xx, est = "mean", bsize, B = 13, type = "db"), 13)
  expect_length(maxbootr(xx, est = "mean", bsize, B = 1017, type = "db"), 1017)
  expect_length(maxbootr(xx, est = "mean", bsize, B = 13, type = "sb"), 13)
  expect_length(maxbootr(xx, est = "mean", bsize, B = 1017, type = "sb"), 1017)
})

test_that("tests for var estimator", {
  seed <- 3
  xx <- rnorm(400)
  bsize <- 50
  expect_length(maxbootr(xx, est = "var", bsize, B = 13, type = "db"), 13)
  expect_length(maxbootr(xx, est = "var", bsize, B = 1017, type = "db"), 1017)
  expect_length(maxbootr(xx, est = "var", bsize, B = 13, type = "sb"), 13)
  expect_length(maxbootr(xx, est = "var", bsize, B = 1017, type = "sb"), 1017)
})

test_that("tests for gev estimator", {
  seed <- 4
  xx <- rnorm(400)
  bsize <- 50
  expect_equal(dim(maxbootr(xx, est = "gev", bsize, B = 13, type = "db")), c(13,3))
  expect_equal(dim(maxbootr(xx, est = "gev", bsize, B = 1017, type = "db")), c(1017,3))
  expect_equal(dim(maxbootr(xx, est = "gev", bsize, B = 13, type = "sb")), c(13,3))
  expect_equal(dim(maxbootr(xx, est = "gev", bsize, B = 1017, type = "sb")), c(1017, 3))
})

test_that("tests for quantile estimator", {
  seed <- 5
  xx <- rnorm(400)
  bsize <- 50
  expect_length(maxbootr(xx, est = "quantile", bsize, B = 13, type = "db", p = 0.9), 13)
  expect_length(maxbootr(xx, est = "quantile", bsize, B = 1017, type = "db", p = 0.9), 1017)
  expect_length(maxbootr(xx, est = "quantile", bsize, B = 13, type = "sb", p = 0.9), 13)
  expect_length(maxbootr(xx, est = "quantile", bsize, B = 1017, type = "sb", p = 0.9), 1017)
})

test_that("tests for rl estimator", {
  seed <- 6
  xx <- rnorm(400)
  bsize <- 50
  expect_length(maxbootr(xx, est = "rl", bsize, B = 13, type = "db", annuity = 70), 13)
  expect_length(maxbootr(xx, est = "rl", bsize, B = 1017, type = "db", annuity = 80), 1017)
  expect_length(maxbootr(xx, est = "rl", bsize, B = 13, type = "sb", annuity = 90), 13)
  expect_length(maxbootr(xx, est = "rl", bsize, B = 1017, type = "sb", annuity = 100), 1017)
})

test_that("tests for unfortunate block sizes", {
  seed <- 7
  xx <- rnorm(401)
  bsize <- 50
  expect_length(maxbootr(xx, est = "rl", bsize, B = 107, type = "db", annuity = 80), 107)
  expect_length(maxbootr(xx, est = "rl", bsize, B = 107, type = "sb", annuity = 80), 107)
})

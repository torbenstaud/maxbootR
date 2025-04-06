test_that("test for correct errors and warnings", {
  expect_error(gev_mle_cpp(c("test")),
               "Input data must be numeric and finite.")
  expect_error(gev_mle_cpp_lvec(c("test")),
               "Input data must be numeric and finite.")
  }
)

test_that("test lTableVec", {
  xx <- rep(1:6, each = 2)
  expect_equal(length(lTableVec(xx, l = 3*2)), 2)
  expect_equal(length(lTableVec(xx, l = 4)), 3)
  expect_equal(length(lTableVec(xx, l = 5)), 3)
})

context("Utilities")



test_that("onLoad adds DD drat repo", {

  expect_equal(.onLoad()["declaredesign"], c(declaredesign="https://declaredesign.github.io"))

})


test_that("pretty printers", {
  expect_output(print(declare_population(sleep)), "declare_population\\(sleep\\)")
})

test_that("error if data is in there.", {
  expect_error(declare_potential_outcomes(data="foo"), "should not be a declared argument.")
})

test_that("fallback to lapply", {
  future_lapply <- future_lapply
  environment(future_lapply) <- new.env(parent = environment(future_lapply))
  environment(future_lapply)$requireNamespace <- function(...) FALSE

  expect_identical(future_lapply(LETTERS, identity), as.list(LETTERS))
})



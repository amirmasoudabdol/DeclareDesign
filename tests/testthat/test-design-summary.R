context("Design summary")

test_that("Basic design summary", {

  my_population <- declare_population(N = 500, noise = rnorm(N))

  my_potential_outcomes <- declare_potential_outcomes(Y_Z_0 = noise, Y_Z_1 = noise + rnorm(N, mean = 2, sd = 2))

  my_sampling <- declare_sampling(n = 250)

  my_assignment <- declare_assignment(m = 25)

  my_estimand <- declare_estimand(ATE = mean(Y_Z_1 - Y_Z_0))

  my_estimator <- declare_estimator(Y ~ Z, estimand = my_estimand)

  design <- declare_design(my_population,
                           my_potential_outcomes,
                           my_sampling,
                           my_estimand,
                           dplyr::mutate(q = 5),
                           my_assignment,
                           reveal_outcomes,
                           my_estimator)

  summary(design)

})
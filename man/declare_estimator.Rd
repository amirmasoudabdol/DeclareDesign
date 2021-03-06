% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/declare_estimator.R
\name{declare_estimator}
\alias{declare_estimator}
\alias{tidy_estimator}
\alias{model_handler}
\alias{estimator_handler}
\title{Declare Estimator}
\usage{
declare_estimator(..., handler = estimator_handler, label = "my_estimator")

tidy_estimator(estimator_function)

model_handler(data, ..., model = estimatr::difference_in_means,
  coefficients = FALSE)

estimator_handler(data, ..., model = estimatr::difference_in_means,
  coefficients = FALSE, estimand = NULL, label)
}
\arguments{
\item{...}{arguments to be captured, and later passed to the handler}

\item{handler}{a tidy-in, tidy-out function}

\item{label}{a string describing the step}

\item{estimator_function}{A function that takes a data.frame as an argument and returns a data.frame with the estimates, summary statistics (i.e., standard error, p-value, and confidence interval) and a label.}

\item{data}{a data.frame}

\item{model}{A model function, e.g. lm or glm. By default, the model is the \code{\link{difference_in_means}} function from the \link{estimatr} package.}

\item{coefficients}{Symbols or literal character vector of coefficients that represent quantities of interest, i.e. Z. If FALSE, return the first non-intercept coefficient; if TRUE return all coefficients. To escape non-standard-evaluation use \code{!!}.}

\item{estimand}{a declare_estimand step object, or a character label, or a list of either}
}
\value{
a function that accepts a data.frame as an argument and returns a data.frame containing the value of the estimator and associated statistics.
}
\description{
Declares an estimator which generates estimates and associated statistics

The intent here is to factor out the estimator/estimand labeling so that it can be reused by other model handlers.
}
\section{Custom Estimators}{


\code{estimator_functions} implementations should be tidy (accept and return a data.frame)

\code{model} implementations should at the miminum provide S3 methods for \code{summary} and \code{confint}.
}

\examples{

########################################################
# Default handler

my_estimand <- declare_estimand(ATE=mean(Y_Z_1-Y_Z_0))

# Automatically uses first non-intercept coefficient as estimate
# Default method is the `difference_in_means` estimator from `estimatr`

my_estimator_dim <- declare_estimator(Y ~ Z, estimand = "ATE", label = "DIM")

# lm from base R
my_estimator_lm <- declare_estimator(Y ~ Z, estimand = "ATE", model = lm, label = "LM")
# Use linear regression with robust standard errors from `estimatr` package
my_estimator_lm_rob <- declare_estimator(
  Y ~ Z,
  estimand = "ATE",
  model = estimatr::lm_robust,
  label = "LM_Robust"
)

# Set `coefficient`` if estimate of interest is not the first non-intercept variable
my_estimator_lm_rob_x <- declare_estimator(
  Y ~ X + Z,
  estimand = my_estimand,
  coefficients = "Z",
  model = estimatr::lm_robust
)

# Use glm from base R
my_estimator_glm <- declare_estimator(
  Y ~ X + Z,
  family = "gaussian",
  estimand = my_estimand,
  coefficients = "Z",
  model = glm
)

# A probit
estimator_probit <- declare_estimator(
  Y ~ Z,
  model = glm,
  family = binomial(link = "probit"),
  coefficients = "Z"
)

########################################################
# Custom handlers

# Define your own estimator and use the `tidy_estimator` function for labeling
# Must have `data` argument that is a data.frame
my_estimator_function <- function(data){
  data.frame(est = with(data, mean(Y)))
}

my_estimator_custom <- declare_estimator(
  handler = tidy_estimator(my_estimator_function),
  estimand = my_estimand
)

# Use a custom estimator function with custom labelling

my_estimator_function <- function(data){
  data.frame(
    estimator_label="foo",
    estimand_label="bar",
    est = with(data, mean(Y)),
    n = nrow(data),
    stringsAsFactors=FALSE
  )
}

my_estimator_custom2 <- declare_estimator(handler = my_estimator_function)

########################################################
# Examples

# First, set up the rest of a design
set.seed(42)

design_def <- declare_design(
  declare_population(N = 100, X = rnorm(N), W=rexp(N,1), noise=rnorm(N)),
  declare_potential_outcomes(Y ~ .25 * Z + noise),
  declare_estimand(ATE = mean(Y_Z_1 - Y_Z_0)),
  declare_assignment(m = 50),
  declare_reveal(),
  my_estimator_dim
)

run_design(design_def)

# Can also use declared estimator on a data.frame
dat <- draw_data(design_def)
my_estimator_dim(dat)

# ----------
# 2. Using existing estimators
# ----------

design <- replace_step(design_def, my_estimator_dim, my_estimator_lm_rob)

run_design(design)


design <- replace_step(design_def, my_estimator_dim, my_estimator_lm)

run_design(design)


design <- replace_step(design_def, my_estimator_dim, my_estimator_glm)

run_design(design)

# ----------
# 3. Using custom estimators
# ----------


design <- replace_step(design_def, my_estimator_dim, my_estimator_custom)

run_design(design)

# The names in your custom estimator return should match with
# your diagnosands when diagnosing a design
my_median <- function(data) data.frame(med = median(data$Y))

my_estimator_median <- declare_estimator(
  handler = tidy_estimator(my_median),
  estimand = my_estimand
)

design <- replace_step(design_def, my_estimator_dim, my_estimator_median)

run_design(design)

my_diagnosand <- declare_diagnosands(med_to_estimand = mean(med - estimand))
diagnose_design(design, diagnosands = my_diagnosand, sims = 5, bootstrap = FALSE)

# ----------
# 4. Multiple estimators per estimand
# ----------

design_two <- insert_step(design_def,  my_estimator_lm,  after=my_estimator_dim)

run_design(design_two)
diagnose_design(design_two, sims = 5, bootstrap = FALSE)

}

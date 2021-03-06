% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/declare_population.R
\name{declare_population}
\alias{declare_population}
\title{Declare the Size and Features of the Population}
\usage{
declare_population(..., handler = fabricate, label = NULL)
}
\arguments{
\item{...}{arguments to be captured, and later passed to the handler}

\item{handler}{a tidy-in, tidy-out function}

\item{label}{a string describing the step}
}
\value{
a function that returns a data.frame
}
\description{
Declare the Size and Features of the Population
}
\examples{

########################################################
# Default handler is fabricate

# Declare a single-level population with no covariates
my_population <- declare_population(N = 100)

# Declare a population from existing data
my_population <- declare_population(sleep)

# Declare a single-level population with a covariate
my_population <- declare_population(
  N = 6,
  gender=draw_binary(N, prob=.5),
  height_ft = rnorm(N, mean=5 + 4/12 + 4/12 * gender, sd=3/12)
)
my_population()

# Declare a two-level hierarchical population
# containing cities within regions

pop <- declare_population(
  regions = level(N = 5),
  cities = level(N = 10, pollution = rnorm(N, mean = 5))
)

head(my_population())

# Custom population functions

my_population_function <- function(N) {
  data.frame(u = rnorm(N))
}

my_population_custom <- declare_population(N = 10, handler = my_population_function)

my_population_custom()
}

// CFctns.cpp
#include <Rcpp.h>
using namespace Rcpp;
#include <cstdlib>  // For strtod (string to double conversion)

using namespace Rcpp;

// SECTION 0: General helper functions

// [[Rcpp::export]]
NumericVector convert_to_doubles(CharacterVector char_vec) {
  // Converts a character vector to a numeric vector using C-style conversion
  int n = char_vec.size();
  NumericVector num_vec(n);

  for(int i = 0; i < n; ++i) {
    std::string str = Rcpp::as<std::string>(char_vec[i]);
    char* endptr;
    double val = std::strtod(str.c_str(), &endptr);  // Safe conversion from string to double

    num_vec[i] = val;
  }

  return num_vec;
}

// [[Rcpp::export]]
double meanCTabVec(NumericVector xx) {
  // Computes the empirical mean from an R table-like numeric vector
  // The names of the vector are treated as values, and the entries as frequencies

  double mBar = 0, n = 0;
  int l = xx.length();
  NumericVector vals = convert_to_doubles(xx.names());

  for(int ind = 0; ind < l; ind++){
    mBar += xx[ind] * vals[ind];
    n += xx[ind];
  }

  mBar = mBar / n;  // Arithmetic mean
  return mBar;
}

// [[Rcpp::export]]
double varCTabVec(NumericVector xx) {
  // Computes the empirical variance from a frequency table (vector with named values)

  double mBar = 0, v = 0, n = 0;
  int l = xx.length();
  NumericVector vals = convert_to_doubles(xx.names());

  // First pass: calculate mean
  for(int ind = 0; ind < l; ind++){
    mBar += xx[ind] * vals[ind];
    n += xx[ind];
  }
  mBar = mBar / n;

  // Second pass: calculate squared deviations
  for(int ind = 0; ind < l; ind++){
    v += xx[ind] * std::pow(mBar - vals[ind], 2);
  }

  v = v / (n - 1);  // Sample variance
  return v;
}

// [[Rcpp::export]]
double neg_log_likelihood_gev(NumericVector theta, NumericVector xx) {
  // Computes the negative log-likelihood of the GEV distribution for a numeric vector

  double mu = theta[0];    // Location parameter
  double sigma = theta[1]; // Scale parameter (must be > 0)
  double gamma = theta[2]; // Shape parameter

  int n = xx.size();
  double neg_log_likelihood = 0.0;

  // Basic parameter validation
  if (sigma <= 0 || std::isnan(mu) || std::isnan(sigma) || std::isnan(gamma)) {
    return 1e10;  // Penalize invalid parameters
  }

  for (int i = 0; i < n; i++) {
    double z = (xx[i] - mu) / sigma;

    if (std::abs(gamma) == 0) {
      // Gumbel distribution (gamma = 0)
      neg_log_likelihood += std::log(sigma) + z + std::exp(-z);
    } else {
      // General GEV case: Fréchet or Weibull
      double t = 1.0 + gamma * z;

      if (t <= 0) {
        return 1e10;  // Outside of domain, apply heavy penalty
      }

      double exponent = -1.0 / gamma;
      double t_exponentiated = std::exp(exponent * std::log(t));  // t^(-1/gamma)

      neg_log_likelihood += std::log(sigma) + (1.0 / gamma + 1.0) * std::log(t) + t_exponentiated;
    }
  }

  return neg_log_likelihood;
}

// [[Rcpp::export]]
double neg_log_likelihood_gev_univ(NumericVector theta, double x) {
  // Computes the negative log-likelihood of a single GEV observation

  double mu = theta[0];    // Location
  double sigma = theta[1]; // Scale
  double gamma = theta[2]; // Shape

  // Parameter checks
  if (sigma <= 0 || std::isnan(mu) || std::isnan(sigma) || std::isnan(gamma)) {
    return 1e10;  // Penalize invalid input
  }

  double z = (x - mu) / sigma;
  double neg_log_likelihood;

  if (std::abs(gamma) == 0) {
    // Gumbel case
    neg_log_likelihood = std::log(sigma) + z + std::exp(-z);
  } else {
    // General GEV
    double t = 1 + gamma * z;

    if (t <= 0 || std::isnan(t) || std::isinf(t)) {
      return 1e10;  // Penalize invalid domain
    }

    double exponent = -1.0 / gamma;
    double t_exponentiated = std::exp(exponent * std::log(t));

    neg_log_likelihood = std::log(sigma) + (1.0 / gamma + 1.0) * std::log(t) + t_exponentiated;
  }

  return neg_log_likelihood;
}

// [[Rcpp::export]]
double neg_log_likelihood_gev_lvec(NumericVector theta, NumericVector xx) {
  // Computes the joint negative log-likelihood for a frequency-style vector (as from a table)
  // Vector names are treated as values, and entries as frequencies

  NumericVector data = convert_to_doubles(xx.names());  // Extract unique values from names
  double joint_neg_log_likelihood = 0.0;

  for (int i = 0; i < xx.size(); ++i) {
    // Weighted log-likelihood by frequency
    joint_neg_log_likelihood += xx[i] * neg_log_likelihood_gev_univ(theta, data[i]);
  }

  return joint_neg_log_likelihood;
}

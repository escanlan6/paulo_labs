# Week 2 helpers. Base R only; inputs are decimal log returns.
# Read the accompanying reference before using a function.

check_returns <- function(x) {
  stopifnot(is.numeric(x), length(x) >= 3L, all(is.finite(x)), sd(x) > 0)
  invisible(TRUE)
}

normal_fit <- function(x) {
  check_returns(x)
  c(n = length(x), m = mean(x), s = sd(x))
}

# m and s describe log returns over ONE specified holding interval.
normal_outcomes <- function(m, s, wealth = 100000, alpha = .99) {
  stopifnot(length(m) == 1, length(s) == 1, is.finite(m),
            is.finite(s), s > 0, wealth > 0, alpha > 0, alpha < 1)
  lower_log_quantile <- qnorm(1 - alpha, mean = m, sd = s)
  data.frame(
    mean_simple = expm1(m + s^2/2),
    median_simple = expm1(m),
    loss_probability = pnorm(0, mean = m, sd = s),
    lower_log_quantile = lower_log_quantile,
    VaR_eur = wealth * (-expm1(lower_log_quantile))
  )
}

return_moments <- function(x) {
  check_returns(x)
  centred <- x - mean(x)
  variance_n <- mean(centred^2)  # Divisor n for central moments, as in the lecture.
  skew <- mean(centred^3) / variance_n^1.5
  kurt <- mean(centred^4) / variance_n^2
  JB <- length(x)/6 * (skew^2 + (kurt - 3)^2/4)
  c(skewness = skew, excess_kurtosis = kurt - 3, JB = JB,
    JB_p = pchisq(JB, df = 2, lower.tail = FALSE))
}

# Explicit m/s mean a comparison against that fixed CDF.
# Omitting them fits a new mean and sample SD from x.
normal_discrepancy <- function(x, m = mean(x), s = sd(x)) {
  check_returns(x)
  stopifnot(is.finite(m), is.finite(s), s > 0)
  n <- length(x)
  i <- seq_len(n)
  ordered <- sort(x)
  u <- pnorm(ordered, mean = m, sd = s)
  # Log probabilities avoid rounding a far-tail CDF to exactly one.
  log_cdf <- pnorm(ordered, m, s, log.p = TRUE)
  log_survival <- pnorm(ordered, m, s, lower.tail = FALSE, log.p = TRUE)
  c(
    KS = max(i/n - u, u - (i - 1)/n),
    CvM = 1/(12*n) + sum((u - (2*i - 1)/(2*n))^2),
    AD = -n - sum((2*i - 1) * (log_cdf + rev(log_survival)))/n
  )
}

# Fitted-normal discrepancies are unchanged by shifting/scaling the sample.
# A single reference can serve all assets with the same n and fitting convention.
normal_mc_reference <- function(n, B = 4999L, seed = 109702L + n) {
  stopifnot(n >= 3, n == as.integer(n), B >= 99, B == as.integer(B))
  set.seed(seed)
  statistics <- matrix(NA_real_, nrow = B, ncol = 3,
                       dimnames = list(NULL, c("KS", "CvM", "AD")))
  for (b in seq_len(B)) {
    simulated <- rnorm(n)
    # The default arguments REFIT the mean and sample SD in every replicate.
    statistics[b, ] <- normal_discrepancy(simulated)
  }
  list(n = n, B = B, seed = seed, statistics = statistics)
}

mc_p_value <- function(observed, simulated_statistics) {
  stopifnot(length(observed) == 1L, is.finite(observed),
            length(simulated_statistics) > 0, all(is.finite(simulated_statistics)))
  (1 + sum(simulated_statistics >= observed)) / (length(simulated_statistics) + 1)
}

normal_tests <- function(x, reference) {
  check_returns(x)
  stopifnot(length(x) <= 5000L, reference$n == length(x),
            nrow(reference$statistics) == reference$B)
  moments <- return_moments(x)
  discrepancy <- normal_discrepancy(x)
  sw <- shapiro.test(x)
  data.frame(
    n = length(x),
    SW = unname(sw$statistic), SW_p = sw$p.value,
    JB = unname(moments["JB"]), JB_p = unname(moments["JB_p"]),
    AD = unname(discrepancy["AD"]),
    AD_p = mc_p_value(discrepancy["AD"], reference$statistics[, "AD"]),
    CvM = unname(discrepancy["CvM"]),
    CvM_p = mc_p_value(discrepancy["CvM"], reference$statistics[, "CvM"]),
    KS = unname(discrepancy["KS"]),
    KS_refit_p = mc_p_value(discrepancy["KS"], reference$statistics[, "KS"]),
    B = reference$B
  )
}

# Teaching comparison: both columns use the SAME simulated sample each time.
# The "fixed" column deliberately omits refitting and is inappropriate for the
# observed statistic, which compares the observations with their own fitted CDF.
ks_refit_experiment <- function(x, B = 4999L, seed = 209702L) {
  check_returns(x)
  stopifnot(B >= 99, B == as.integer(B))
  n <- length(x)
  original_mean <- mean(x)
  original_sd <- sd(x)
  observed <- unname(normal_discrepancy(x)["KS"])
  fixed <- refitted <- numeric(B)
  set.seed(seed)
  for (b in seq_len(B)) {
    simulated <- rnorm(n, mean = original_mean, sd = original_sd)
    fixed[b] <- normal_discrepancy(simulated, original_mean, original_sd)["KS"]
    refitted[b] <- normal_discrepancy(simulated)["KS"]
  }
  naive <- ks.test(x, "pnorm", original_mean, original_sd)$p.value
  list(
    observed = observed, B = B, seed = seed,
    draws = data.frame(fixed = fixed, refitted = refitted),
    p_values = data.frame(
      calibration = c("Ordinary KS (inappropriate here)",
                      "Fixed-parameter simulation (inappropriate here)",
                      "Simulation with refitting"),
      p_value = c(naive, mc_p_value(observed, fixed),
                  mc_p_value(observed, refitted))
    )
  )
}

format_p <- function(p, B = NULL) {
  vapply(p, function(value) {
    if (!is.null(B) && value <= 1/(B + 1) + 1e-12)
      return(paste0(format(1/(B + 1), scientific = FALSE), "*"))
    if (value < .0001) return("<0.0001")
    if (value < .001) return(formatC(value, digits = 4, format = "f"))
    formatC(value, digits = 3, format = "f")
  }, character(1))
}

# Annual clock: h is in years, lambda in jumps/year, sigma per sqrt(year).
# Jump mean/SD describe a single log jump; h = 1/252 is a trading step.
# mu controls E[exp(r_h)] = exp(mu*h). This is a scenario, not a fitted model.
jump_model <- function(mu = .08, sigma = .14, lambda = 2,
                       jump_mean = -.04, jump_sd = .06, h = 1/252) {
  stopifnot(all(is.finite(c(mu, sigma, lambda, jump_mean, jump_sd, h))),
            sigma > 0, lambda >= 0, jump_sd >= 0, h > 0)
  a <- mu - sigma^2/2 - lambda * expm1(jump_mean + jump_sd^2/2)
  list(mu = mu, sigma = sigma, lambda = lambda, jump_mean = jump_mean,
       jump_sd = jump_sd, h = h, a = a,
       log_mean = h * (a + lambda * jump_mean),
       log_variance = h * (sigma^2 + lambda * (jump_sd^2 + jump_mean^2)),
       expected_gross = exp(mu*h))
}

simulate_jump_returns <- function(n, model, seed = 209706L) {
  stopifnot(n > 0, n == as.integer(n))
  set.seed(seed)
  count <- rpois(n, model$lambda * model$h)
  background <- model$a * model$h +
    model$sigma * sqrt(model$h) * rnorm(n)
  # Conditional on count k, the sum of k independent normal jumps is normal.
  jumps <- count * model$jump_mean +
    sqrt(count) * model$jump_sd * rnorm(n)
  background + jumps
}

# Numerical CDF/quantiles provide a check on sparse simulated tail estimates.
jump_cdf <- function(q, model) {
  k <- 0:qpois(1 - 1e-12, model$lambda * model$h)
  weights <- dpois(k, model$lambda * model$h)
  means <- model$a * model$h + k * model$jump_mean
  sds <- sqrt(model$sigma^2 * model$h + k * model$jump_sd^2)
  result <- numeric(length(q))
  for (i in seq_along(k))
    result <- result + weights[i] * pnorm(q, means[i], sds[i])
  result
}

jump_quantile <- function(p, model) {
  stopifnot(all(p > 1e-10), all(p < 1 - 1e-10))
  vapply(p, function(probability) {
    # Enlarge the bracket if the selected horizon or parameters require it.
    lo <- model$log_mean - 1
    hi <- model$log_mean + 1
    while (jump_cdf(lo, model) > probability) lo <- lo - 2 * abs(lo) - 1
    while (jump_cdf(hi, model) < probability) hi <- hi + 2 * abs(hi) + 1
    uniroot(function(x) jump_cdf(x, model) - probability,
            interval = c(lo, hi), tol = 1e-11)$root
  }, numeric(1))
}

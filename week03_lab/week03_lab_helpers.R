# Week 3 laboratory helpers. Each function uses base R so that its calculations
# remain visible and can be checked directly.

check_pair <- function(actual, predicted) {
  if (!is.numeric(actual) || !is.numeric(predicted)) {
    stop("actual and predicted must be numeric")
  }
  if (length(actual) != length(predicted) || length(actual) == 0L) {
    stop("actual and predicted must have the same positive length")
  }
  if (any(!is.finite(actual)) || any(!is.finite(predicted))) {
    stop("actual and predicted must contain only finite values")
  }
  invisible(TRUE)
}

mae <- function(actual, predicted) {
  check_pair(actual, predicted)
  mean(abs(actual - predicted))
}

rmse <- function(actual, predicted) {
  check_pair(actual, predicted)
  sqrt(mean((actual - predicted)^2))
}

r2_against <- function(actual, predicted, baseline) {
  check_pair(actual, predicted)
  check_pair(actual, baseline)
  denominator <- sum((actual - baseline)^2)
  if (denominator <= 0) stop("baseline squared error must be positive")
  1 - sum((actual - predicted)^2) / denominator
}

prediction_metrics <- function(actual, predictions, baseline_name) {
  if (!is.list(predictions) || is.null(names(predictions))) {
    stop("predictions must be a named list of numeric vectors")
  }
  if (!(baseline_name %in% names(predictions))) stop("baseline name not found")
  baseline <- predictions[[baseline_name]]
  result <- lapply(names(predictions), function(method) {
    predicted <- predictions[[method]]
    data.frame(
      method = method,
      MAE = mae(actual, predicted),
      RMSE = rmse(actual, predicted),
      R2_test = r2_against(actual, predicted, baseline),
      stringsAsFactors = FALSE
    )
  })
  do.call(rbind, result)
}

expanding_volatility_forecasts <- function(finance,
                                            test_start = as.Date("2010-01-01")) {
  required <- c("month", "target_month", "realised_vol", "vix_end",
                "next_realised_vol")
  if (!all(required %in% names(finance))) {
    stop("finance data are missing a required column")
  }
  finance$month <- as.Date(finance$month)
  finance$target_month <- as.Date(finance$target_month)
  finance <- finance[order(finance$target_month), ]
  test_rows <- which(finance$target_month >= as.Date(test_start))

  forecasts <- lapply(test_rows, function(j) {
    training <- finance[finance$target_month < finance$target_month[j], ]
    if (nrow(training) < 24L) stop("fewer than 24 training months")
    if (max(training$target_month) > finance$month[j]) {
      stop("future outcome entered a training window")
    }
    fitted_model <- lm(next_realised_vol ~ vix_end, data = training)
    data.frame(
      origin_month = finance$month[j],
      target_month = finance$target_month[j],
      actual = finance$next_realised_vol[j],
      historical_mean = mean(training$next_realised_vol),
      persistence = finance$realised_vol[j],
      vix_model = as.numeric(predict(fitted_model, newdata = finance[j, ])),
      training_rows = nrow(training),
      training_R2 = summary(fitted_model)$r.squared
    )
  })
  do.call(rbind, forecasts)
}

risk_group_summary <- function(test_data, predicted_frequency, groups = 10L) {
  required <- c("ClaimNb", "Exposure")
  if (!all(required %in% names(test_data))) {
    stop("test data are missing ClaimNb or Exposure")
  }
  check_pair(test_data$ClaimNb, predicted_frequency)
  if (any(test_data$Exposure <= 0)) stop("exposure must be positive")
  n <- nrow(test_data)
  ordered_rank <- rank(predicted_frequency, ties.method = "first")
  risk_group <- floor((ordered_rank - 1) * groups / n) + 1L
  risk_group <- pmin(groups, pmax(1L, risk_group))

  parts <- split(seq_len(n), risk_group)
  result <- lapply(names(parts), function(g) {
    i <- parts[[g]]
    exposure <- sum(test_data$Exposure[i])
    data.frame(
      risk_group = as.integer(g),
      policies = length(i),
      exposure = exposure,
      claims = sum(test_data$ClaimNb[i]),
      mean_predicted_frequency = weighted.mean(
        predicted_frequency[i], test_data$Exposure[i]
      ),
      observed_frequency = sum(test_data$ClaimNb[i]) / exposure
    )
  })
  result <- do.call(rbind, result)
  result[order(result$risk_group), ]
}

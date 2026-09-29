# Week 4 data dictionary

The student ZIP contains one frozen monthly S&P 500/VIX panel. It can be used offline. The panel is copied byte-for-byte from the Week 3 freeze; `metadata.yml` and `source_week03_metadata.yml` preserve its source and construction record.

## `data/sp500_vix_monthly.csv`

One row joins a forecast-origin month with the following calendar month's target.

| Column | Definition |
|---|---|
| `month` | Forecast-origin calendar month, stored as its first date |
| `trading_days` | Number of S&P 500 daily return observations used for current-month volatility |
| `sp500_month_return` | Current-month S&P 500 price return, percent |
| `realised_vol` | Current-month annualised realised volatility, percentage points |
| `vix_date` | Date of the last available VIX close in the origin month |
| `vix_end` | That VIX close, annualised volatility points |
| `target_month` | Following calendar month, stored as its first date |
| `next_realised_vol` | Realised volatility from daily S&P 500 log returns in `target_month` |
| `sample_role` | Week 3 label: `train` through December 2009, `test` from January 2010 |

Realised volatility is $100\sqrt{252}$ times the sample standard deviation of daily S&P 500 log returns in a month. VIX and realised volatility are both measured in annualised percentage points. The final target is December 2025; the final origin is November 2025.

## Information dates for Week 4

At the end of `month`, the origin-month VIX close and realised volatility are available. The target `next_realised_vol` is available only after `target_month` ends. For an origin $t$, include a training row only when its `target_month <= t`. The scored target row is never in its own training set.

Validation uses 120 target months from January 2000 to December 2009. Assessment uses 192 target months from January 2010 to December 2025. The four candidate formulas and MSE selection rule are recorded in `metadata.yml`.

## Sources and integrity

- S&P 500 daily closes: [Yahoo Finance historical data](https://finance.yahoo.com/quote/%5EGSPC/history/), downloaded for the Week 3 course freeze.
- VIX daily history: [Cboe historical data](https://cdn-api.cboe.com/api/global/us_indices/daily_prices/VIX_History.csv), downloaded for the same freeze.
- `metadata.yml` records the panel SHA-256 hash and the Week 4 protocol. `source_week03_metadata.yml` records the original Week 3 freeze and source-file MD5 values. `SHA256SUMS.txt` in the ZIP records packaged-file hashes.

The 2010–2025 aggregate results for some candidates already appeared in Week 3. Week 4 therefore uses that period as a retrospective classroom comparison, not an untouched external test.

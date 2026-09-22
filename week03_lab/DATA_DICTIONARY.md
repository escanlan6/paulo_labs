# Week 3 data dictionary

The student package contains frozen, prepared data. No live download is required.

## `sp500_vix_monthly.csv`

One row contains a forecast origin month and its next-month target.

| Column | Definition |
|---|---|
| `month` | Forecast-origin calendar month, stored as its first date |
| `trading_days` | S&P 500 return observations used in current-month realised volatility |
| `sp500_month_return` | Current-month S&P 500 price return, percent |
| `realised_vol` | Current-month annualised realised volatility, percentage points |
| `vix_date` | Date of the last available VIX close in `month` |
| `vix_end` | That VIX close, annualised volatility points |
| `target_month` | Next calendar month |
| `next_realised_vol` | Realised volatility calculated from S&P 500 daily log returns in `target_month` |
| `sample_role` | `train` for targets through December 2009, `test` for January 2010 through December 2025 |

Monthly realised volatility is

$$
100\sqrt{252}\times
\operatorname{sd}(\text{daily S&P 500 log returns in the month}).
$$

The calculation uses the sample standard deviation. Months with fewer than 15 daily returns would be excluded; none of the retained forecast targets violates the required alignment. VIX and realised volatility use annualised percentage-point units.

Sources:

- S&P 500 (`^GSPC`) daily closes from Yahoo Finance, downloaded for the course freeze;
- Cboe VIX daily history from the official historical-data download.

The data stop on 31 December 2025 even when a source download contains later observations.

## `motor_frequency.csv.gz`

One row is one anonymised French motor third-party liability policy observation.

| Column | Definition |
|---|---|
| `IDpol` | Unique anonymised policy identifier |
| `ClaimNb` | Observed number of claims |
| `Exposure` | Time at risk in years |
| `DrivAge` | Driver age in years |
| `BonusMalus` | Bonus-malus score |
| `Area` | Area category A-F |
| `sample_role` | Frozen seeded policy assignment, approximately 70% `train` and 30% `test` |
| `claim_frequency` | `ClaimNb / Exposure`, claims per exposure-year |

The Week 3 build retains all 677,991 supplied rows. The selected fields have no missing values, exposure is positive and claim counts are non-negative. The maximum supplied count is 16 and the maximum exposure is 2.01 years. Counts and exposures were not capped or silently changed.

Policy identifiers are unique. The training and test roles therefore cannot share a policy. The assignment uses seed 109703 and is stored in the file so every student receives the same comparison.

Source: `freMTPL2freq` in CASdatasets. Cite Christophe Dutang and Arthur Charpentier (2026), *CASdatasets: Insurance datasets*, DOI [10.57745/P0KHAG](https://doi.org/10.57745/P0KHAG).

## Metadata and integrity

- `metadata.yml` records the target definitions, source URLs, freeze date, split seed and MD5 hashes of source downloads.
- `SHA256SUMS.txt` in the distributed package records hashes of the packaged data and metadata.

All Week 3 predictions are pedagogical. The policy model does not establish causation or permission to use a factor in an insurance tariff. The finance model does not constitute a trading strategy.

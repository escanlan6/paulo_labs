# Week 2 data dictionary

## Investments and construction

| Asset | Investment | Currency treatment |
|---|---|---|
| Equities | VWRL.AS global-equity fund | EUR listing |
| Bonds | IEGA.AS euro government-bond fund | EUR listing |
| Gold | PHAU.L physical-gold product | USD level divided by ECB USD per EUR |
| Portfolio | 60% equities, 30% bonds, 10% gold | Built from the EUR simple returns |

These are the Week 1 investments and frozen inputs. The returns are nominal
total returns to a EUR investor. Fund adjusted-price ratios incorporate
reinvestment. There is no safe-account discounting and no transaction cost.

The portfolio is frictionless and resets to 60/30/10 at each common observation.
Daily simple returns are weighted before taking logs. Weekly and monthly
portfolio returns compound this daily strategy; they are not weighted sums
of component weekly or monthly simple returns.

## Return files

`returns_daily_eur.csv`, `returns_weekly_eur.csv` and
`returns_monthly_eur.csv` contain one row per investment and interval.

| Column | Definition |
|---|---|
| `asset` | Equities, Bonds, Gold or Portfolio |
| `start_date` | Date of the starting wealth/level, ISO YYYY-MM-DD |
| `date` | Date of the ending wealth/level |
| `gross_return` | Ending wealth divided by starting wealth, G |
| `simple_return` | G - 1; decimals, so 0.01 means 1% |
| `log_return` | log(G); decimals |
| `wealth` | End-of-interval wealth for an initial 100 on 2020-01-02 |
| `level` | Underlying adjusted EUR asset level at the endpoint; deliberately missing for Portfolio |
| `period` | Aggregation grouping date in weekly/monthly files; use start_date/date for actual endpoints |

Do not compare raw levels across assets: their scales differ. Wealth is the
common-base series. Missing portfolio `level` values are intentional;
the three return columns must be complete.

The common level window is 2 January 2020 to 31 December 2025. There are
1,510 daily intervals per investment, with the first ending 3 January 2020.
The common calendar matches Week 1, including the ECB FX and overnight-rate
calendar. “Daily” means a common observation step, which can span weekends
or holidays. Equal-step models approximate these observation intervals.

Monthly returns use end-of-month wealth ratios and exclude the initial
incomplete month. There are 71 per investment, from the interval ending
28 February 2020 through December 2025. The starting endpoint of that first
monthly interval is 31 January 2020. Weekly data are supplied for extension
work and similarly use end-of-period wealth ratios.

## Metadata and provenance

- `asset_metadata.csv`: original Week 1 instrument metadata. VWRD.L is an
  alternative USD listing of the equity exposure used for a Week 1 currency
  comparison; it is not an additional Week 2 return series.
- `source_week01_metadata.yml`: original download dates and public sources.
- `metadata.yml`: Week 2 construction conventions and lecture-build context.
  Its source-input hashes refer to the original Week 1 files, which remain
  in the course archive; those price files are not needed for this lab.
- `SHA256SUMS.txt`: integrity hashes of the packaged data and metadata files.

The package supplies verified returns rather than recreating the Week 1
download exercise. Its return files are byte-for-byte copies of the lecture's
frozen inputs. The R reference documents the lab's simulation seeds.

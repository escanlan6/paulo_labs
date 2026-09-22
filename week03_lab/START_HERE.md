# Week 3 laboratory

Extract the entire ZIP into a writable folder before opening its files.

1. Open **week03_lab.html** in a browser to read the tasks.
2. Open **week03_lab.qmd** in RStudio to complete the worksheet.
3. Keep **week03_r_reference.html** open for function syntax and assumptions.
4. Run the setup chunk, add your code and interpretations, then select **Render**.

This is a two-hour formative lab. Nothing is submitted for marks. AI tools are allowed when you request small pieces of code, explain them, check the units and write your own interpretation.

## Requirements

The supplied HTML works offline and needs only a browser.

To execute the worksheet, use R 4.1 or later, RStudio and Quarto. Install these packages once if needed:

```r
install.packages(c("dplyr", "tidyr", "readr", "ggplot2",
                   "scales", "knitr", "rmarkdown"))
```

Package installation needs internet access. The laboratory calculations use the included frozen files and need no network connection.

## Included files

- `week03_lab.qmd` and `.html`: editable worksheet and reading copy.
- `week03_r_reference.qmd` and `.html`: R syntax and method notes.
- `week03_lab_helpers.R`: readable metric, expanding-window and risk-group functions.
- `data/`: monthly finance data, policy data and provenance.
- `DATA_DICTIONARY.md`: columns, units, sources and split conventions.
- `lab.css`: document style.
- `finalize_html.cjs` and `vendor/katex/`: optional offline equation bundler.

Keep the folder structure intact. Do not refresh the market data or generate a different policy split.

## Offline equations after rerendering

An ordinary Quarto render may refer to an online KaTeX library. The distributed HTML has already been made offline. To repeat that step after rerendering, use Node.js from the extracted folder:

```text
node finalize_html.cjs week03_lab.html
```

No Node.js installation is needed merely to read the supplied HTML or run the R calculations.

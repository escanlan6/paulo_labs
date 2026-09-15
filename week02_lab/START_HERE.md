# Week 2 laboratory

Extract the whole ZIP into a writable folder before opening its files.

1. Open **week02_lab.html** in a browser to read the tasks.
2. Open **week02_lab.qmd** in RStudio to complete the worksheet. This is the
   editable source. Run the setup chunk, then add code and interpretations.
3. Keep **week02_r_reference.html** alongside it for examples and assumptions.
4. Select **Render** in RStudio to update the HTML with your results.

This is a two-hour formative lab. Nothing is submitted for marks. AI tools
are allowed: request small pieces of code, explain them, check them, and write
your own interpretation.

## Requirements

To read the supplied HTML, you only need a browser. The delivered HTML works
offline, including equations.

To execute the worksheet, use R 4.1 or later, RStudio and Quarto. Install the
following R packages once if they are missing:

```r
install.packages(c("dplyr", "tidyr", "readr", "ggplot2",
                   "scales", "knitr", "rmarkdown"))
```

Package installation requires internet access; the calculations use the
included frozen data and need no network connection.

## What is included

- `week02_lab.qmd` and `.html`: editable worksheet and reading copy.
- `week02_r_reference.qmd` and `.html`: function reference.
- `week02_lab_helpers.R`: readable functions for tests and jump scenarios.
- `data/`: daily, weekly and monthly EUR returns and their provenance.
- `DATA_DICTIONARY.md`: columns, conventions and portfolio definition.
- `lab.css`: document style.
- `finalize_html.cjs` and `vendor/katex/`: optional offline-math bundler.

Keep the files together. Do not convert gold again: it is already in EUR.
Use the existing data; do not refresh market prices.

## Rendering and offline equations

An ordinary Quarto render creates an HTML whose equations use an online
KaTeX library. To make your newly rendered HTML fully offline, use Node.js
and run this from the extracted folder after rendering:

```text
node finalize_html.cjs week02_lab.html
```

The supplied HTML has already had this step applied. No Node.js installation
is needed just to read it or to run the R calculations.

If setup cannot find the data, confirm that you extracted the entire ZIP
and opened the worksheet from the extracted `week02_lab` folder.

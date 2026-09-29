# Week 4 laboratory

Extract the entire ZIP into a writable folder before opening its files.

1. Open **week04_lab.html** in a browser to read the tasks.
2. Open **week04_lab.qmd** in RStudio to add your code and interpretations.
3. Keep **week04_r_reference.html** open for syntax and mathematical checks.
4. Run the setup chunk, complete the tasks, then select **Render** to retain your results.

This is a two-hour formative lab. Nothing is submitted for marks. The local data cover every calculation; no live download is required.

## Requirements

The supplied HTML works offline in a browser. To execute and render the worksheet, use R 4.1 or later, RStudio and Quarto. Install these R packages once if needed:

```r
install.packages(c("dplyr", "readr", "ggplot2", "knitr", "rmarkdown"))
```

Package installation needs internet access. The lab itself does not.

## Included files

- `week04_lab.qmd` and `.html`: editable worksheet and reading copy.
- `week04_r_reference.qmd` and `.html`: R syntax and method notes.
- `data/`: the frozen monthly panel and its provenance records.
- `DATA_DICTIONARY.md`: columns, units, sources and date rules.
- `lab.css`: document style.
- `finalize_html.cjs` and `vendor/katex/`: optional offline equation bundler after rerendering.
- `SHA256SUMS.txt`: packaged-file hashes.

Keep the folder structure intact. The instructor solution and assessment result files are not in this ZIP.

## Offline equations after rerendering

An ordinary Quarto render may refer to an online KaTeX library. The distributed HTML has already been made offline. To repeat that step after rerendering, use Node.js from the extracted folder:

```text
node finalize_html.cjs week04_lab.html
```

Node.js is not needed merely to read the supplied HTML or run the R calculations.

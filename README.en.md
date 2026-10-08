# set-template

[Deutsch](README.md) · **English**

![Quarto Extension](https://img.shields.io/badge/quarto-extension-blue)
![Format: Typst](https://img.shields.io/badge/format-typst-239dad)
[![License: MIT](https://img.shields.io/badge/license-MIT-yellow.svg)](LICENSE)

Quarto template for personalised evaluation reports as PDF, e.g. from course evaluations or
student and graduate surveys. The analysis is done by the R package
[setanalysis](https://github.com/donvollb/setanalysis): one line of code per question produces a
heading, a table and a plot. This template provides the layout (Typst) and two working example
reports based on randomly generated example data.

The reports themselves are in German; the template can be adapted to other languages via `lang`
and the texts in the `.qmd` files.

![Preview of the course evaluation example](vorschau/lve-bericht.png)

## Features

- **Typst format** with header (logo), footer, page numbers and table of contents
- **One accent colour** (`accent_col`) for rules, links, logo, highlights and the setanalysis plots
- **Many reports from one file:** parameter `i` selects the report; setanalysis' inclusion logic
  decides which questions appear in which report
- **Long tables break across pages** (with repeated header); headings move to the next page together with their content
- **Open-ended answers in an appendix** with links back and forth

## Requirements

- [Quarto](https://quarto.org) ≥ 1.7 (includes Typst)
- [R](https://www.r-project.org) with the package **setanalysis** (currently the development version):

  ```r
  # install.packages("pak")
  pak::pak("donvollb/setanalysis@dev")
  ```

- Font **Red Hat Text** ([Google Fonts](https://fonts.google.com/specimen/Red+Hat+Text)).
  setanalysis ships the font for its plots; for the PDF text it has to be installed.
  Install the files from the *static* subfolder. On Windows you may need to choose
  *Install for all users* (select all *.ttf* files → right-click) so that Typst finds them.

## Installation

Create a new project with the template and examples:

```bash
quarto use template donvollb/set-template
```

Quarto asks for a directory name and renames `template.qmd` after it.
To add only the format to an existing project:

```bash
quarto add donvollb/set-template
```

## Usage

```bash
quarto render template.qmd           # report 1 (parameter i from the YAML header)
quarto render template.qmd -P i:3    # report 3
quarto render                        # all examples
```

Rendered examples: [course evaluation](vorschau/lve-bericht.pdf) ·
[cohort survey: master report](vorschau/kohorte-master.pdf) ·
[cohort survey: report "Sonderauswertung"](vorschau/kohorte-sonderauswertung.pdf)

## Structure

```
├── _extensions/set-template/   format "set-template-typst"
│   ├── _extension.yml          defaults (margins, font, colour, logo …)
│   ├── typst-template.typ      layout: header, footer, title, tables, headings
│   ├── typst-show.typ          passes the YAML header to the layout
│   ├── chunk-ausgabe.lua       allows page breaks inside R chunks
│   └── images/                 logos
├── template.qmd                example 1: course evaluation report per department
├── beispiele/kohorte.qmd       example 2: many reports via a report table and a rule table
├── daten/                      fictitious example data, report table and rule table
│   └── beispieldaten_erzeugen.R  generates the data (random, reproducible)
└── vorschau/                   rendered example PDFs and preview images
```

### Example 1: course evaluation (`template.qmd`)

One report per department: `params$i` selects the row of the info table and the data are filtered
accordingly. Contains response rate, semester of study, core questions (aggregated per course),
overall grade, workload and legends.

### Example 2: many reports with different content (`beispiele/kohorte.qmd`)

For surveys where each report (e.g. per degree programme) contains different questions:

1. The **report table** has one row per report (code, degree, programme, title …).
2. The **rule table** defines for each question when it is shown, e.g. `inkl.1.3` →
   `Abschluss == "Bachelor of Science (B.Sc.)"`.
3. `input_tabelle()` computes `TRUE`/`FALSE` per report and question. The template sets these
   values as variables; `merge_sc(…, nr = "1.3")` then checks `inkl.1.3`, and whole sections are
   shown or hidden with `eval: !expr header1`.

Both tables are included as `daten/kohorte_berichte.xlsx` and `daten/kohorte_regeln.xlsx`.

### Example data

All data in `daten/` are randomly generated; departments and degree programmes are made up and
open-ended answers are Lorem ipsum. The variables carry the same attributes as data read with
`evasys_read_data()` (question text, number, type, answer codes). Regenerate them with
`Rscript beispieldaten_erzeugen.R` inside `daten/` (additionally requires the writexl package).

![Preview of the cohort example](vorschau/kohorte.png)

## Customising

### YAML header fields

| Field         | Meaning                                                | Default                           |
|---------------|--------------------------------------------------------|-----------------------------------|
| `title`, `subtitle` | title on the first page (`subtitle` can be set per report from R, see examples) | – |
| `lfoot`       | text on the left of the footer                         | empty                             |
| `accent_col`  | accent colour for layout and plots                     | `"#507289"`                       |
| `header-logo` | logo on the right of the header (SVG)                  | `images/Logo Meze - Cobranding.svg` |
| `toc`, `toc-title`, `toc-depth` | table of contents                    | `true`, `INHALTSVERZEICHNIS`, `1` |
| `margin`, `fontsize`, `mainfont` | margins and font                    | 2/3/2 cm, `10pt`, `Red Hat Text`  |
| `params: i`   | which report to render                                 | `1`                               |

The colour `#006a6a` in the logo is replaced by the accent colour. Use
`header-logo: path/to/logo.svg` (relative to the document) for a different logo.

RPTU colours for `accent_col`:

| Colour               | Code      | Colour               | Code      |
|----------------------|-----------|----------------------|-----------|
| Slate (blue-grey)    | `#507289` | Petrol (dark green)  | `#006b6b` |
| Ocean (green-grey)   | `#77b6ba` | Apple (light green)  | `#26d07c` |
| Night (dark blue)    | `#042c58` | Plum (violet)        | `#4c3575` |
| Day (light blue)     | `#6ab2e7` | Fuchsia (pink)       | `#d13896` |
| Raspberry (red)      | `#e31b4c` | Mango (orange)       | `#ffa252` |

### Building blocks

- setanalysis functions in R chunks, e.g. `merge_sc()`, `merge_mc()`, `merge_sk()`,
  `merge_aggr_sk()`, `merge_open()`; overview with `?setanalysis`.
- `appendix_open()` belongs at the end of every report (prints the collected open-ended answers).
- Page break: `{{< pagebreak >}}` in text or inside a chunk.
- Typst helpers of the template: `#begriff[…]` (term highlighted in the accent colour),
  `#hinweis[…]` (small note), each inside a ```` ```{=typst} ```` block.

## Planned

- Example script that renders and logs all reports of a survey in one go

## License

**Code:** [MIT License](LICENSE)

**Logos:** property of [RPTU (University of Kaiserslautern-Landau)](https://rptu.de)

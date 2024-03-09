---
render_macros: false
---

# Anoma Research Topics LaTex Template

This is a template for writing Anoma Research Topics, a.k.a ARTs in LaTeX.

## Using the template

To begin, clone the repository:

`git clone https://github.com/anoma/art-template`

You may remove the `examples/` directory:

`git rm -rf examples`

The document is defined in the `main.tex` file.
Update the class options at the top, if necessary.

You may include here further `.tex`, '`.md.tex` and `.org.tex` files
using `\input` statements.

The `.md.tex` and `.org.tex` files are generated using pandoc
from their `.md` and `.org` counterparts.
When including pandoc-generated files,
make sure to also include `templates/pandoc.tex`.

### Class options

- paper size: `a4paper` or `letterpaper` (must be present)
- add line numbers: `lineno` (optional)
- document type:
  - `article`: Article (default)
  - `techreport`: Technical Report
  - `report`: Report
  - `commun`: Communication
  - `persp`: Perspective
  - `review`: Review

### Tables & figures

Tables and figures may be wider than `\textwidth`, and should be centered.
For this reason, add a `\centerline{}`
around the `\begin{tabular}...\end{tabular}`
and `\includegraphics{...}` statements.

For full-width figures set the width to `1.3\textwidth`:

```latex
\centerline{\includegraphics[width=1.3\textwidth]{filename}}
```

### References

The references are stored in the `ref.bib` file. We have included a few
references as of other ARTs and related papers. Feel free to add your own
references.

## Updating the template

To update to the latest version of the LaTeX template
in an already existing repository using the template,
run the following:

```
make update-template
```

If you're updating from an old version of the template
that does not have a Makefile yet, run the following instead:

```
curl -O https://raw.githubusercontent.com/anoma/art-template/main/Makefile
make update-template-old
```

In addition to updating the template,
this will also apply fixes to the `*.tex` files in the repository using `bin/fix.sh`:
- add paper size and remove font size class options
- center tables

## LaTeX fixes

`bin/fix.sh` offers automatic fixes for common issues in LaTeX source files.
To see the available options, run it without arguments.

## Building

LaTeXMk and XeLaTeX are necessary to build the PDF.

To build the PDF file:

```
make
```

Fonts are rendered best with the XeLaTeX engine, however,
if you don't have it installed, you may use other engines:

`make luatex`

or

`make pdflatex`


This will generate `.md.tex` and `.org.tex` files using pandoc,
and an `main.pdf` file in the `output/` directory.


To continously rebuild `main.pdf` when a source file changes, run:

```
make watch
```

Then open the PDF file with a viewer that reloads the file on change.

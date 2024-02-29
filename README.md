---
render_macros: false
---

# Anoma Research Topics LaTex Template

This is a template for writing Anoma Research Topics, a.k.a ARTs in LaTeX.

## Latex template

To begin, clone the repository and modify the `main.tex` file.
You may include `md.tex` and `.org.tex` files
which are generated using pandoc from their `.md` and `.org` counterparts.

Once done, build the PDF file:

```
make
```

This will generate `.md.tex` and `.org.tex` files using pandoc,
and a `main.pdf` file using LaTeXMk and XeLaTeX.

Fonts are rendered best with the XeLaTeX engine.
In case you don't have XeLaTeX or LaTeXMk installed,
you may change the `MKPDF` variable defined in the `Makefile`.

To continously rebuild `main.pdf` when a source file changes, run:

```
make watch
```

Then open the PDF file with a viewer that reloads the file on change.

## Org template

It is recommended to build `.org` files using pandoc as described above.
Here is an alternative build process using emacs.

The org template file is `main-org.org`,
In order to export the org file to latex properly,
you will need to include the following code into your emacs configuration:

<pre>
(with-eval-after-load 'ox-latex
    (add-to-list 'org-latex-classes
                '("art" "\\documentclass[11pt]{art}"
                ("\\section{%s}" . "\\section*{%s}")
                ("\\subsection{%s}" . "\\subsection*{%s}")
                ("\\subsubsection{%s}" . "\\subsubsection*{%s}")
                ("\\paragraph{%s}" . "\\paragraph*{%s}")
                ("\\subparagraph{%s}" . "\\subparagraph*{%s}"))))

(setq org-latex-default-packages-alist nil)
(setq org-latex-with-hyperref nil)
</pre>

## References

The references are stored in the `ref.bib` file. We have included a few
references as of other ARTs and related papers. Feel free to add your own
references.

# Anoma Research Topics LaTex Template

This is a template for writing Anoma Research Topics, a.k.a ARTs in LaTeX.

## Latex template

To begin, clone the repository and modify the `main.tex` file.

Once done, compile the LaTeX file using LaTeXMk in your terminal. Depending on
whether you're using XeLatex or pdflatex, run the corresponding command:

**For XeLatex:**
```bash
latexmk -pdf -shell-espace -xelatex main.tex
```

**For pdflatex:**
```bash
latexmk -pdf -shell-espace main.tex
```
This will generate a PDF version of your `.tex` file.

## Org template
The org template file is `main-org.org`. In order to export the org file to
latex properly, you will need to include the following code into your emacs
configuration:

```elisp
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
```

## References

The references are stored in the `ref.bib` file. We have included a few
references as of other ARTs and related papers. Feel free to add your own
references.
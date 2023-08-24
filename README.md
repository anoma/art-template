# Anoma Research Topics LaTex Template

This is a template for writing Anoma research topics in LaTeX.

## Latex template
The latex template file is `main.tex`.

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

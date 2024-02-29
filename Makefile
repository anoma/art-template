TEX := $(shell git ls-files | grep '\.tex$$')
CLS := $(shell git ls-files | grep '\.cls$$')
STY := $(shell git ls-files | grep '\.sty$$')
MD := $(shell git ls-files | grep '\.md$$' | grep -v README)
ORG := $(shell git ls-files | grep '\.org$$')

MD_TEX := $(patsubst %.md,%.md.tex,$(MD))
ORG_TEX := $(patsubst %.org,%.org.tex,$(ORG))

OUT ?= output

LATEXMK ?= latexmk
LATEXMK_TEXENGINE ?= xelatex
LATEXMK_OPTS ?= -pdf -shell-escape -$(LATEXMK_TEXENGINE) -output-directory=$(OUT)

MKPDF ?= $(LATEXMK) $(LATEXMK_OPTS)

.PHONY: xelatex
xelatex: LATEXMK_TEXENGINE:=xelatex
xelatex: main.pdf

.PHONY: lualatex
lualatex: LATEXMK_TEXENGINE:=lualatex
lualatex: main.pdf

.PHONY: pdflatex
pdflatex: LATEXMK_TEXENGINE:=pdflatex
pdflatex: main.pdf
	@echo "We recommend using xelatex or lualatex instead of pdflatex."

all: pdf

pdf: xelatex

watch: main.pdf
	while inotifywait -qe modify $(TEX) $(CLS) $(STY) $(MD) $(ORG); do make main.pdf; done

main.pdf: main.tex $(TEX) $(CLS) $(STY) $(MD_TEX) $(ORG_TEX)
	$(MKPDF) $(MKPDF_OPTS) $<

%.md.tex: %.md
	pandoc \
		--from=markdown	\
		--to=latex \
		--biblatex \
		$(if $(shell test -e defaults.yaml && echo 1),--defaults=defaults.yaml,) \
		-o $(patsubst %.md,%.md.tex,$<) \
		$<

%.org.tex: %.org
	pandoc \
		--from=org+citations \
		--to=latex \
		--biblatex \
		$(if $(shell test -e defaults.yaml && echo 1),--defaults=defaults.yaml,) \
		-o $(patsubst %.org,%.org.tex,$<) \
		$<

clean-pandoc:
	rm -f $(MD_TEX) $(ORG_TEX)

clean-latex:
	rm -f $(OUT)/main.{blg,bbl,brf,aux,out,fls,xdv,toc,log,fdb_latexmk}

clean: clean-pandoc clean-latex

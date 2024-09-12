TEX := $(shell git ls-files | grep '\.tex$$')
CLS := $(shell git ls-files | grep '\.cls$$')
STY := $(shell git ls-files | grep '\.sty$$')
MD := $(shell git ls-files | grep '\.md$$' | grep -v README)
ORG := $(shell git ls-files | grep '\.org$$')

MD_TEX := $(patsubst %.md,%.md.tex,$(MD))
ORG_TEX := $(patsubst %.org,%.org.tex,$(ORG))

SED ?= $(shell which gsed 2>/dev/null || which sed)
TAR ?= $(shell which gtar 2>/dev/null || which tar)

OUT ?= .

LATEXMK ?= latexmk
LATEXMK_TEXENGINE ?= xelatex
LATEXMK_OPTS ?= -pdf -$(LATEXMK_TEXENGINE)

MKPDF ?= $(LATEXMK) $(LATEXMK_OPTS)

all: pdf

pdf: xelatex

.PHONY: xelatex
xelatex: LATEXMK_TEXENGINE:=xelatex
xelatex: main

.PHONY: lualatex
lualatex: LATEXMK_TEXENGINE:=lualatex
lualatex: main

.PHONY: pdflatex
pdflatex: LATEXMK_TEXENGINE:=pdflatex
pdflatex: main
	@echo "WARNING: pdfTeX is not supported, only for local preview purposes."
	@echo "         It produces slightly different output than XeTeX, which is used for publishing."

watch: main
	if which inotifywait 2>/dev/null; then \
	  while inotifywait -qe modify $(TEX) $(CLS) $(STY) $(MD) $(ORG); do echo make main; done; \
	else if which fswatch 2>/dev/null; then \
	  fswatch $(TEX) $(CLS) $(STY) $(MD) $(ORG) | (while read; do echo make main; done); \
	fi; else
	  @echo "ERROR: Missing inotifywait (Linux) or fswatch (Mac)."
	fi

main: $(OUT)/main.pdf

$(OUT)/main.pdf: main.tex $(TEX) $(CLS) $(STY) $(MD_TEX) $(ORG_TEX)
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
	rm -f $(OUT)/main.{blg,bbl,brf,aux,out,fls,xdv,toc,log,fdb_latexmk,synctex,synctex.gz}

clean-pdf:
	rm -f $(OUT)/main.pdf

clean: clean-pandoc clean-latex clean-pdf

update-bib:
	curl -fLO https://art.anoma.net/art.bib

update-template:
	curl -fsL https://github.com/anoma/art-template/tarball/main \
		| gunzip -c | $(TAR) xv --strip-components=1 \
		--wildcards '*/.gitignore' '*/Makefile' '*/latexmkrc' '*/art.bib' '*/templates' '*/bin'
	git add -f .gitignore Makefile latexmkrc art.bib templates bin

update-template-old: update-template
	bin/fix.sh opts-paper-font main.tex
	bin/fix.sh tabular-center $(TEX)
	test -f art.cls && git rm -f art.cls || true

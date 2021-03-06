# Makefile for UCASThesis
# $Id$

include config.mk

ifeq ($(MAKE),)
    override MAKE = make
endif

ifeq ($(TEXI2DVI),)
    override TEXI2DVI = texi2dvi
endif

PACKAGE=ucasthesis
SOURCES=$(PACKAGE).ins $(PACKAGE).dtx 
THESISCONTENTS=$(THESISMAIN).tex data/*.tex $(EPS) $(EPSGEN)
EPS=$(wildcard figures/*.eps)
EPSGEN=
# xelatex can directly use jpg file
ifneq ($(METHOD),xelatex)
EPSGEN+=$(addsuffix .eps,$(basename $(wildcard figures/*.jpg)))
endif
EPSGEN+=$(addsuffix .eps,$(basename $(wildcard figures/*.fig)))
BIBFILE=ref/*.bib
SPINECONTENTS=$(SPINEMAIN).tex
CLSFILES=dtx-style.sty $(PACKAGE).cls $(PACKAGE).cfg

.PHONY: all clean thesis spine doc cls default

default: thesis
all: doc thesis spine

###### generate cls/cfg
cls: $(CLSFILES)

$(CLSFILES): $(SOURCES)
	latex $(PACKAGE).ins

###### for doc

doc: $(PACKAGE).pdf

ifeq ($(METHOD),xelatex)

$(PACKAGE).pdf: $(CLSFILES)
	xelatex $(PACKAGE).dtx
	makeindex -s gind.ist -o $(PACKAGE).ind $(PACKAGE).idx
	makeindex -s gglo.ist -o $(PACKAGE).gls $(PACKAGE).glo
	xelatex $(PACKAGE).dtx
	xelatex $(PACKAGE).dtx

else ifeq ($(METHOD),pdflatex)

$(PACKAGE).pdf: $(CLSFILES)
	pdflatex $(PACKAGE).dtx
	makeindex -s gind.ist -o $(PACKAGE).ind $(PACKAGE).idx
	makeindex -s gglo.ist -o $(PACKAGE).gls $(PACKAGE).glo
	pdflatex $(PACKAGE).dtx
	pdflatex $(PACKAGE).dtx

else

$(PACKAGE).dvi: $(CLSFILES)
	latex $(PACKAGE).dtx
	makeindex -s gind.ist -o $(PACKAGE).ind $(PACKAGE).idx
	makeindex -s gglo.ist -o $(PACKAGE).gls $(PACKAGE).glo
	latex $(PACKAGE).dtx
	latex $(PACKAGE).dtx

$(PACKAGE).pdf: $(PACKAGE).dvi
	latex $(PACKAGE).dtx
	dvipdfmx  $(PACKAGE).dvi

endif

###### for thesis

thesis: $(THESISMAIN).pdf

ifeq ($(METHOD),xelatex)

$(THESISMAIN).pdf: $(CLSFILES) $(THESISCONTENTS) $(THESISMAIN).bbl
	xelatex $(THESISMAIN).tex
	xelatex $(THESISMAIN).tex

$(THESISMAIN).bbl: $(BIBFILE)
	xelatex $(THESISMAIN).tex
	-bibtex $(THESISMAIN)
	rm $(THESISMAIN).pdf

else ifeq ($(METHOD),pdflatex)

$(THESISMAIN).pdf: $(CLSFILES) $(THESISCONTENTS) $(THESISMAIN).bbl
	pdflatex $(THESISMAIN).tex
	pdflatex $(THESISMAIN).tex

$(THESISMAIN).bbl: $(BIBFILE)
	pdflatex $(THESISMAIN).tex
	-bibtex $(THESISMAIN)
	rm $(THESISMAIN).pdf

else

$(THESISMAIN).pdf: $(THESISMAIN).dvi
	latex $(THESISMAIN).tex
	dvipdfmx $(THESISMAIN).dvi

$(THESISMAIN).dvi: $(CLSFILES) $(THESISCONTENTS) $(THESISMAIN).bbl
	$(TEXI2DVI) $(THESISMAIN).tex

$(THESISMAIN).bbl: $(BIBFILE)
	$(TEXI2DVI) $(THESISMAIN).tex
	-bibtex $(THESISMAIN)

endif


figures/%.eps: figures/%.jpg
	convert $^ -compress none eps2:$@
figures/%.eps: figures/%.fig
	fig2dev -L eps $^ $@

###### for spine
spine: $(SPINEMAIN).pdf

ifeq ($(METHOD),xelatex)

$(SPINEMAIN).pdf: $(CLSFILES) $(SPINECONTENTS)
	xelatex $(SPINEMAIN).tex

else ifeq ($(METHOD),pdflatex)

$(SPINEMAIN).pdf: $(CLSFILES) $(SPINECONTENTS)
	pdflatex $(SPINEMAIN).tex

else

$(SPINEMAIN).dvi: $(CLSFILES) $(SPINECONTENTS)
	$(TEXI2DVI) $(SPINEMAIN).tex

$(SPINEMAIN).pdf: $(SPINEMAIN).dvi
	latex $(SPINEMAIN).tex
	dvipdfmx $(SPINEMAIN).dvi

endif

clean: 
	rm -f *.aux *.bbl *.blg *.glo *.gls *.idx *.ilg *.ind *.log \
		*.out *.thm *.toc *.lof *.lot data/*.aux $(EPSGEN) \
		dtx-style.sty *.cls *.cfg \
		main.pdf spine.pdf ucasthesis.pdf

# Copyright (C) 2013 Massimiliano Dominici
# Makefile for package 'dramatist'

BUILDDIR	=tmp/
TDSDIR		=tds
PACKAGE		=dramatist
SOURCE		=$(PACKAGE).dtx
STYLES		=$(PACKAGE).sty $(PACKAGE)-1.2d.sty *.dst 
GENERATED	=$(PACKAGE).ins README.txt $(STYLES)
DOC		=$(PACKAGE).pdf
ALL		=$(GENERATED) README $(DOC)

help :
	echo ""
	echo " make pkg. . . . . . . . . . . generate style files and README"
	echo " make doc. . . . . . . . . . . generate documentation"
	echo " make all. . . . . . . . . . . generate style files and documentation"
	echo " make ctan . . . . . . . . . . generate zip archive for CTAN"
	echo " make localinstall . . . . . . install package in a texmf-tree inside the source directory"
	echo " make clean. . . . . . . . . . remove build directory"
	echo " make clean-localinstall . . . remove texmf-tree"
	echo ""

$(addprefix $(BUILDDIR), $(GENERATED)) : $(addprefix $(BUILDDIR), $(SOURCE))
	cd $(BUILDDIR)	&& tex $(SOURCE) 

$(addprefix $(BUILDDIR), README) : $(addprefix $(BUILDDIR),  README.txt)
	cd $(BUILDDIR) && cp README.txt README 

$(addprefix $(BUILDDIR), $(SOURCE)) : $(SOURCE)
	mkdir -p $(BUILDDIR)
	cd $(BUILDDIR)	&& cp ../$< .

$(addprefix $(BUILDDIR), $(DOC)) : $(addprefix $(BUILDDIR), $(SOURCE))
	cd $(BUILDDIR)	&& latexmk -r ../latexmkrc -pdf $(SOURCE)

$(addprefix $(BUILDDIR), $(addsuffix .zip, $(PACKAGE))) : $(addprefix $(BUILDDIR), $(ALL))
	cd $(BUILDDIR) && mkdir -p $(PACKAGE) && \
	cp -a $(ALL) $(PACKAGE) && zip -9v $(addsuffix .zip, $(PACKAGE)) $(PACKAGE)/*
	rm -fR $(PACKAGE)

pkg : $(addprefix $(BUILDDIR), $(GENERATED)) $(addprefix $(BUILDDIR), README)

doc : $(addprefix $(BUILDDIR), $(DOC))

all : $(addprefix $(BUILDDIR), $(ALL))

ctan : $(addprefix $(BUILDDIR), $(addsuffix .zip, $(PACKAGE)))

localinstall: all
	mkdir -p $(TDSDIR)/{doc,source,tex}/latex/dramatist
	cp $(addprefix $(BUILDDIR), $(DOC)) $(TDSDIR)/doc/latex/dramatist/
	cp $(addprefix $(BUILDDIR), $(SOURCE)) $(TDSDIR)/source/latex/dramatist/
	cp $(addprefix $(BUILDDIR), $(STYLES)) $(TDSDIR)/tex/latex/dramatist/
	texhash $(TDSDIR)/

clean:
	rm -fR $(BUILDDIR)

clean-localinstall: clean
	rm -fR $(TDSDIR)

.PHONY : pkg doc all ctan localinstall clean clean-localinstall

.SILENT : help

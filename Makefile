BUILDDIR=tmp/
PACKAGE=dramatist
SOURCE=$(PACKAGE).dtx
STYLES=$(PACKAGE).sty centered.dst classic.dst modern.dst $(PACKAGE)-1.2d.sty
GENERATED=$(PACKAGE).ins README.txt $(STYLES)
DOC=$(PACKAGE).pdf
ALL=$(GENERATED) README $(DOC)

.PHONY : clean ctan doc localinstall all

$(addprefix $(BUILDDIR), $(GENERATED)) : $(addprefix $(BUILDDIR), $(SOURCE))
	cd $(BUILDDIR)	&& tex $(SOURCE) 

$(addprefix $(BUILDDIR), README) : $(addprefix $(BUILDDIR),  README.txt)
	cd $(BUILDDIR) && cp README.txt README

$(addprefix $(BUILDDIR), $(SOURCE)) : $(SOURCE)
	mkdir -p $(BUILDDIR)
	cd $(BUILDDIR)	&& cp ../$< .

all : $(addprefix $(BUILDDIR), $(ALL))

doc : $(addprefix $(BUILDDIR), $(DOC))

$(addprefix $(BUILDDIR), $(DOC)) : $(addprefix $(BUILDDIR), $(SOURCE))
	cd $(BUILDDIR)	&& pdflatex $(SOURCE) && \
	pdflatex $(SOURCE) && pdflatex $(SOURCE)

ctan : $(addprefix $(BUILDDIR), $(addsuffix .zip, $(PACKAGE)))

$(addprefix $(BUILDDIR), $(addsuffix .zip, $(PACKAGE))) : $(addprefix $(BUILDDIR), $(ALL))
	cd $(BUILDDIR) && mkdir -p $(PACKAGE) && \
	cp -a $(ALL) $(PACKAGE) && zip -9v $(addsuffix .zip, $(PACKAGE)) $(PACKAGE)/*
	rm -fR $(PACKAGE)

localinstall: all
	mkdir -p tds/{doc,source,tex}/latex/dramatist
	cp $(addprefix $(BUILDDIR), $(DOC)) tds/doc/latex/dramatist/
	cp $(addprefix $(BUILDDIR), $(SOURCE)) tds/source/latex/dramatist/
	cp $(addprefix $(BUILDDIR), $(STYLES)) tds/tex/latex/dramatist/
	texhash tds/

clean:
	rm -fR $(BUILDDIR)

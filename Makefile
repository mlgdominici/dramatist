BUILDDIR=tmp/
PACKAGE=dramatist
SOURCE=$(PACKAGE).dtx
STYLES=$(PACKAGE).sty centered.dst classic.dst modern.dst
GENERATED=$(PACKAGE).ins README $(STYLES)
DOC=$(PACKAGE).pdf
ALL=$(GENERATED) $(DOC)

COMMITDATE=`git log -1 --date=short --pretty=format:"%ad" HEAD | tr - /`
VERSION=`git describe --tags | awk '{split($$0,a,"-"); print a[1] "." a[2]}'`
REVISION=`git describe --tags | awk '{split($$0,a,"-"); print a[3]}' | tail -c +2`

.PHONY : clean ctan doc localinstall

$(addprefix $(BUILDDIR), $(GENERATED)) : $(addprefix $(BUILDDIR), $(SOURCE))
	cd $(BUILDDIR)	&& tex $(SOURCE) 

$(addprefix $(BUILDDIR), $(SOURCE)) : $(SOURCE)
	mkdir -p $(BUILDDIR)
	cd $(BUILDDIR)	&& cp ../$< . && \
	sed -i "s_£Id£_$(COMMITDATE) $(VERSION) Revision: $(REVISION)_g" $< 

doc : $(addprefix $(BUILDDIR), $(DOC))

$(addprefix $(BUILDDIR), $(DOC)) : $(addprefix $(BUILDDIR), $(SOURCE))
	cd $(BUILDDIR)	&& pdflatex $(SOURCE) && \
	pdflatex $(SOURCE) && pdflatex $(SOURCE)

ctan : $(addprefix $(BUILDDIR), $(addsuffix .zip, $(PACKAGE)))

$(addprefix $(BUILDDIR), $(addsuffix .zip, $(PACKAGE))) : $(addprefix $(BUILDDIR), $(ALL))
	cd $(BUILDDIR) && mv README.txt README && mkdir -p $(PACKAGE) && \
	cp -a $(ALL) $(PACKAGE) && zip -9v $(addsuffix .zip, $(PACKAGE)) $(PACKAGE)/*
	rm -fR $(PACKAGE)

localinstall: $(addprefix $(BUILDDIR), $(ALL))
	mkdir -p tds/{doc,source,tex}/latex/dramatist
	cp $(addprefix $(BUILDDIR), $(DOC)) tds/doc/latex/dramatist/
	cp $(addprefix $(BUILDDIR), $(SOURCE)) tds/source/latex/dramatist/
	cp $(addprefix $(BUILDDIR), $(STYLES)) tds/tex/latex/dramatist/
	texhash tds/

clean:
	rm -fR $(BUILDDIR)

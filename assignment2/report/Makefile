LATEX = pdflatex
LATEXOPTS = -interaction=nonstopmode -halt-on-error -shell-escape
DOC = report

all: once.a

once.%: 
	$(LATEX) $(LATEXOPTS) $(DOC)

$(DOC).aux: once.a

clean:
	rm -f $(DOC).{aux,log,out,toc,lof,lot,lom}
remove: clean
	rm -f $(DOC).pdf

release: remove once.a once.b once.c


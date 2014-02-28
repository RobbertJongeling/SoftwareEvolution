LATEX = pdflatex
LATEXOPTS = -interaction=nonstopmode -halt-on-error -shell-escape
DOC = report

all: once.a

sections/results/%.pdf: sections/results/%.dot
	dot -Tpdf -o $@ $<

clean_classdiagrams:
	rm -f sections/results/*.pdf

once.%: sections/results/eLib.pdf sections/results/neko-0.9.pdf sections/results/neko-1.9.pdf
	$(LATEX) $(LATEXOPTS) $(DOC)

$(DOC).aux: once.a

clean: clean_classdiagrams
	rm -f $(DOC).{aux,log,out,toc,lof,lot,lom}
remove: clean
	rm -f $(DOC).pdf

release: remove once.a once.b once.c


TEXMF ?= /usr/local/texlive/texmf-local

example: install
	pdflatex -interaction=nonstopmode "\input" example.tex
install: copy
	texhash
copy:
	mkdir -p $(TEXMF)/tex/latex/base/
	cp yacv.cls $(TEXMF)/tex/latex/base/
	$(foreach module, $(wildcard modules/*), cp -r $(module) $(TEXMF)/tex/latex/;)
doc:
	$(info not written)
ctan:
	$(info not implemented)

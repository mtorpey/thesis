thesis:
	pdflatex --shell-escape thesis.tex
	bibtex thesis
	makeindex thesis
	makeindex thesis.nlo -s nomencl.ist -o thesis.nls

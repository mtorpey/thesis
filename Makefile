thesis:
	pdflatex --shell-escape thesis.tex
	bibtex thesis
	makeindex thesis

quick:
	pdflatex --shell-escape thesis.tex
	bibtex thesis
	sed -i 's/O, E, I, and S./N.~J.~A. Sloane et~al./g' thesis.bbl
	makeindex thesis
	makeindex thesis.nlo -s nomencl.ist -o thesis.nls

full:
	make quick
	make quick
	make quick
	make quick

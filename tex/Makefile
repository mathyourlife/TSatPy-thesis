TEX := pdflatex -shell-escape -interaction=nonstopmode -file-line-error
# PRE :=  $(TEX) -ini -job-name="preamble" "&pdflatex preamble.tex\dump"
# BIB := bibtex
VIEW := evince

view:
	$(VIEW) CoutureThesis.pdf &

thesis:
	$(TEX) CoutureThesis.tex
	makeindex CoutureThesis.nlo -s nomencl.ist -o CoutureThesis.nls
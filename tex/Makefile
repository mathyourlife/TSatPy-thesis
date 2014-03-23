DIR := $(shell pwd)
VIEW := evince
TEX := latex -shell-escape
BIB := bibtex

view:
	$(VIEW) CoutureThesis.pdf &

thesis:
	$(TEX) CoutureThesis.tex
	$(BIB) CoutureThesis
	$(TEX) CoutureThesis.tex
	dvips CoutureThesis.dvi
	ps2pdf CoutureThesis.ps CoutureThesis.pdf

pdf-pieces:
	mkdir -p $(DIR)/tmp
	rm -f $(DIR)/tmp/*
	pdftk $(DIR)/CoutureThesis.pdf burst output $(DIR)/tmp/CoutureThesis_%02d.pdf

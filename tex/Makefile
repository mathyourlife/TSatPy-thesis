DIR := $(shell pwd)
TEX := latex
# PRE :=  $(TEX) -ini -job-name="preamble" "&pdflatex preamble.tex\dump"
# BIB := bibtex
VIEW := evince


view:
	$(VIEW) CoutureThesis.ps &

thesis:
	$(TEX) CoutureThesis.tex
	dvips CoutureThesis.dvi

pdf:
	ps2pdf CoutureThesis.ps CoutureThesis.pdf

pdf-pieces:
	mkdir -p $(DIR)/tmp
	rm -f $(DIR)/tmp/*
	pdftk $(DIR)/CoutureThesis.pdf burst output $(DIR)/tmp/CoutureThesis_%02d.pdf
DIR := $(shell pwd)
VIEW := evince
TEX := latex -shell-escape
BIB := bibtex
PAPER1 := GNC2015-CoutureDecomposeQuaternion
PAPER2 := GNC2015-CoutureQuaternionError
PAPER3 := GNC2015-CoutureQuaternionToMoment

papers:
	$(TEX) $(PAPER1).tex
	$(TEX) $(PAPER2).tex
	$(TEX) $(PAPER3).tex
	dvips $(PAPER1).dvi
	dvips $(PAPER2).dvi
	dvips $(PAPER3).dvi
	ps2pdf $(PAPER1).ps $(PAPER1).pdf
	ps2pdf $(PAPER2).ps $(PAPER2).pdf
	ps2pdf $(PAPER3).ps $(PAPER3).pdf

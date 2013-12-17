
DIR := $(shell pwd)

test:
	nosetests --nocapture --with-coverage --cover-erase --cover-package=TSatPy --cover-html --cover-html-dir=coverage_report

lint:
	pep8 TSatPy
	pylint TSatPy

doc:
	sphinx-apidoc -F -o docs/ TSatPy/
	make -C "$(DIR)/docs" html



DIR := $(shell pwd)

test:
	nosetests --nocapture --with-coverage --cover-erase --cover-package=TSatPy --cover-html --cover-html-dir=coverage_report

lint:
	pep8 TSatPy
	pylint TSatPy --disable=C0103

doc:
	sphinx-apidoc -F -o docs/ TSatPy/
	make -C "$(DIR)/docs" html

clean:
	rm -r $(DIR)/docs/*
	rm -r $(DIR)/coverage_report/*

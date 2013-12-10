
DIR := $(shell pwd)

test:
	nosetests --nocapture --with-coverage --cover-package=TSatPy

lint:
	pep8 TSatPy
	pylint TSatPy

doc:
	sphinx-apidoc -F -o docs/ TSatPy/
	make -C "$(DIR)/docs" html


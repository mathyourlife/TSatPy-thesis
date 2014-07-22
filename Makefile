
DIR := $(shell pwd)
VERSION := $(shell grep version $(DIR)/TSatPy/__init__.py | cut -d "'" -f 2)
PIDFILE := /tmp/tsatpy.pid

bump:
	python $(DIR)/bin/bump.py

test:
	nosetests --nocapture --with-coverage --cover-erase --cover-package=TSatPy --cover-html --cover-html-dir=coverage_report

controller:
	twistd --nodaemon --pidfile $PIDFILE --python $(DIR)/bin/tsat_controller.py

lint:
	pep8 TSatPy --exclude=TSatPy/tests/* --ignore=E126,E128,E241,E124
	pylint TSatPy --disable=C0103 --ignore=tests | grep -v "Module 'numpy' has no"

doc:
	sphinx-apidoc -A "Daniel Robert Couture" -V $(VERSION) -F -o docs/ TSatPy/
	make -C "$(DIR)/docs" html

toc:
	python $(DIR)/bin/update_readme_toc.py

clean:
	rm -r $(DIR)/docs/*
	rm -r $(DIR)/coverage_report/*

thesis:
	make -C "$(DIR)/tex" thesis
	make -C "$(DIR)/tex" view

notebook:
	ipython3 notebook --quiet --notebook-dir=$(DIR)/notebooks

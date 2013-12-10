

test:
	nosetests --nocapture --with-coverage --cover-package=TSatPy

lint:
	pep8 TSatPy
	pylint TSatPy

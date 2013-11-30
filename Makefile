

test:
	nosetests --nocapture --with-coverage

lint:
	pep8 TSatPy
	pylint TSatPy

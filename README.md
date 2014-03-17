# TSatPy

This thesis utilizes an experimental tabletop satellite (UNH TableSat 1A) to span three main efforts.  First is to create a physical model of a satellite from NASA's Magnetospheric MultiScale (MMS) Mission in order to validate and compare varied gyroless attitude determination and control (ADC) techniques.  The ADC systems must keep the TableSat rotating at a constant 3 rpm, prevent boom oscillations, and correct for detected nutations off the spin plane.  The second goal is to produce a software system that can be used to run against both theoretical simulations and experimental models.  The third goal is improve TableSat's use as an outreach tool.  The system should provide near ``real-time'' feedback of the system's state, allow for on-the-fly modification to control parameters, and be designed such that a individuals specializing in control systems could customize and extend its functionality without substantial computer science expertise.

<!--- start_TOC -->

* [TSatPy](#tsatpy)
	* [License](#license)
	* [Installation](#installation)
		* [TSatPy Installation](#tsatpy-installation)
		* [Python's Virtual Environment](#pythons-virtual-environment)
	* [TSatPy Documentation](#tsatpy-documentation)
	* [Testing](#testing)
		* [Run Tests](#run-tests)
		* [Test Coverage](#test-coverage)
	* [Code Compliance](#code-compliance)
		* [Run code compliance checks](#run-code-compliance-checks)
	* [Compile Thesis](#compile-thesis)

<!--- end_TOC -->

## License

[MIT](LICENSE)

## Installation

This project was developed under ubuntu linxu although should operate similar under other distributions.  I would recommend using python's virtual environments if you haven't used them before, but a global install will work the same.  See the [Python's Virtual Environment](#pythons-virtual-environment) section for setting up a `tsat` virtual environment.

### TSatPy Installation

```bash
git clone git@github.com:MathYourLife/TSatPy.git
cd TSatPy
pip install -e .
```

### Python's Virtual Environment

I'd recommend installing via python's virtual environments.

```bash
sudo apt-get install -y python-dev
sudo apt-get install -y python-pip
sudo pip install --upgrade pip
sudo pip install --upgrade setuptools
sudo pip install --upgrade virtualenv
sudo pip install --upgrade virtualenvwrapper

mkdir -p ~/.virtualenvs
export WORKON_HOME=$HOME/.virtualenvs
source /usr/local/bin/virtualenvwrapper.sh
mkvirtualenv --no-site-packages -p /usr/bin/python2.7 tsat
workon tsat
```

## TSatPy Documentation

The module's documentation is available via python's sphinx documentation system.

```bash
make doc
firefox docs/_build/html/index.html
```

## Testing

### Run Tests

```bash
make test
```

### Test Coverage

```bash
make test
```

*Recent Run: Test Coverage*
<!--- start_test_status -->
```
nosetests --nocapture --with-coverage --cover-erase --cover-package=TSatPy --cover-html --cover-html-dir=coverage_report
.....................................................................
Name                    Stmts   Miss  Cover   Missing
-----------------------------------------------------
TSatPy                      3      0   100%
TSatPy.Clock               12      0   100%
TSatPy.Comm                64     42    34%   9, 13, 17, 52-59, 62, 65-71, 75-84, 87-98, 101-108, 111, 114
TSatPy.Discrete            47      0   100%
TSatPy.Estimator           78      9    88%   10-11, 16, 33-36, 39-40, 43, 46
TSatPy.Sensor              49     15    69%   9-11, 21-33, 36-41, 50, 53, 91
TSatPy.Server              53     32    40%   23, 26-34, 44-47, 50-51, 54, 69-85, 89-99
TSatPy.Service             30     19    37%   33-35, 50-55, 72-111
TSatPy.State              226      0   100%
TSatPy.StateOperators      41      0   100%
-----------------------------------------------------
TOTAL                     603    117    81%
----------------------------------------------------------------------
Ran 69 tests in 0.342s

OK
```
<!--- end_test_status -->

View detailed test coverage report
```bash
firefox coverage_report/index.html
```

## Code Compliance

The python code is designed to mostly comply with python's PEP8 coding standards.  A few exceptions are made by personal preference.

### Run code compliance checks

```
make lint
```

## Compile Thesis

Render the pdf of the LaTeX document with:

```bash
make thesis
```

(If only writing the thesis was this easy)


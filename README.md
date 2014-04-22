# TSatPy

TSatPy is a library written by Daniel R. Couture for my thesis "Development of a Modular Application for Observer Based Control Systems for NASA's Spin-Stabilized MMS Mission Spacecraft" in partial fulfillment for a Master's degree in Mechanical Engineering at the University of New Hampshire.  The general purpose of TSatPy is to create an application developed for initial use with TableSat (a small model of NASA's MMS mission s/c), but can be reused for a wide variety of spin stabilized systems.

**Important Links**

* [TSatPy/README.md](TSatPy/README.md) for more detailed design information
* [tex/sample_scripts/](tex/sample_scripts/) for sample scripts to demonstrate the functionality of the library
* [TSatPy/tests/](TSatPy/tests) Unit tests (partially complete) run with `make test`
* `make doc` to generate the code documentation with class structures/parameters/returns...
* `make thesis` to generate a pdf of my thesis from LaTeX
* `make lint` to perform python code compliance checks against PEP8 standards

**Table of Contents**

<!--- start_TOC -->

* [TSatPy](#tsatpy)
	* [Purpose](#purpose)
	* [Contributions to Control Theory](#contributions-to-control-theory)
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


## Contributions to Control Theory

* Gyroless observer-based controllers used to detect and eliminate nutations and maintain control of a spin stabilized satellite.
* Improved capabilities of validating observer-based control methods by keeping identical control systems between analytical simulations and real experiments.
* Allow clusters of estimators and controllers to all receive the same update for improved side-by-side comparisons of effectiveness.
* Reduce time required to tune a controller by allowing for gain adjustments and swapping of estimation/control techniques on-the-fly.
* Decompose quaternion state into separate rotational and nutation quaternions for use in error correction.
* Use decomposed quaternion and differentiated rotational quaternions to decouple rate and attitude control.
* Base quaternion state corrections on the representative rotational angle error, not the quaternion's sinusoidal scalar term.
* Build the application such that the same control laws can be used to drive analytical simulations as well as experimental tests with physical systems.
* Develop the application in a modular fashion to easily allow for future improvements and additions.
* Control rates between modules such as sensors to estimators and estimators to controllers are independent and can operate at separate rates.
* "run-time" feedback is available to visualize how the controller believes the system is responding.
* A global clock instance is used for the authoritative time which during simulations can be adjusted in runtime to speed up or slow down the simulation to obtain better insight into the system dynamics.
* Compensations for variable step sizes ($\delta t$) are made where able to protect the numerical integrity of the controller under large changes in control rates.
* Code covered by proper software unit tests to validate and maintain expected behavior of the system during software upgrades.
* Provide the combination of "run-time" visualizations and on-the-fly parameter/controller tuning for outreach programs.
* Write the control application in a high level language to keep it accessible for improvements to control systems engineers with moderate programming experience.


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
......................................................................................................................
Name                   Stmts   Miss  Cover   Missing
----------------------------------------------------
TSatPy                     3      0   100%
TSatPy.Clock              14      0   100%
TSatPy.Comm               65     42    35%   64, 71, 78, 123-130, 136, 139-145, 149-158, 161-172, 175-182, 185, 188
TSatPy.Controller         96     30    69%   57, 194-200, 209, 218, 230, 241-265, 274-280
TSatPy.Estimator         150     39    74%   210, 222, 296-300, 335, 417-456, 465-469
TSatPy.Sensor             43     12    72%   23-25, 33-41, 44-49, 58, 61
TSatPy.Server             53     32    40%   28, 31-39, 49-52, 55-56, 59, 74-90, 94-104
TSatPy.Service            30     19    37%   36-38, 53-58, 75-114
TSatPy.State             269      0   100%
TSatPy.StateOperator     125      0   100%
----------------------------------------------------
TOTAL                    848    174    79%
----------------------------------------------------------------------
Ran 118 tests in 0.262s

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


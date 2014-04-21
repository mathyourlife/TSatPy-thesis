# TSatPy

This thesis utilizes an experimental tabletop satellite (UNH TableSat 1A) to span three main efforts.

1. Create a physical model of a satellite from NASA's Magnetospheric MultiScale (MMS) Mission in order to validate and compare varied gyroless attitude determination and control (ADC) techniques.  The ADC systems must keep the TableSat rotating at a constant 3 rpm, prevent boom oscillations, and correct for detected nutations off the spin plane.
2. Produce a software system that can be used to run against both theoretical simulations and experimental models.
3. Improve TableSat's use as an outreach tool.  The system should provide near "real-time" feedback of the system's state, allow for on-the-fly modification to control parameters, and be designed such that a individuals specializing in control systems could customize and extend its functionality without substantial computer science expertise.

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

## Purpose

The work in this thesis utilizes an experimental tabletop satellite (TableSat) to span three main efforts.

1. Create a physical model of a satellite from NASA's Magnetospheric MultiScale (MMS) Mission in order to validate and compare varied gyroless attitude determination and control (ADC) techniques.  The ADC systems must keep the TableSat rotating at a constant 3 rpm, prevent boom oscillations, and correct for detected nutations off the spin plane.
2. Produce a software system that can be used to run against both theoretical simulations and experimental models.
3. Improve TableSat's use as an outreach tool.  The system should provide near ``real-time'' feedback of the system's state, allow for on-the-fly modification to control parameters, and be designed such that a individuals specializing in control systems could customize and extend its functionality without substantial computer science expertise.

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
............................................................................................
Name                    Stmts   Miss  Cover   Missing
-----------------------------------------------------
TSatPy                      3      0   100%
TSatPy.Clock               14      0   100%
TSatPy.Comm                64     42    34%   9, 13, 17, 52-59, 62, 65-71, 75-84, 87-98, 101-108, 111, 114
TSatPy.Controller          96     30    69%   33, 113-119, 122, 125, 128, 131-150, 153-159
TSatPy.Discrete            47      0   100%
TSatPy.Estimator          158     78    51%   11-12, 18-22, 26-41, 45-60, 66-67, 70-73, 84-86, 94, 130-134, 169, 188-194, 197, 200, 203, 206-238, 241-245
TSatPy.Sensor              43     12    72%   9-11, 19-27, 30-35, 44, 47
TSatPy.Server              53     32    40%   23, 26-34, 44-47, 50-51, 54, 69-85, 89-99
TSatPy.Service             30     19    37%   33-35, 50-55, 72-111
TSatPy.State              265     11    96%   174, 176, 561, 624-626, 640, 697, 720-723, 730
TSatPy.StateOperators     122     17    86%   106, 170, 175, 262-263, 266-275, 278, 346, 364
-----------------------------------------------------
TOTAL                     895    241    73%
----------------------------------------------------------------------
Ran 92 tests in 0.518s

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


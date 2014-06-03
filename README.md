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

**Adaptive Step Algorithms**

All time dependent calculations vary their parameters at run-time dependent
on the time since the last time it ran.  For example, calculations based on
integrals or derivatives reference the system clock to scale the results
based on what the clock reports is the current time step.

**Variable System Clock**

The system clock is the official time keeper for the entire ADCS.  Advantages
to using a central clock instead of the computer time is that the speed
of elapsed time can be modified at run-time during simulations to either
compress the time to complete the simulation or slow down the simulation to
inspect a certain event.

**Quaternion Multiplicative Corrections**

Quaternions that quantify a system's position contain 4 values that are
commonly tracked and controlled separately.  This produces a lot of errors
since the 4 values are co-dependent and altering one modifies the rest as
well.  Breaking the values apart also creates a disconnect between the values
and the physical position they help define.  Use of the quaternion
multiplicative correction technique maintains the integrity of the values
and their relation to the physical position of the system.  Usages of
quaternions in most estimators and controllers require normalization of
the state to a unit vector after each calculation.  In this implementation,
the only time normalization that should ever be required is to correct
for floating point error accumulation.

**Quaternion Scaling**

Unlike body rates that can be linearly scaled, the 4 quaternion values are a
sinusoidal value where multiple values can represent the same attitude
(i.e. 0, 360 degrees).  The common method of scaling by the raw values can
have unexpected results.  Due to the trig of small angle interacting with
quaternions that represent small deviations in this manner introduces a
little error, but the linear assumption creates larger errors as the angle
increases.  All quaternion scaling in this library is performed or the angle
that the quaternion represents.  With this method, we can maintain the
linear scaling affect that is desired while maintaining the integrity
of the quaternion representation.

**Run-time interface**

Through the use of a python twisted daemon process an restful API interface
is available to query the state of the system in the middle of a run.
This creates the ability to display meaningful representations of the
system and increase insight into the system's dynamic behavior instead of
relying on batch post processing.

[Sample video](http://vimeo.com/42960673)

**Concurrent Estimation/Control Algorithms**

When running a comparative analysis between different types of estimators
or different types of controllers, common methods are to re-run simulations
for each variation and compare the results.  The library allows for
configurations such as providing the same measurement values to both a PID
and SMO estimator to compare their performance.

**Quaternion Decomposition**

With spin stabilized satellites the only part of the attitude quaternion
that requires control is the one that quantifies the "wobble".  Since the 4
values are co-dependent as mentioned above just modifying 2 of the values
results in a corrupted position representation.

**Modular Design**

This library is designed to have interchangeable components with predefined
and consistent interfaces and roles by allowing for the inclusion of
additional estimation and control techniques.  In the case of estimation,
an Extended Kalman Filter (EKF) class can be added by creating a new class
in Estimator.py that has contains the common properties (`x_hat`, `last_err`..)
and common methods (`x_hat = update(x)`).

**Portable Design**

The portable design dictates that with the defined interfaces between modules,
the observer based control methods have no knowledge of what is producing
the sensor readings and what is accepting moment commands.  This enforces
consistency in the behavior of the system whether it's hooked up to an
in-memory model of a satellite, TableSat IA, or any future spin spin
stabilized platform.  The only code change that may be required (Sensor.py and
Actuator.py) is in applying the system to a new platform that contains
new types of sensors and actuators.

**Python**

Since control systems professionals regularly work in a Numerical Simulation
Software environment (like MATLAB Simulink or Octave) and when it comes to
implementation the logic is generally converted to a more standard language
by software engineers there becomes a disconnect between the planning and
implementation of a controller.  By using a language like python, the code
can be written in an expressive manner so that a control systems
professional only needs a little programming experience to modify the code.
It also keeps the controller in a language than could be reviewed for
optimization by a software engineer and applied to the actual system
without requiring a conversion to an entirely different system or language.


## License

[MIT](LICENSE)

## Installation

This project was developed under ubuntu linxu although should operate similar under other distributions.  I would recommend using python's virtual environments if you haven't used them before, but a global install will work the same.  See the [Python's Virtual Environment](#pythons-virtual-environment) section for setting up a `tsat` virtual environment.

### TSatPy Installation

Required packages
```bash
libopenblas-dev build-essential gcc gfortran python-dev libblas-dev liblapack-dev cython
```

Required viz packages
```bash
libfreetype6-dev
```

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


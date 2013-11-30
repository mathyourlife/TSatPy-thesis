# TSatPy

Python implementation of the TableSat controls platform.

## Installation

Run from linux OS

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

git clone git@github.com:MathYourLife/TSatPy.git
cd TSatPy
pip install -e .
```

## Testing

```bash
nosetests
# or to see any print statements
nosetests --nocapture --with-coverage
```

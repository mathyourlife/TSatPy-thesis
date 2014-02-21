#!/usr/bin/env python

from setuptools import setup
import TSatPy
import os

REQ_FILE = os.path.join(os.path.dirname(__file__),'requirements.txt')

# Pull required packages from the requirements.txt file
with open(REQ_FILE) as rfile:
    required = rfile.read().strip().split('\n')

classifiers = [
    'Development Status :: %s' % TSatPy.DEV_STATUS,
    'Intended Audience :: Developers',
    'Intended Audience :: Science/Research',
    'License :: OSI Approved :: MIT License',
    'Operating System :: Unix',
    'Programming Language :: Python',
    'Programming Language :: Python :: 2',
    'Topic :: Scientific/Engineering',
    'Topic :: Software Development',
]

kwargs = {
    'name': 'tsatpy',
    'version': TSatPy.__version__,
    'description': 'TableSat Control Platform',
    'long_description': open(os.path.join(os.path.dirname(__file__), 'README.md')).read(),
    'author': 'Daniel R. Couture',
    'url': 'https://github.com/MathYourLife/TSatPy',
    'packages': ['TSatPy'],
    'install_requires': required,
    'license': 'MIT license',
    'classifiers': classifiers,
    'test_suite': 'nose.collector',
    'tests_require': ['nose', 'coverage'],
}

setup(**kwargs)

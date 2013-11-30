#!/usr/bin/env python

from distutils.core import setup

import os

REQ_FILE = os.path.join(os.path.dirname(__file__),"requirements.txt")

# Pull required packages from the requirements.txt file
with open(REQ_FILE) as rfile:
    required = rfile.read().strip().split('\n')

kwargs = {
    "name": "tsatpy",
    "version": '0.0.1',
    "author": "Daniel R. Couture",
    "url": "https://github.com/MathYourLife/TSatPy",
    "packages": ['TSatPy'],
    "install_requires": required,
}

setup(**kwargs)

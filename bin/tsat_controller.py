#!/usr/bin/env python

import json
import TSatPy
import os

cfg_file = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'config.json')

with open(cfg_file) as f:
    cfg = json.load(f)

application = TSatPy.new(**cfg)

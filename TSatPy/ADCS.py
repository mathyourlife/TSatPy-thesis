"""
This module is the parent container for all the observer based controls,
and comm instances.  The instance of the ADCS should accept a json config
that can be easily stored and define the setup of the model including type
and number of estimators.

* input: config json
* output: ADCS model
"""


class ADCS(object):

    def __init__(self, clock):
        self.clock = clock
        self.timers = {}
        self.init_plant(loop)

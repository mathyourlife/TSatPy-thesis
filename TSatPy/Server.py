"""
Run the logic behind parsing postfix log lines for sender information
"""

import cgi
import json

from twisted.internet.task import LoopingCall
from twisted.web import resource

import State
from Clock import Metronome


class TSatController(object):
    """
    Create an instance of the TSat controller
    """

    def __init__(self, loop=0.1):
        self.clock = Metronome()
        self.timers = {}
        self.init_plant(loop)

    def init_plant(self, loop):
        q = State.Identity()
        w = State.BodyRate([0, 0, 0.00001])
        I = [[4, 0, 0], [0, 4, 0], [0, 0, 4]]
        self.plant = State.Plant(I, q, w, self.clock)
        self.timers['plant'] = LoopingCall(self.propagate_plant_state)
        self.timers['plant'].start(loop)

    def propagate_plant_state(self):
        self.plant.propagate([0, 0, 0])


class TSatPyAPI(resource.Resource):
    """
    API interface with the TSat controller.
    """

    isLeaf = True

    def render_GET(self, request):
        """
        Entry method for how a request is handled.
        """

        uri = request.uri.lower()

        if uri.startswith('/plant/state'):
            msg = json.dumps(self.tsat.plant.latex())

        if uri.startswith('/plant/draw'):
            tsat = TSat(0.5)
            model = Model(tsat)
            msg = "OK"

        return cgi.escape(msg).encode('ascii', 'xmlcharrefreplace')

"""
Run the logic behind parsing postfix log lines for sender information
"""

import cgi
import json

from twisted.internet.task import LoopingCall
from twisted.web import resource

import State
from Clock import Metronome



from twisted.internet.protocol import DatagramProtocol
from twisted.internet import reactor


class TSatComm(DatagramProtocol):

    def __init__(self, msg_handlers):
        self.msg_handlers = msg_handlers

    def datagramReceived(self, msg, (host, port)):
        print "received %r from %s:%d" % (msg, host, port)


        msg_num, msg_data = msg.split('\t')
        handle = self.msg_handlers[int(msg_num)][1]

        if handle is None:
            return

        handle(self.msg_handlers[msg_num][0], msg_data)
        # self.transport.write(data, (host, port))


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

    def voltage_in(self, message):
        print "voltage in: %s" % message


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

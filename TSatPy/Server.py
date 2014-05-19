"""
This module defined the classes that will receive requests from the API
interface and the UDP socket.

* input: API or UDP request
* output: twisted daemon config

"""

import cgi
import json

from twisted.internet.task import LoopingCall
from twisted.web import resource

from TSatPy import State
from TSatPy.Clock import Metronome
from TSatPy.Sensor import Sensors
from TSatPy.Estimator import Estimator

from twisted.internet.protocol import DatagramProtocol
from twisted.internet import reactor


class TSatComm(DatagramProtocol):

    def __init__(self, msg_handlers):
        self.msg_handlers = msg_handlers

    def datagramReceived(self, msg, (host, port)):
        print("received %r from %s:%d" % (msg, host, port))

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

    def __init__(self):
        self.clock = Metronome()
        self.sensor = None
        self.estimator = None
        self.setup()

    def setup(self):
        self.sensor = Sensors()
        self.estimator = Estimator()

    def v_to_x(self, v):
        self.sensor.v_to_x(v)


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
        if '?' in request.uri:
            uri, _ = request.uri.split('?', 1)
        else:
            uri = request.uri
        uri_path = uri.strip('/').split('/')
        root_uri = uri_path.pop(0).lower()

        if uri.startswith('/plant/state'):
            msg = json.dumps(self.tsat.plant.latex())

        if uri.startswith('/plant/draw'):
            tsat = TSat(0.5)
            model = Model(tsat)
            msg = "OK"

        return cgi.escape(msg).encode('ascii', 'xmlcharrefreplace')


if __name__ == '__main__':
    c = TSatController()

    v = range(1, 15)
    # css = PhotoDiodeArray()
    # css.update_state(v)
    # print(css)
    # c.sensors.
    # s = Sensors()
    c.v_to_x(v)
    print('-' * 100)
    print(c.sensor)

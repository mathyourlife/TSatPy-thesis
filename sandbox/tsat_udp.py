
import time
import struct
from twisted.application import service, internet
from twisted.internet.protocol import DatagramProtocol
from io import BytesIO


class TSatComm(DatagramProtocol):

    HEADER_FMT = '!5B'

    def __init__(self, msgs):
        self.msgs = msgs
        self.msg = dict(zip(msgs.keys(), [None]*len(msgs)))
        self.callbacks = dict(zip(msgs.keys(), [set()]*len(msgs)))

    def add_callback(self, msg_num, callback):
        self.callbacks[msg_num].add(callback)

    def datagramReceived(self, msg, (host, port)):
        print "received %r from %s:%d" % (msg, host, port)
        msgio = BytesIO(msg)

        msg_num, f1, f2, size, f3 = struct.unpack(self.HEADER_FMT, msgio.read(5))
        print msg_num, f1, f2, size, f3

        fmt, handler, name = self.msgs[msg_num]
        print fmt
        # msg_data = struct.unpack_from('dddd', payload[1:])
        data_str = struct.unpack_from(fmt, msgio.read())
        print data_str
        if handler is None:
            for callback in self.callbacks[msg_num]:
                callback()
        else:
            data = handler(data_str)
            self.msg[msg_num] = (time.time(), data)
            for callback in self.callbacks[msg_num]:
                callback(data)

        args = [104, 0, 0, 1, 0, 1]
        data = struct.pack('!6B', *args)

        self.transport.write(data, (host, port))


def ReadAckMsg(msg):
    print 'in ReadAckMsg'
    return msg[0] == 1

def EndDataMsg(msg):
    print 'in EndDataMsg'
    pass

def ReadRawData(msg):
    print 'in ReadRawData'
    return [float(v) for v in msg]

def main():
    msg_handlers = {
        2:   ['!B', ReadAckMsg, 'Set run mode'],
        4:   ['!B', None, 'Set run mode'],
        18:  ['!4d', None, 'Set fan speed'],
        19:  ['!B', None, 'Set log record mode'],
        20:  ['!B', None, 'Request sensor reading'],
        22:  ['!B', EndDataMsg, 'End of sensor log'],
        23:  ['!d', None, 'Request sensor log data'],
        33:  ['!d', None, 'Set log sample rate'],
        63:  ['!15d', ReadRawData, 'Sensor readings'],
        64:  ['!16d', ReadRawData, 'Sensor log entry'],
        65:  ['!d', ReadRawData, 'Sensor log size'],
        104: ['!B', ReadAckMsg, 'Ack run mode'],
        118: ['!B', ReadAckMsg, 'Ack fan volt'],
        119: ['!B', ReadAckMsg, 'Ack sensor log run mode'],
        133: ['!B', ReadAckMsg, 'ACK log sample rate'],
    }

    comm = TSatComm(msg_handlers)
    application = service.Application("tsatpy")

    udp_service = internet.UDPServer(9878, comm)
    udp_service.setServiceParent(application)

    return application


application = main()

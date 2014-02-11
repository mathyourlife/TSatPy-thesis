
import struct
from twisted.application import service, internet
from twisted.internet.protocol import DatagramProtocol


class TSatComm(DatagramProtocol):

    def __init__(self, msg_handlers):
        self.msg_handlers = msg_handlers

    def datagramReceived(self, msg, (host, port)):
        print "received %r from %s:%d" % (msg, host, port)

        msg_num, f1, f2, size, f3 = [ord(i) for i in msg[:5]]
        print msg_num, f1, f2, size, f3

        fmt = self.msg_handlers[msg_num][0]
        print fmt
        # msg_data = struct.unpack_from('dddd', payload[1:])
        data = struct.unpack_from(fmt, msg[5:])
        print data

        args = [104, 0, 0, 1, 0, 1]
        data = struct.pack('BBBBBB', *args)

        self.transport.write(data, (host, port))


def ReadAckMsg(fmt, msg):
    print 'in ReadAckMsg'
    pass

def EndDataMsg(fmt, msg):
    print 'in EndDataMsg'
    pass

def ReadRawData(fmt, msg):
    print 'in ReadRawData'
    msg_data = struct.unpack_from(fmt, msg)
    print msg_data
    pass

def main():
    uint = 'B' # 1
    dsize = 'd' # 8
    vsize = 32767
    msg_handlers = {
        2:   [uint, ReadAckMsg, 'Set run mode'],
        4:   [uint, None, 'Set run mode'],
        18:  [4*dsize, None, 'Set fan speed'],
        19:  [uint, None, 'Set log record mode'],
        20:  [uint, None, 'Request sensor reading'],
        22:  [uint, EndDataMsg, 'End of sensor log'],
        23:  [dsize, None, 'Request sensor log data'],
        33:  [dsize, None, 'Set log sample rate'],
        63:  [15*dsize, ReadRawData, 'Sensor readings'],
        64:  [16*dsize, ReadRawData, 'Sensor log entry'],
        65:  [dsize, ReadRawData, 'Sensor log size'],
        104: [uint, ReadAckMsg, 'Ack run mode'],
        118: [uint, ReadAckMsg, 'Ack fan volt'],
        119: [uint, ReadAckMsg, 'Ack sensor log run mode'],
        133: [uint, ReadAckMsg, 'ACK log sample rate'],
    }

    comm = TSatComm(msg_handlers)
    application = service.Application("tsatpy")

    udp_service = internet.UDPServer(9877, comm)
    udp_service.setServiceParent(application)

    return application


application = main()

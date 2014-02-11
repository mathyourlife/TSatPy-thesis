
import socket
import struct

def ReadAckMsg(msg):
    print "ReadAckMsg"
    print msg


def EndDataMsg(msg):
    print "EndDataMsg"
    print msg


def ReadRawData(msg):
    print "ReadRawData"
    print msg


class UDP(object):

    def send(self):
        UDP_IP = "192.168.0.190"
        UDP_PORT = 9877

        args = [65, 0, 0, 1, 0, 300]
        MESSAGE = struct.pack('BBBBBd', *args)

        print "UDP target IP:", UDP_IP
        print "UDP target port:", UDP_PORT
        print "message:", MESSAGE

        sock = socket.socket(socket.AF_INET, # Internet
                  socket.SOCK_DGRAM) # UDP
        sock.bind(('0.0.0.0', UDP_PORT))
        sock.sendto(MESSAGE, (UDP_IP, UDP_PORT))


    def recieve(self, message):
        control_loop.voltage_in(message)




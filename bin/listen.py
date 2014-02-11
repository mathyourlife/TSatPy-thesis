
from twisted.internet import protocol
from twisted.pair import rawudp

class MyProtocol(protocol.DatagramProtocol):

    def datagramReceived(self, data, (host, port)):
        print data, (host, port)

def testPacketParsing():
    proto = rawudp.RawUDPProtocol()
    p1 = MyProtocol()
    print 0xF00F
    proto.addProto(0xF00F, p1)

    proto.datagramReceived("\x43\xA2" #source port
                           + "\xf0\x0f" #dest port
                           + "\x00\x06" #len
                           + "\xDE\xAD" #check
                           + "foobar",
                           partial=0,
                           dest='dummy',
                           source='testHost',
                           protocol='dummy',
                           version='dummy',
                           ihl='dummy',
                           tos='dummy',
                           tot_len='dummy',
                           fragment_id='dummy',
                           fragment_offset='dummy',
                           dont_fragment='dummy',
                           more_fragments='dummy',
                           ttl='dummy',
                           )

testPacketParsing()
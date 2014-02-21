
import struct
OK, EFORMAT, ESERVER, ENAME, ENOTIMP, EREFUSED = range(6)
IXFR, AXFR, MAILB, MAILA, ALL_RECORDS = range(251, 256)
IN, CS, CH, HS = range(1, 5)
from io import BytesIO


class Message:
    """
    L{Message} contains all the information represented by a single
    DNS request or response.

    @ivar id: See L{__init__}
    @ivar answer: See L{__init__}
    @ivar opCode: See L{__init__}
    @ivar recDes: See L{__init__}
    @ivar recAv: See L{__init__}
    @ivar auth: See L{__init__}
    @ivar rCode: See L{__init__}
    @ivar trunc: See L{__init__}
    @ivar maxSize: See L{__init__}
    @ivar authenticData: See L{__init__}
    @ivar checkingDisabled: See L{__init__}

    @ivar queries: The queries which are being asked of or answered by
        DNS server.
    @type queries: L{list} of L{Query}

    @ivar answers: Records containing the answers to C{queries} if
        this is a response message.
    @type answers: L{list} of L{RRHeader}

    @ivar authority: Records containing information about the
        authoritative DNS servers for the names in C{queries}.
    @type authority: L{list} of L{RRHeader}

    @ivar additional: Records containing IP addresses of host names
        in C{answers} and C{authority}.
    @type additional: L{list} of L{RRHeader}
    """
    headerFmt = "!H2B4H"
    headerSize = struct.calcsize(headerFmt)

    # Question, answer, additional, and nameserver lists
    queries = answers = add = ns = None

    def __init__(self, id=0, answer=0, opCode=0, recDes=0, recAv=0,
                       auth=0, rCode=OK, trunc=0, maxSize=512,
                       authenticData=0, checkingDisabled=0):
        """
        @param id: A 16 bit identifier assigned by the program that
            generates any kind of query.  This identifier is copied to
            the corresponding reply and can be used by the requester
            to match up replies to outstanding queries.
        @type id: L{int}

        @param answer: A one bit field that specifies whether this
            message is a query (0), or a response (1).
        @type answer: L{int}

        @param opCode: A four bit field that specifies kind of query in
            this message.  This value is set by the originator of a query
            and copied into the response.
        @type opCode: L{int}

        @param recDes: Recursion Desired - this bit may be set in a
            query and is copied into the response.  If RD is set, it
            directs the name server to pursue the query recursively.
            Recursive query support is optional.
        @type recDes: L{int}

        @param recAv: Recursion Available - this bit is set or cleared
            in a response and denotes whether recursive query support
            is available in the name server.
        @type recAv: L{int}

        @param auth: Authoritative Answer - this bit is valid in
            responses and specifies that the responding name server
            is an authority for the domain name in question section.
        @type auth: L{int}

        @ivar rCode: A response code, used to indicate success or failure in a
            message which is a response from a server to a client request.
        @type rCode: C{0 <= int < 16}

        @param trunc: A flag indicating that this message was
            truncated due to length greater than that permitted on the
            transmission channel.
        @type trunc: L{int}

        @param maxSize: The requestor's UDP payload size is the number
            of octets of the largest UDP payload that can be
            reassembled and delivered in the requestor's network
            stack.
        @type maxSize: L{int}

        @param authenticData: A flag indicating in a response that all
            the data included in the answer and authority portion of
            the response has been authenticated by the server
            according to the policies of that server.
            See U{RFC2535 section-6.1<https://tools.ietf.org/html/rfc2535#section-6.1>}.
        @type authenticData: L{int}

        @param checkingDisabled: A flag indicating in a query that
            pending (non-authenticated) data is acceptable to the
            resolver sending the query.
            See U{RFC2535 section-6.1<https://tools.ietf.org/html/rfc2535#section-6.1>}.
        @type authenticData: L{int}
        """
        self.maxSize = maxSize
        self.id = id
        self.answer = answer
        self.opCode = opCode
        self.auth = auth
        self.trunc = trunc
        self.recDes = recDes
        self.recAv = recAv
        self.rCode = rCode
        self.authenticData = authenticData
        self.checkingDisabled = checkingDisabled

        self.queries = []
        self.answers = []
        self.authority = []
        self.additional = []


    def addQuery(self, name, type=ALL_RECORDS, cls=IN):
        """
        Add another query to this Message.

        @type name: C{bytes}
        @param name: The name to query.

        @type type: C{int}
        @param type: Query type

        @type cls: C{int}
        @param cls: Query class
        """
        self.queries.append(Query(name, type, cls))


    def encode(self, strio):
        compDict = {}
        body_tmp = BytesIO()
        for q in self.queries:
            q.encode(body_tmp, compDict)
        for q in self.answers:
            q.encode(body_tmp, compDict)
        for q in self.authority:
            q.encode(body_tmp, compDict)
        for q in self.additional:
            q.encode(body_tmp, compDict)
        body = body_tmp.getvalue()
        size = len(body) + self.headerSize
        if self.maxSize and size > self.maxSize:
            self.trunc = 1
            body = body[:self.maxSize - self.headerSize]
        byte3 = (( ( self.answer & 1 ) << 7 )
                 | ((self.opCode & 0xf ) << 3 )
                 | ((self.auth & 1 ) << 2 )
                 | ((self.trunc & 1 ) << 1 )
                 | ( self.recDes & 1 ) )
        byte4 = ( ( (self.recAv & 1 ) << 7 )
                  | ((self.authenticData & 1) << 5)
                  | ((self.checkingDisabled & 1) << 4)
                  | (self.rCode & 0xf ) )

        strio.write(struct.pack(self.headerFmt, self.id, byte3, byte4,
                                len(self.queries), len(self.answers),
                                len(self.authority), len(self.additional)))
        strio.write(body)


    def decode(self, strio, length=None):
        self.maxSize = 0
        header = readPrecisely(strio, self.headerSize)
        r = struct.unpack(self.headerFmt, header)
        self.id, byte3, byte4, nqueries, nans, nns, nadd = r
        self.answer = ( byte3 >> 7 ) & 1
        self.opCode = ( byte3 >> 3 ) & 0xf
        self.auth = ( byte3 >> 2 ) & 1
        self.trunc = ( byte3 >> 1 ) & 1
        self.recDes = byte3 & 1
        self.recAv = ( byte4 >> 7 ) & 1
        self.authenticData = ( byte4 >> 5 ) & 1
        self.checkingDisabled = ( byte4 >> 4 ) & 1
        self.rCode = byte4 & 0xf

        self.queries = []
        for i in range(nqueries):

            self.name.decode(strio)
            buff = readPrecisely(strio, 4)
            self.type, self.cls = struct.unpack("!HH", buff)

            q = Query()
            try:
                q.decode(strio)
            except EOFError:
                return
            self.queries.append(q)

        items = (
            (self.answers, nans),
            (self.authority, nns),
            (self.additional, nadd))

        for (l, n) in items:
            self.parseRecords(l, n, strio)


    def parseRecords(self, list, num, strio):
        for i in range(num):
            header = RRHeader(auth=self.auth)
            try:
                header.decode(strio)
            except EOFError:
                return
            t = self.lookupRecordType(header.type)
            if not t:
                continue
            header.payload = t(ttl=header.ttl)
            try:
                header.payload.decode(strio, header.rdlength)
            except EOFError:
                return
            list.append(header)


    # Create a mapping from record types to their corresponding Record_*
    # classes.  This relies on the global state which has been created so
    # far in initializing this module (so don't define Record classes after
    # this).
    _recordTypes = {}
    for name in globals():
        if name.startswith('Record_'):
            _recordTypes[globals()[name].TYPE] = globals()[name]

    # Clear the iteration variable out of the class namespace so it
    # doesn't become an attribute.
    del name


    def lookupRecordType(self, type):
        """
        Retrieve the L{IRecord} implementation for the given record type.

        @param type: A record type, such as L{A} or L{NS}.
        @type type: C{int}

        @return: An object which implements L{IRecord} or C{None} if none
            can be found for the given type.
        @rtype: L{types.ClassType}
        """
        return self._recordTypes.get(type, UnknownRecord)


    def toStr(self):
        """
        Encode this L{Message} into a byte string in the format described by RFC
        1035.

        @rtype: C{bytes}
        """
        strio = BytesIO()
        self.encode(strio)
        return strio.getvalue()


    def fromStr(self, str):
        """
        Decode a byte string in the format described by RFC 1035 into this
        L{Message}.

        @param str: L{bytes}
        """
        strio = BytesIO(str)
        self.decode(strio)


def readPrecisely(file, l):
    buff = file.read(l)
    if len(buff) < l:
        raise EOFError
    return buff

# DNS Protocol Version Query Request
verPayload   = '\x02\xec'     # Transaction ID  748
verPayload  += '\x01\x00'     # Standard query flag  (1, 0)
verPayload  += '\x00\x01'     # Questions    1
verPayload  += '\x00\x00'     # Number of Answers  0
verPayload  += '\x00\x00'     # Number of Authoritative Records 0
verPayload  += '\x00\x00'     # Number of Additional Records 0
verPayload  += '\x07\x76\x65\x72\x73\x69\x6f\x6e\x04\x62\x69\x6e\x64\x00\x00\x10\x00\x03'    # version.bind Request

headerFmt = "!H2B4H"
headerSize = struct.calcsize(headerFmt)

strio = BytesIO(verPayload)
print strio

header = readPrecisely(strio, headerSize)
print header

print struct.unpack(headerFmt, header)
m = Message()
m.fromStr(verPayload)


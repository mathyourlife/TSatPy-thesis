

class ADCS(object):

    def __init__(self, clock):
        self.clock = clock
        self.timers = {}
        self.init_plant(loop)

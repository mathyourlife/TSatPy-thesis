import time


class Derivative(object):

    @property
    def val(self):
        return self.rate

    def __init__(self):
        self.reset()

    def update(self, val, ts=None):

        if ts is None:
            ts = time.time()

        try:
            self.rate = (val - self.last_value) / (self.last_time - ts)
        except TypeError:
            pass
        self.last_value = val
        self.last_time = ts

    def reset(self):

        self.last_value = None
        self.last_time = None
        self.rate = 0

    def __str__(self):
        return "<%s rate:%s>" % (self.__class__.__name__, self.rate)

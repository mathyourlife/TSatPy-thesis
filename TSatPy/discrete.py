"""
Common Classes used to implement discrete time calculations.
"""

import time


class Derivative(object):
    """
    Discrete time derivative
    """

    @property
    def val(self):
        """ Convenience property to pull the current rate """
        return self.rate

    def __init__(self):
        self.last_value = None
        self.last_time = None
        self.rate = None

    def update(self, val, epoch=None):
        """
        Set the new value and calculate the derivative.  Rate value
        will not be available until the second update.

        :param val: New value
        :type  val: Numeric
        :param epoch: Epoch timestamp for the new value.  If none, current timestamp is used.
        :type  epoch: float
        """

        if epoch is None:
            epoch = time.time()

        try:
            self.rate = (val - self.last_value) / float(epoch - self.last_time)
        except TypeError:
            pass
        except ZeroDivisionError:
            pass

        self.last_value = val
        self.last_time = epoch

    def reset(self):
        """
        Helper method to reset the object.
        """

        self.last_value = None
        self.last_time = None
        self.rate = None

    def __str__(self):
        """
        String represetiaiton of the derivative.
        """
        return "<%s rate:%s>" % (self.__class__.__name__, self.rate)


class Integral(object):
    """
    Discrete time integral
    """

    @property
    def val(self):
        """ Convenience property to pull the current sum """
        return self.sum

    def __init__(self):
        self.last_value = None
        self.last_time = None
        self.sum = None

    def update(self, val, epoch=None):
        """
        Update the running sum with the new value.  Assumed a first order hold
        where the signal value is a linear interpolation between the last update and
        the current one.

        :param val: New value
        :type  val: Numeric
        :param epoch: Epoch timestamp for the new value.  If none, current timestamp is used.
        :type  epoch: float
        """

        if epoch is None:
            epoch = time.time()

        try:
            self.sum += (val + self.last_value) * float(epoch - self.last_time) / 2
        except ZeroDivisionError:
            pass
        except TypeError:
            self.sum = 0

        self.last_value = val
        self.last_time = epoch

    def reset(self):
        """
        Helper method to reset the object.
        """

        self.last_value = None
        self.last_time = None
        self.sum = None

    def __str__(self):
        """
        String represetiaiton of the derivative.
        """
        return "<%s sum:%s>" % (self.__class__.__name__, self.sum)

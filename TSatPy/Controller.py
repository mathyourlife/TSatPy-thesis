"""
The TSatPy.Controller module is responsible for taking the estimated state
of the system from the TSatPy.Estimator instance, comparing it to the
state of the system desired by the user and calculating a moment required
to push the current state to the desired.
"""

import numpy as np
from TSatPy import State

class ControllerException(Exception):
    pass


class ControllerBase(object):
    def __init__(self, clock, ic=None):
        self.clock = clock
        self.last_update = None
        self.M = State.Moment()
        self.x_e = State.State()

    def update(self, x, M=None):
        pass

class PID(ControllerBase):
    def __init__(self, clock, **kwargs):
        ControllerBase.__init__(self, clock, **kwargs)

        # Default desired state
        self.x_d = State.State()

        self.M = State.Moment()
        # Zero out state integrator term
        self.x_i = State.State()
        self.x_e = State.State()

        self.last_err = None
        self.K = {
            'p': None,
            'i': None,
            'd': None,
        }

    def set_desired_state(self, x_d):
        # A straight replacement could destroy uses of references to the
        # object.  Replace underlying data instead.
        self.x_d.q.vector = x_d.q.vector
        self.x_d.q.scalar = x_d.q.scalar
        self.x_d.w.w = x_d.w.w

    def set_Kp(self, K):
        self.K['p'] = K

    def set_Ki(self, K):
        self.K['i'] = K

    def set_Kd(self, K):
        self.K['d'] = K

    def update(self, x_hat):
        t = self.clock.tick()
        try:
            dt = t - self.last_update
        except TypeError:
            dt = 0

        x_err = State.StateError(self.x_d, x_hat)
        m_adj = State.Moment()

        m_adj += self.K['p'] * x_err

        self.x_e = x_err
        self.M.M = -m_adj.M
        return self.M

    def __str__(self):
        gains = [self.__class__.__name__,
            ' x_d %s' % self.x_d,
            ' x_e %s' % self.x_e]
        for G in self.K.iteritems():
            gains.append(' K%s %s' % G)
        return '\n'.join(gains)


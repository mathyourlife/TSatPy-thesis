"""
The TSatPy.Controller module is responsible for taking the estimated state
of the system from the TSatPy.Estimator instance, comparing it to the
state of the system desired by the user and calculating a moment required
to push the current state to the desired.
"""

import numpy as np
from TSatPy import State, StateOperator as SO


class ControllerException(Exception):
    pass


class ControllerBase(object):
    def __init__(self, clock, ic=None):
        self.clock = clock
        self.last_update = None
        self.M = State.Moment()
        self.x_e = State.State()
        # Default desired state
        self.x_d = State.State()

    def set_desired_state(self, x_d):
        # A straight replacement could destroy uses of references to the
        # object.  Replace underlying data instead.
        self.x_d.q.vector = x_d.q.vector
        self.x_d.q.scalar = x_d.q.scalar
        self.x_d.w.w = x_d.w.w

    def update(self, x, M=None):
        pass


class PID(ControllerBase):
    def __init__(self, clock, **kwargs):
        ControllerBase.__init__(self, clock, **kwargs)

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

    def set_Kp(self, K):
        self.K['p'] = K

    def set_Ki(self, K):
        self.K['i'] = K

    def set_Kd(self, K):
        self.K['d'] = K

    def update(self, x_hat):
        t = self.clock.tick()
        try:
            dt = float(t - self.last_update)
        except TypeError:
            dt = 0

        x_err = State.StateError(self.x_d, x_hat)
        m_adj = State.Moment()

        if self.K['p'] is not None:
            m_adj += self.K['p'] * x_err

        if dt and self.K['i'] is not None:
            Kt = SO.StateGain(
                SO.QuaternionGain(dt),
                SO.BodyRateGain(np.eye(3) * dt))
            self.x_i += Kt * x_err

            m_adj += self.K['i'] * self.x_i

        if dt and self.K['d'] is not None:
            Kt = SO.StateGain(
                SO.QuaternionGain(1 / dt),
                SO.BodyRateGain(np.eye(3) * (1 / dt)))

            x_diff = x_err - self.last_err
            x_d_err = Kt * x_diff

            m_adj += self.K['d'] * x_d_err

        self.x_e = x_err
        self.last_update = t
        self.last_err = x_err
        self.M = m_adj
        return self.M

    def __str__(self):
        gains = [self.__class__.__name__,
            ' x_d %s' % self.x_d,
            ' x_e %s' % self.x_e]
        for G in self.K.iteritems():
            gains.append(' K%s %s' % G)
        return '\n'.join(gains)


class SMC(ControllerBase):
    """
    A sliding mode observer takes the form of
    x(k+1) = x(k) + L*x_e(k) + K*1s(x_e(k))
    """

    def __init__(self, clock, **kwargs):
        ControllerBase.__init__(self, clock, **kwargs)

        # Zero out state integrator
        self.last_err = None
        self.L = None
        self.K = None
        self.S = None

    def set_L(self, L):
        self.L = L

    def set_K(self, K):
        self.K = K

    def set_S(self, S):
        self.S = S

    def update(self, x_hat):
        t = self.clock.tick()
        try:
            dt = t - self.last_update
        except TypeError:
            dt = 0

        x_err = State.StateError(self.x_d, x_hat)
        m_adj = State.Moment()

        if self.L is not None:
            m_adj += self.L * x_err

        x_s = self.S * x_err
        m_adj += self.K * x_s

        self.x_e = x_err
        self.last_update = t
        self.last_err = x_err
        self.M = m_adj
        return self.M

    def __str__(self):
        gains = [self.__class__.__name__,
            ' x_d %s' % self.x_d,
            ' x_e %s' % self.x_e]
        gains.append(' L %s' % self.L)
        gains.append(' K %s' % self.K)
        gains.append(' S %s' % self.S)
        return '\n'.join(gains)


import time
import numpy as np
from twisted.internet.task import LoopingCall
from TSatPy import State
from TSatPy import StateOperators as SO


class Estimator(object):
    def __init__(self, clock, **kwargs):
        self.clock = clock
        self.estimators = []

    def add(self, type, plant, kwargs):
        """
        Add an configured estimator to the array of estimators
        """
        if type.lower() == 'pid':
            est = self.config_pid(plant, **kwargs)
        elif type.lower() == 'smo':
            est = self.config_smo(plant, **kwargs)
        self.estimators.append(est)

    def config_smo(self, plant, Lq, Lw, Kq, Kw, Sq, Sw):

        L = SO.StateGain(
            SO.QuaternionGain(Lq),
            SO.BodyRateGain(np.eye(3) * Lw))
        K = SO.StateGain(
            SO.QuaternionGain(Kq),
            SO.BodyRateGain(np.eye(3) * Kw))

        Sx = SO.StateSaturation(
            SO.QuaternionSaturation(Sq),
            SO.BodyRateSaturation(Sw))

        smo = SMO(self.clock, plant=plant)
        smo.set_S(Sx)
        smo.set_L(L)
        smo.set_K(K)
        return smo

    def config_pid(self, plant, kpq, kpw, kiq, kiw, kdq, kdw):

        pid = PID(self.clock, plant=plant)

        Kp = SO.StateGain(
            SO.QuaternionGain(kpq),
            SO.BodyRateGain(np.eye(3) * kpw))
        Ki = SO.StateGain(
            SO.QuaternionGain(kiq),
            SO.BodyRateGain(np.eye(3) * kiw))
        Kd = SO.StateGain(
            SO.QuaternionGain(kdq),
            SO.BodyRateGain(np.eye(3) * kdw))

        pid.set_Kp(Kp)
        pid.set_Ki(Ki)
        pid.set_Kd(Kd)
        return pid

    def update(self, x, M=None):
        """
        Update all active estimators with the current measured state.
        """
        for idx in xrange(len(self.estimators)):
            self.estimators[idx].update(x=x, M=M)

    def __str__(self):
        est_str = [self.__class__.__name__]
        for est in self.estimators:
            est_str.append(str(est))
        return '\n'.join(est_str)



class EstimatorBase(object):

    def __init__(self, clock, plant=None, ic=None):
        self.clock = clock
        self.last_update = None
        self.plant = plant
        if plant:
            if ic is not None:
                self.plant.set_state(ic)
            self.x_hat = plant.x
        else:
            if ic is None:
                self.x_hat = State.State()
            else:
                self.x_hat = ic

    def update(self, x, M=None):
        pass


class PID(EstimatorBase):

    def __init__(self, clock, **kwargs):
        EstimatorBase.__init__(self, clock, **kwargs)

        # Zero out state integrator
        self.x_i = State.State()
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

    def update(self, x, M=None):
        t = self.clock.tick()
        try:
            dt = t - self.last_update
        except TypeError:
            dt = 0

        # Use the plant dynamics to predict where the system's state
        # should be now.
        if self.plant:
            self.plant.propagate()
            x_hat_pre = self.plant.x
            self.x_hat.q.vector = x_hat_pre.q.vector
            self.x_hat.q.scalar = x_hat_pre.q.scalar
            self.x_hat.w.w = x_hat_pre.w.w

        x_err = State.StateError(self.x_hat, x)
        x_adj = State.State()

        if self.K['p'] is not None:
            x_kp = self.K['p'] * x_err
            x_adj += x_kp

        if dt and self.K['i'] is not None:
            Kq = SO.QuaternionGain(dt)
            Kw = SO.BodyRateGain(
                [[dt, 0, 0], [0, dt, 0], [0, 0, dt]])
            Kt = SO.StateGain(Kq, Kw)

            x_i_err = Kt * x_err
            self.x_i += x_i_err

            x_ki = self.K['i'] * self.x_i
            x_adj += x_ki

        if dt and self.K['d'] is not None:
            Kq = SO.QuaternionGain(1 / dt)
            Kw = SO.BodyRateGain(
                [[1 / dt, 0, 0], [0, 1 / dt, 0], [0, 0, 1 / dt]])
            Kt = SO.StateGain(Kq, Kw)

            x_diff = x_err - self.last_err
            x_d_err = Kt * x_diff
            x_kd = self.K['d'] * x_d_err
            x_adj += x_kd

        self.x_adj = x_adj
        self.x_hat -= x_adj
        if self.plant:
            self.plant.set_state(self.x_hat)
        self.last_update = t
        self.last_err = x_err
        return self.x_hat

    def __str__(self):
        gains = [self.__class__.__name__, ' x_hat %s' % self.x_hat]
        for G in self.K.iteritems():
            gains.append(' K%s %s' % G)
        return '\n'.join(gains)


class SMO(EstimatorBase):
    """

    x(k+1) = x(k) + L*x_e(k) + K*1s(x_e(k))
    """

    def __init__(self, clock, **kwargs):
        EstimatorBase.__init__(self, clock, **kwargs)

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

    def update(self, x, M=None):
        t = self.clock.tick()
        try:
            dt = t - self.last_update
        except TypeError:
            dt = 0

        # Use the plant dynamics to predict where the system's state
        # should be now.
        if self.plant:
            self.plant.propagate()
            x_hat_pre = self.plant.x
            self.x_hat.q.vector = x_hat_pre.q.vector
            self.x_hat.q.scalar = x_hat_pre.q.scalar
            self.x_hat.w.w = x_hat_pre.w.w

        x_err = State.StateError(self.x_hat, x)
        x_adj = State.State()

        if self.L is not None:
            x_l = self.L * x_err
            x_adj += x_l

        x_s = self.S * x_err
        x_ks = self.K * x_s
        x_adj += x_ks

        self.x_adj = x_adj
        self.x_hat -= x_adj
        if self.plant:
            self.plant.set_state(self.x_hat)
        self.last_update = t
        self.last_err = x_err
        return self.x_hat

    def __str__(self):
        gains = [self.__class__.__name__, ' x_hat %s' % self.x_hat]
        gains.append(' L %s' % self.L)
        gains.append(' K %s' % self.K)
        gains.append(' S %s' % self.S)
        return '\n'.join(gains)



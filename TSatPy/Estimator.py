
import time
from twisted.internet.task import LoopingCall
from TSatPy import State
from TSatPy import StateOperators


class Estimator(object):
    def __init__(self):
        self.x_hat = State()
        self.estimators = {
            'pid': PID(),
        }

    def propagate(self, x, u):
        pass


class EstimatorBase(object):

    def __init__(self, clock, propagate_every=None, I=None):
        self.clock = clock
        self.last_update = None
        self.I = [[4, 0, 0], [0, 4, 0], [0, 0, 4]]
        self.x_hat = State.State()
        self.plant = State.Plant(self.I, self.x_hat, self.clock)
        self.propagate_every = propagate_every

        if self.propagate_every is not None:
            self.timers = {
                'propagate': LoopingCall(self.propagate)
            }
            self.start_propagation()

    def start_propagation(self):
        if self.propagate is not None:
            self.timers['propagate'].start(self.propagate_every)

    def propagate(self, M=None):
        pass

    def update(self, x, M=None):
        pass


class PID(EstimatorBase):

    def __init__(self, clock, propagate_every=None, I=None):
        EstimatorBase.__init__(self, clock, propagate_every, I)
        self.K = {
            'p': None,
            'i': None,
            'd': None,
        }

    def set_Kp(self, K):
        self.K['p'] = K

    def update(self, x, M=None):
        t = self.clock.tick()
        try:
            dt = t - self.last_update
        except TypeError:
            dt = 0

        x_err = State.StateError(self.x_hat, x)
        x_adj = self.K['p'] * x_err

        self.x_hat -= x_adj
        self.last_update = t
        return self.x_hat

    def __str__(self):
        gains = [self.__class__.__name__, ' x_hat %s' % self.x_hat]
        for G in self.K.iteritems():
            gains.append(' K%s %s' % G)
        return '\n'.join(gains)


def main():
    from TSatPy.Clock import Metronome
    from twisted.internet import reactor
    import numpy as np
    c = Metronome()
    k = 0.2
    Kq = StateOperators.QuaternionGain(k)
    Kw = StateOperators.BodyRateGain([[k,0,0],[0,k,0],[0,0,k]])
    Kp = StateOperators.StateGain(Kq, Kw)

    pid = PID(c)
    pid.set_Kp(Kp)
    print('Initial Condition\n%s' % pid)

    x = State.State(
        State.Quaternion([0,0,1],radians=np.pi/15),
        State.BodyRate([0.1,2,3])
    )
    print('Measured State: %s' % x)
    x_hat = pid.update(x)
    print('Updated State:  %s' % x_hat)
    print('Expected State: %s' % State.State(
        State.Quaternion([0,0,1],radians=np.pi/75),
        State.BodyRate([0.02,0.4,0.6])))

    # reactor.run()


if __name__ == '__main__':
    main()
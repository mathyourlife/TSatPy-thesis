"""
This module contains the algorithms that take what we have estimated the
system to be doing, compare it to what we want it to do, and determine
what moments need to be applied to make the system behave as desired.

The master control instance governs the interface between the incoming
estimator state and the outgoing actuator moments.  The master controller
can run multiple control algorithms simultaneously which can be individually
tuned to different types of system behaviors like one that can handle
large errors and one for the soft corrections at steady state.

* input: configuration of what types of control algorithms should be used
         and the parameters required to set them up
* output: a desired moment based on the active control algorithm's calculations

"""

import numpy as np
from TSatPy import State, StateOperator as SO


class ControllerException(Exception):
    pass


class ControllerBase(object):
    """
    Base controller methods to be extended upon

    :param clock: the system clock to track time passing and speed changes
    :type  clock: Clock.Metronome
    """
    def __init__(self, clock):
        self.clock = clock
        self.last_update = None
        self.M = State.Moment()
        self.x_e = State.State()
        # Default desired state
        self.x_d = State.State()

    def set_desired_state(self, x_d):
        """
        A straight replacement could destroy uses of references to the
        object.  Replace underlying data instead.

        :param x_d: The desired attitude and body rate for the system
        :type  x_d: State
        """
        self.x_d.q.vector = x_d.q.vector
        self.x_d.q.scalar = x_d.q.scalar
        self.x_d.w.w = x_d.w.w

    def update(self, x_hat):
        """
        Place holder method to be overridden.
        """
        pass


class PID(ControllerBase):
    """
    Proportional-Integral-Derivative controller.

    Gains Kp, Ki, and Kd can be all or none defined.  Integral and derivative
    calcualtions are time dependent so reference the 'clock' instance as it
    can alter it's speed during a run.

    M = Kp * xe + Ki * sum(xe) + Kd * (xe - xe_last)

    :param clock: system clock that can run at different speeds
    :type  clock: Metronome.Clock
    """
    def __init__(self, clock):
        ControllerBase.__init__(self, clock)

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
        """
        Set the state proportional gain

        :param K: gains to be multiplied by the current error value
        :type  K: StateOperator.StateToMoment
        """
        self.K['p'] = K

    def set_Ki(self, K):
        """
        Set the state integral gain

        :param K: gains to be multiplied by the running total in self.x_i
        :type  K: StateOperator.StateToMoment
        """
        self.K['i'] = K

    def set_Kd(self, K):
        """
        Set the state derivative gain

        :param K: gains to be multiplied by the rate of change
        :type  K: StateOperator.StateToMoment
        """
        self.K['d'] = K

    def update(self, x_hat):
        """
        A new state estimate is available.

        :param x_hat: The estimated state
        :type  x_hat: State
        :return: The moment to push the state to the desired state
        :rtype: Moment
        """
        t = self.clock.tick()
        try:
            dt = float(t - self.last_update)
        except TypeError:
            dt = 0

        # Calculate the state error and starting the empty moment
        x_err = State.StateError(self.x_d, x_hat)
        m_adj = State.Moment()

        # Add the proportional adjustment
        if self.K['p'] is not None:
            m_adj += self.K['p'] * x_err

        # Add the integral adjustment
        if dt and self.K['i'] is not None:
            Kt = SO.StateGain(
                SO.QuaternionGain(dt),
                SO.BodyRateGain(np.eye(3) * dt))
            self.x_i += Kt * x_err

            m_adj += self.K['i'] * self.x_i

        # Add the derivative adjustment
        if dt and self.K['d'] is not None:
            Kt = SO.StateGain(
                SO.QuaternionGain(1 / dt),
                SO.BodyRateGain(np.eye(3) * (1 / dt)))

            x_diff = x_err - self.last_err
            x_d_err = Kt * x_diff

            m_adj += self.K['d'] * x_d_err

        # Ending the update, set the changes and return the
        # moments for supply to the actuators
        self.x_e = x_err
        self.last_update = t
        self.last_err = x_err
        self.M = m_adj
        return self.M

    def __str__(self):
        """
        Pretty print of the PID

        :return: nice representation of the current instance
        :rtype: str
        """
        gains = [self.__class__.__name__,
            ' x_d %s' % self.x_d,
            ' x_e %s' % self.x_e]
        for G in self.K.iteritems():
            gains.append(' K%s %s' % G)
        return '\n'.join(gains)


class SMC(ControllerBase):
    """
    A sliding mode controller starts as a proportional controller, but
    is also offset by a saturation based function.

    Luenberger gain plus a saturation function
    M = L*x_e + K*1s(x_e)

    :param clock: system clock that can run at different speeds
    :type  clock: Metronome.Clock
    """

    def __init__(self, clock):
        ControllerBase.__init__(self, clock)

        # Zero out state integrator
        self.last_err = None
        self.L = None
        self.K = None
        self.S = None

    def set_L(self, L):
        """
        Set the Luenberger gain (proportional gain)

        :param L: Luenberger gain for proportional scaling of the error
        :type  L: StateOperator.StateToMoment
        """
        self.L = L

    def set_K(self, K):
        """
        Set the Luenberger gain (proportional gain)

        :param K: Gain to convert the saturated state to a moment
        :type  K: StateOperator.StateToMoment
        """
        self.K = K

    def set_S(self, S):
        """
        Saturation of the state.

        Body rates saturate as normal.  The quaternion saturates according
        to the rotational angle \theta

        :param S: Luenberger gain for proportional scaling of the error
        :type  S: StateOperator.StateSaturation
        """
        self.S = S

    def update(self, x_hat):
        """
        A new state estimate is available.

        :param x_hat: The estimated state
        :type  x_hat: State
        :return: The moment to push the state to the desired state
        :rtype: Moment
        """
        t = self.clock.tick()
        try:
            dt = t - self.last_update
        except TypeError:
            dt = 0

        # Calculate the state error and starting the empty moment
        x_err = State.StateError(self.x_d, x_hat)
        m_adj = State.Moment()

        # Include the proportional Luenberger/Proportional gain
        if self.L is not None:
            m_adj += self.L * x_err

        # Include the scaled saturation moment
        x_s = self.S * x_err
        m_adj += self.K * x_s

        # Ending the update, set the changes and return the
        # moments for supply to the actuators
        self.x_e = x_err
        self.last_update = t
        self.last_err = x_err
        self.M = m_adj
        return self.M

    def __str__(self):
        """
        Pretty print of the SMC

        :return: nice representation of the current instance
        :rtype: str
        """
        gains = [self.__class__.__name__,
            ' x_d %s' % self.x_d,
            ' x_e %s' % self.x_e]
        gains.append(' L %s' % self.L)
        gains.append(' K %s' % self.K)
        gains.append(' S %s' % self.S)
        return '\n'.join(gains)

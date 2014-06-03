"""
This module contains the algorithm that take the measured state from the
sensor model which jumps around a lot because of the noise in the originating
signal and attempts to eliminate the noise and create an accurate representation
of the true state of the system.

* input: measured state (x)
* output: estimated true state (x_hat)

Example::

    c = Metronome()
    k = 0.2
    Kp = StateGain(
        QuaternionGain(k),
        BodyRateGain([[k,0,0],[0,k,0],[0,0,k]]))

    pid = PID(c)
    pid.set_Kp(Kp)

    x = State(
        Quaternion([0,0,1],radians=np.pi/15),
        BodyRate([0.1,2,3]))
    x_hat = pid.update(x)

"""

import time
import numpy as np
from TSatPy import State
from TSatPy import StateOperator as SO


class Estimator(object):
    """
    Master estimator object.  Accepts state measurements and submits them
    to all configured estimators in parallel.  Multiple estimators can
    be setup to respond better under times of large disturbances and
    others in steady state then the "best" estimated state can be pushed
    to the controller.

    Example::

        # Setup a PID and SMO estimator to run in parallel
        clock = Metronome()
        configs = [{'type': 'pid',
         'args': {'kpq': 0.0735,'kpw': 0.7,'kiq': 0.000863,
                  'kiw': 0,'kdq': 0.00812,'kdw': 0}
        },{'type': 'smo',
         'args': {'Lq': 0.3619,'Lw': 0.3752,'Kq': 0.3076,
                   'Kw': 0.4994,'Sq': 0.4191,'Sw': 0.0052}}]

        est = Estimator(clock)
        for config in configs:
            est.add(config['type'], plant, config['args'])

        est.update(x_m)

    """

    def __init__(self, clock):
        self.clock = clock
        self.estimators = []

    def add(self, est_type, plant, kwargs):
        """
        Configure an estimator and add it to the estimators to receive
        measurement updates.

        :param est_type: class of estimator to configure (pid or smo)
        :type  est_type: str
        :param plant: A configured plant to be used in state propagation
        :type  plant: State.Plant
        :param kwargs: options to be used to configure the estimator
        :type  kwargs: dict
        """
        if est_type.lower() == 'pid':
            # Setup a PID estimator
            est = self.config_pid(plant, **kwargs)
        elif est_type.lower() == 'smo':
            # Setup a Sliding Mode Observer
            est = self.config_smo(plant, **kwargs)
        self.estimators.append(est)

    def config_smo(self, plant, Lq, Lw, Kq, Kw, Sq, Sw):
        """
        Configure the Sliding Mode Observer instance

        x(k+1) = f(x(k)) + L*x_e(k) + K*1s(x_e(k))

        :param plant: System plant used for state propagation
        :type  plant: State.Plant
        :param Lq: quaternion parameter for the Luenberger gain
        :type  Lq: numeric
        :param Lw: body rate parameter for the Luenberger gain
        :type  Lw: numeric
        :param Kq: quaternion parameter for gain applied to the saturated state
        :type  Kq: numeric
        :param Kw: body rate parameter for gain applied to the saturated state
        :type  Kw: numeric
        :param Sq: quaternion parameter for the state saturation
        :type  Sq: numeric
        :param Sw: body rate parameter for the state saturation
        :type  Sw: numeric
        :return: configured Sliding Mode Observer instance
        :rtype: SMO
        """

        # Setup the estimator gains and saturation instances
        L = SO.StateGain(
            SO.QuaternionGain(Lq),
            SO.BodyRateGain(np.eye(3) * Lw))
        K = SO.StateGain(
            SO.QuaternionGain(Kq),
            SO.BodyRateGain(np.eye(3) * Kw))
        Sx = SO.StateSaturation(
            SO.QuaternionSaturation(Sq),
            SO.BodyRateSaturation(Sw))

        # Initialize the estimator and set the gains/saturation
        smo = SMO(self.clock, plant=plant)
        smo.set_S(Sx)
        smo.set_L(L)
        smo.set_K(K)
        return smo

    def config_pid(self, plant, kpq, kpw, kiq, kiw, kdq, kdw):
        """
        Configure the PID estimator to accept updates

        :param plant: System plant used for state propagation
        :type  plant: State.Plant
        :param kpq: parameter for the proportional quaternion gain
        :type  kpq: numeric
        :param kpw: parameter for the proportional body rate gain
        :type  kpw: numeric
        :param kiq: parameter for the integral quaternion gain
        :type  kiq: numeric
        :param kiw: parameter for the integral body rate gain
        :type  kiw: numeric
        :param kdq: parametor for the derivative quaternion gain
        :type  kdq: numeric
        :param kdw: parameter for the derivative body rate gain
        :type  kdw: numeric
        :return: configured PID estimator
        :rtype: PID
        """

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

        :param x: a newly measured state
        :type  x: State.State
        :param M: The last applied moment
        :type  M: State.Moment
        """
        for idx in range(len(self.estimators)):
            self.estimators[idx].update(x=x, M=M)

    def __str__(self):
        """
        Pretty print of the Estimator master

        :return: nice representation of the current instance
        :rtype: str
        """
        est_str = [self.__class__.__name__]
        for est in self.estimators:
            est_str.append(str(est))
        return '\n'.join(est_str)


class EstimatorBase(object):
    """
    Base estimation methods to be extended upon

    :param clock: the system clock to track time passing and speed changes
    :type  clock: Clock.Metronome
    :param plant: System plant used for state propagation
    :type  plant: State.Plant
    :param ic: initial state for the estimator
    :type  ic: State.State
    """

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
        """
        Place holder method to be overridden.
        """
        pass


class PID(EstimatorBase):
    """
    A sliding mode observer takes the form of

    x(k+1) = f(x(k)) + Kp * xe + Ki * sum(xe) + Kd * (xe - xe_last)

    :param clock: system time piece
    :type  clock: Clock.Metronome
    :param kwargs: Addition arguments required for the EstimatorBase
    :type  kwargs: dict
    """

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

    def update(self, x, M=None):
        """
        A new state measurement in available

        :param x: The last measured state
        :type  x: State
        :param M: Moment applied to the system
        :type  M: State.Moment
        :return: The moment to push the state to the desired state
        :rtype: Moment
        """
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

        # Calculate the state error and starting the empty moment
        x_err = State.StateError(self.x_hat, x)
        x_adj = State.State()

        # Add the proportional adjustment
        if self.K['p'] is not None:
            x_adj += self.K['p'] * x_err

        # Add the integral adjustment
        if dt and self.K['i'] is not None:
            Kt = SO.StateGain(
                SO.QuaternionGain(dt),
                SO.BodyRateGain(np.eye(3) * dt))
            self.x_i += Kt * x_err

            x_adj += self.K['i'] * self.x_i

        # Add the derivative adjustment
        if dt and self.K['d'] is not None:
            Kt = SO.StateGain(
                SO.QuaternionGain(1 / dt),
                SO.BodyRateGain(np.eye(3) * (1 / dt)))

            x_diff = x_err - self.last_err
            x_d_err = Kt * x_diff

            x_adj += self.K['d'] * x_d_err

        # Ending the update, set the changes and return the
        # moments for supply to the actuators
        self.x_adj = x_adj
        self.x_hat = self.x_hat - x_adj
        if self.plant:
            self.plant.set_state(self.x_hat)
        self.last_update = t
        self.last_err = x_err
        return self.x_hat

    def __str__(self):
        """
        Pretty print of the PID

        :return: nice representation of the current instance
        :rtype: str
        """
        gains = [self.__class__.__name__, ' x_hat %s' % self.x_hat]
        for G in sorted(self.K.items()):
            gains.append(' K%s %s' % G)
        return '\n'.join(gains)


class SMO(EstimatorBase):
    """
    A sliding mode observer takes the form of

    x(k+1) = f(x(k)) + L*x_e(k) + K*1s(x_e(k))

    :param clock: system time piece
    :type  clock: Clock.Metronome
    :param kwargs: Addition arguments required for the EstimatorBase
    :type  kwargs: dict
    """

    def __init__(self, clock, **kwargs):
        EstimatorBase.__init__(self, clock, **kwargs)

        # Zero out state integrator
        self.last_err = None
        self.L = None
        self.K = None
        self.S = None

    def set_L(self, L):
        """
        Set the Luenberger gain for the estimator (Proportional gain)

        :param L: Luenberger gain
        :type  L: StateOperator.StateGain
        """
        self.L = L

    def set_K(self, K):
        """
        Set the state gain applied after the saturation function.

        :param K: state gain post saturation
        :type  K: StateOperator.StateGain
        """
        self.K = K

    def set_S(self, S):
        """
        Set the saturation instance.  This instance returns the same value
        when below a threshold and then caps the response when the threshold
        is exceeded.

        :param S: state saturation instance
        :type  S: StateOperator.StateSaturation
        """
        self.S = S

    def update(self, x, M=None):
        """
        A new measurement is available and/or a new moment is applied.
        Use the system plant provided along with the SMO estimation technique
        to try and clean up the signal and eliminate the noisy state prior
        to supplying the controller to compare against the desired state.

        :param x: measured state
        :type  x: State.State
        :param M: Moment thate was applied to the system (unforced if empty)
        :type  M: State.Moment
        :return: newest guess at the true system state
        :rtype: State.State
        """
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

        # Calculate the error between the last estimated state and
        # new state measurement
        x_err = State.StateError(self.x_hat, x)
        x_adj = State.State()

        # Apply the Luenberger proportional adjustment if specified
        if self.L is not None:
            x_l = self.L * x_err
            x_adj += x_l

        # Apply the saturated adjustment
        x_s = self.S * x_err
        x_ks = self.K * x_s
        x_adj += x_ks

        # Set the newly calculated values and update the plant's state
        # with the new state estimate.
        # TODO: update the body rate?
        self.x_adj = x_adj
        self.x_hat = self.x_hat - x_adj
        if self.plant:
            self.plant.set_state(self.x_hat)
        self.last_update = t
        self.last_err = x_err
        return self.x_hat

    def __str__(self):
        """
        Pretty print of the SMO

        :return: nice representation of the current instance
        :rtype: str
        """
        gains = [self.__class__.__name__, ' x_hat %s' % self.x_hat]
        gains.append(' L %s' % self.L)
        gains.append(' K %s' % self.K)
        gains.append(' S %s' % self.S)
        return '\n'.join(gains)

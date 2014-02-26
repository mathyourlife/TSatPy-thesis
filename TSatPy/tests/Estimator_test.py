import unittest
from TSatPy import State, StateOperators, Estimator
from TSatPy.Clock import Metronome
import numpy as np


class TestPID(unittest.TestCase):

    def test_p_controller(self):
        c = Metronome()
        k = 0.2
        Kq = StateOperators.QuaternionGain(k)
        Kw = StateOperators.BodyRateGain([[k,0,0],[0,k,0],[0,0,k]])
        Kp = StateOperators.StateGain(Kq, Kw)

        pid = Estimator.PID(c)
        pid.set_Kp(Kp)

        x = State.State(
            State.Quaternion([0,0,1],radians=np.pi/15),
            State.BodyRate([0.1,2,3])
        )
        x_hat = pid.update(x)

        x_expected = State.State(
            State.Quaternion([0,0,1],radians=np.pi/75),
            State.BodyRate([0.02,0.4,0.6]))

        self.assertEquals(x_hat, x_expected)


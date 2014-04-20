import unittest
from mock import patch
from TSatPy import State, StateOperators as SO, Controller
from TSatPy.Clock import Metronome
import numpy as np


class TestPID(unittest.TestCase):

    def test_str(self):
        c = Metronome()
        Kp = SO.BodyRateToMoment(np.eye(3) * 0.1)

        pid = Controller.PID(c)
        pid.set_Kp(Kp)

        str_expected = [
            'PID',
            ' x_d <Quaternion [0 0 0], 1>, <BodyRate [0 0 0]>',
            ' x_e <Quaternion [0 0 0], 1>, <BodyRate [0 0 0]>',
            ' Ki None',
            ' Kp <BodyRateToMoment <K [[ 0.1 0. 0. ] [ 0. 0.1 0. ] [ 0. 0. 0.1]]>>',
            ' Kd None',
        ]
        self.assertEquals('\n'.join(str_expected), str(pid))

    def test_body_rate_p_controller(self):
        c = Metronome()

        x_hat = State.State(
            State.Quaternion([0,0,1],radians=1),
            State.BodyRate([1,0,0.4]))
        x_d = State.State(
            State.Quaternion([0,0,1],radians=4),
            State.BodyRate([0,0,0.6]))

        Kp = SO.StateToMoment(
            None,
            SO.BodyRateToMoment(np.eye(3) * 0.1))

        pid = Controller.PID(c)
        pid.set_Kp(Kp)
        pid.set_desired_state(x_d)

        M = pid.update(x_hat)
        M_exp = State.Moment([0.1,0,-0.02])

        self.assertEquals(M_exp, M)

    def test_quaternion_p_controller(self):
        c = Metronome()

        x_hat = State.State(
            State.Quaternion([0,0,1],radians=1),
            State.BodyRate([1,0,0.4]))
        x_d = State.State(
            State.Quaternion([0,0,1],radians=4),
            State.BodyRate([0,0,0.6]))

        Kp = SO.StateToMoment(
            SO.QuaternionToMoment(0.2),
            None)

        pid = Controller.PID(c)
        pid.set_Kp(Kp)
        pid.set_desired_state(x_d)

        M = pid.update(x_hat)
        M_exp = State.Moment([0,0,0.6])

        self.assertEquals(M_exp, M)

    def test_p_controller(self):
        c = Metronome()

        x_hat = State.State(
            State.Quaternion([0,0,1],radians=1),
            State.BodyRate([1,0,0.4]))
        x_d = State.State(
            State.Quaternion([0,0,1],radians=4),
            State.BodyRate([0,0,0.6]))

        Kp = SO.StateToMoment(
            SO.QuaternionToMoment(0.2),
            SO.BodyRateToMoment(np.eye(3) * 0.1))

        pid = Controller.PID(c)
        pid.set_Kp(Kp)
        pid.set_desired_state(x_d)

        M = pid.update(x_hat)
        M_exp = State.Moment([0.1,0,-0.02]) + State.Moment([0,0,0.6])

        self.assertEquals(M_exp, M)



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
        M_exp = State.Moment([-0.1,0,0.02])

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
        M_exp = State.Moment([0,0,-0.6])

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
        M_exp = State.Moment([-0.1,0,0.02]) + State.Moment([0,0,-0.6])

        self.assertEquals(M_exp, M)


    @patch('time.time', return_value=13)
    def test_i_rate_control(self, mock_time):
        c = Metronome()
        x_hat = State.State(
            State.Quaternion([0,0,1],radians=1),
            State.BodyRate([1,0,0.4]))
        x_d = State.State(
            State.Quaternion([0,0,1],radians=4),
            State.BodyRate([0,0,0.6]))

        Ki = SO.StateToMoment(
            None,
            SO.BodyRateToMoment(np.eye(3) * 0.1))

        pid = Controller.PID(c)
        pid.set_Ki(Ki)
        pid.set_desired_state(x_d)

        mock_time.return_value = 13.5
        M = pid.update(x_hat)

        # first update, no last_update time so 0's
        self.assertEquals(M, State.Moment())

        mock_time.return_value = 14.25
        M = pid.update(x_hat)

        # Second update 0.75 sec later
        self.assertEquals(M,
            State.Moment([0.75 * 0.1 * -1, 0, 0.75 * 0.1 * 0.2]))

    @patch('time.time', return_value=13)
    def test_i_quaternion_control(self, mock_time):
        c = Metronome()
        x_hat = State.State(
            State.Quaternion([0,0,1],radians=1),
            State.BodyRate([1,0,0.4]))
        x_d = State.State(
            State.Quaternion([0,0,1],radians=4),
            State.BodyRate([0,0,0.6]))

        Ki = SO.StateToMoment(
            SO.QuaternionToMoment(0.3),
            None)

        pid = Controller.PID(c)
        pid.set_Ki(Ki)
        pid.set_desired_state(x_d)

        mock_time.return_value = 13.5
        M = pid.update(x_hat)

        # first update, no last_update time so 0's
        self.assertEquals(M, State.Moment())

        mock_time.return_value = 14.25
        M = pid.update(x_hat)

        # Second update 0.75 sec later
        self.assertEquals(M,
            State.Moment([0, 0, -3 * 1 * 0.3 * 0.75]))

    @patch('time.time', return_value=13)
    def test_i_quaternion_control(self, mock_time):
        c = Metronome()
        x_hat = State.State(
            State.Quaternion([0,0,1],radians=1),
            State.BodyRate([1,0,0.4]))
        x_d = State.State(
            State.Quaternion([0,0,1],radians=4),
            State.BodyRate([0,0,0.6]))

        Ki = SO.StateToMoment(
            SO.QuaternionToMoment(0.3),
            SO.BodyRateToMoment(np.eye(3) * 0.1))

        pid = Controller.PID(c)
        pid.set_Ki(Ki)
        pid.set_desired_state(x_d)

        mock_time.return_value = 13.5
        M = pid.update(x_hat)

        # first update, no last_update time so 0's
        self.assertEquals(M, State.Moment())

        mock_time.return_value = 14.25
        M = pid.update(x_hat)

        # Second update 0.75 sec later
        self.assertEquals(M,
            State.Moment([0, 0, -3 * 1 * 0.3 * 0.75]) +
            State.Moment([0.75 * 0.1 * -1, 0, 0.75 * 0.1 * 0.2]))

    @patch('time.time', return_value=13)
    def test_d_body_rate_no_time_elapse(self, mock_time):
        c = Metronome()
        x_hat = State.State(
            State.Quaternion([0,0,1],radians=1),
            State.BodyRate([1,0,0.4]))
        x_d = State.State(
            State.Quaternion([0,0,1],radians=4),
            State.BodyRate([0,0,0.6]))

        Kd = SO.StateToMoment(
            SO.QuaternionToMoment(0.3),
            SO.BodyRateToMoment(np.eye(3) * 0.1))

        pid = Controller.PID(c)
        pid.set_Kd(Kd)
        pid.set_desired_state(x_d)

        M = pid.update(x_hat)
        self.assertEquals(State.Moment(), M)
        M = pid.update(x_hat)
        self.assertEquals(State.Moment(), M)

    @patch('time.time')
    def test_d_estimator(self, mock_time):

        mock_time.return_value = 1234

        c = Metronome()
        x_d = State.State(
            State.Quaternion([0,0,1],radians=4),
            State.BodyRate([0,0,0.6]))

        Kd = SO.StateToMoment(
            SO.QuaternionToMoment(0.3),
            SO.BodyRateToMoment(np.eye(3) * 0.1))

        pid = Controller.PID(c)
        pid.set_Kd(Kd)
        pid.set_desired_state(x_d)

        mock_time.return_value = 1235
        x_hat = State.State(
            State.Quaternion([0,0,1],radians=1),
            State.BodyRate([1,0,0.4]))

        M = pid.update(x_hat)

        mock_time.return_value = 1235.5
        x_hat = State.State(
            State.Quaternion([0,0,1],radians=2),
            State.BodyRate([1,0.1,0.3]))

        M = pid.update(x_hat)
        M_expected = State.Moment([
            0 * 0.1 / 0.5,
            -0.1* 0.1 / 0.5,
            0.1  * 0.1 / 0.5,
        ]) + State.Moment([
            0, 0, 1 * 0.3 / 0.5
        ])
        self.assertEquals(M, M_expected)

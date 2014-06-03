import unittest
from mock import patch
from TSatPy import State, StateOperator as SO, Estimator
from TSatPy.Clock import Metronome
import numpy as np


class TestEstimator(unittest.TestCase):

    def test_init(self):
        c = Metronome()
        pid = Estimator.Estimator(c)
        self.assertEquals(pid.estimators, [])

    def test_add_pid(self):
        c = Metronome()
        config = {'type': 'pid',
         'args': {'kpq': 0.0735,'kpw': 0.7,'kiq': 0.000863,
                  'kiw': 0,'kdq': 0.00812,'kdw': 0}}
        x = State.State()
        I = [[4, 0, 0], [0, 4, 0], [0, 0, 4]]
        p = State.Plant(I, x, c)
        est = Estimator.Estimator(c)
        est.add(config['type'], p, config['args'])

        self.assertEquals(len(est.estimators), 1)
        self.assertEquals(type(est.estimators[0]), Estimator.PID)

    def test_add_smo(self):
        c = Metronome()
        config = {'type': 'smo',
         'args': {'Lq': 0.3619,'Lw': 0.3752,'Kq': 0.3076,
                   'Kw': 0.4994,'Sq': 0.4191,'Sw': 0.0052}}
        x = State.State()
        I = [[4, 0, 0], [0, 4, 0], [0, 0, 4]]
        p = State.Plant(I, x, c)

        est = Estimator.Estimator(c)
        est.add(config['type'], p, config['args'])

        self.assertEquals(len(est.estimators), 1)
        self.assertEquals(type(est.estimators[0]), Estimator.SMO)

    @patch('TSatPy.Estimator.SMO.update')
    @patch('TSatPy.Estimator.PID.update')
    def test_all_updates(self, mock_pid_update, mock_smo_update):
        c = Metronome()
        configs = [{'type': 'pid',
         'args': {'kpq': 0.0735,'kpw': 0.7,'kiq': 0.000863,
                  'kiw': 0,'kdq': 0.00812,'kdw': 0}
        },{'type': 'smo',
         'args': {'Lq': 0.3619,'Lw': 0.3752,'Kq': 0.3076,
                   'Kw': 0.4994,'Sq': 0.4191,'Sw': 0.0052}}]
        x = State.State()
        I = [[4, 0, 0], [0, 4, 0], [0, 0, 4]]
        p = State.Plant(I, x, c)
        est = Estimator.Estimator(c)
        for config in configs:
            est.add(config['type'], p, config['args'])

        self.assertEquals(len(est.estimators), 2)

        self.assertFalse(mock_pid_update.called)
        self.assertFalse(mock_smo_update.called)

        est.update(x)

        self.assertTrue(mock_pid_update.called)
        self.assertTrue(mock_smo_update.called)

    def test_str(self):
        c = Metronome()
        config = {'type': 'pid',
         'args': {'kpq': 0.0735,'kpw': 0.7,'kiq': 0.000863,
                  'kiw': 0,'kdq': 0.00812,'kdw': 0}}
        x = State.State()
        I = [[4, 0, 0], [0, 4, 0], [0, 0, 4]]
        p = State.Plant(I, x, c)
        est = Estimator.Estimator(c)
        self.assertEquals('Estimator', str(est))
        est.add(config['type'], p, config['args'])

        msg = """Estimator
PID
 x_hat <Quaternion [0 0 0], 1>, <BodyRate [0 0 0]>
 Kd <StateGain <Kq 0.00812>, <Kw = [[ 0. 0. 0.] [ 0. 0. 0.] [ 0. 0. 0.]]>>
 Ki <StateGain <Kq 0.000863>, <Kw = [[ 0. 0. 0.] [ 0. 0. 0.] [ 0. 0. 0.]]>>
 Kp <StateGain <Kq 0.0735>, <Kw = [[ 0.7 0. 0. ] [ 0. 0.7 0. ] [ 0. 0. 0.7]]>>"""
        self.assertEquals(msg, str(est))


class TestPID(unittest.TestCase):

    def test_str(self):
        k = 3
        c = Metronome()
        Kq = SO.QuaternionGain(k)
        Kw = SO.BodyRateGain([[k,0,0],[0,k,0],[0,0,k]])
        Kp = SO.StateGain(Kq, Kw)

        pid = Estimator.PID(c)
        pid.set_Kp(Kp)

        str_expected = [
            'PID',
            ' x_hat <Quaternion [0 0 0], 1>, <BodyRate [0 0 0]>',
            ' Kd None',
            ' Ki None',
            ' Kp <StateGain <Kq 3>, <Kw = [[3 0 0] [0 3 0] [0 0 3]]>>',
        ]
        self.assertEquals('\n'.join(str_expected), str(pid))

    def test_p_estimator(self):
        c = Metronome()
        k = 0.2
        Kq = SO.QuaternionGain(k)
        Kw = SO.BodyRateGain([[k,0,0],[0,k,0],[0,0,k]])
        Kp = SO.StateGain(Kq, Kw)

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

    def test_p_estimator_with_ic(self):
        c = Metronome()
        k = 0.2
        Kq = SO.QuaternionGain(k)
        Kw = SO.BodyRateGain([[k,0,0],[0,k,0],[0,0,k]])
        Kp = SO.StateGain(Kq, Kw)
        ic = State.State(
            State.Quaternion([0,0,1],radians=0.1),
            State.BodyRate([0,0,1])
        )

        pid = Estimator.PID(c, ic=ic)
        pid.set_Kp(Kp)

        x = State.State(
            State.Quaternion([0,0,1],radians=0.6),
            State.BodyRate([0.1,2,3])
        )
        x_hat = pid.update(x)

        x_expected = State.State(
            State.Quaternion([0,0,1],radians=0.2),
            State.BodyRate([0.02,0.4,1.4]))

        self.assertEquals(x_hat, x_expected)

    @patch('time.time')
    def test_i_estimator(self, mock_time):

        mock_time.return_value = 1234

        c = Metronome()
        k = 0.5
        Kq = SO.QuaternionGain(k)
        Kw = SO.BodyRateGain([[k,0,0],[0,k,0],[0,0,k]])
        Ki = SO.StateGain(Kq, Kw)

        pid = Estimator.PID(c)
        pid.set_Ki(Ki)

        mock_time.return_value = 1235

        x = State.State(
            State.Quaternion([0,0,1],radians=0.1),
            State.BodyRate([0.1,2,3])
        )

        # No state adjustment off ic on first update
        x_hat = pid.update(x)
        self.assertEquals(x_hat, State.State())

        dt = 1.2
        mock_time.return_value = 1236.2

        # Update integral estimate after 1.2 sec with a 0.5 gain
        x_hat = pid.update(x)
        x_hat_expected = State.State(
            State.Quaternion([0,0,1],radians=0.1 * dt * k),
            State.BodyRate([
                0.1 * dt * k,
                2 * dt * k,
                3 * dt * k,
            ])
        )

        self.assertEquals(x_hat, x_hat_expected)

    @patch('time.time')
    def test_d_estimator_no_time_change(self, mock_time):

        mock_time.return_value = 1234

        c = Metronome()

        k = 4
        Kd = SO.StateGain(
            SO.QuaternionGain(k),
            SO.BodyRateGain([[k,0,0],[0,k,0],[0,0,k]]))

        pid = Estimator.PID(c)
        pid.set_Kd(Kd)

        x = State.State(
            State.Quaternion([0,0,1],radians=np.pi/15),
            State.BodyRate([0.1,2,3])
        )

        x_hat = pid.update(x)
        self.assertEquals(State.State(), x_hat)
        x_hat = pid.update(x)
        self.assertEquals(State.State(), x_hat)

    @patch('time.time')
    def test_d_estimator(self, mock_time):

        mock_time.return_value = 1234

        c = Metronome()
        k = 3
        Kd = SO.StateGain(
            SO.QuaternionGain(k),
            SO.BodyRateGain([[k,0,0],[0,k,0],[0,0,k]]))

        pid = Estimator.PID(c)
        pid.set_Kd(Kd)

        mock_time.return_value = 1235

        x = State.State(
            State.Quaternion([0,0,1],radians=0.4),
            State.BodyRate([0.1,2,3])
        )
        x_hat = pid.update(x)

        x = State.State(
            State.Quaternion([0,0,1],radians=0.6),
            State.BodyRate([0.2,2.2,2.5])
        )
        mock_time.return_value = 1235.5

        x_hat = pid.update(x)

        x_hat_expected = State.State(
            State.Quaternion(
                [0,0,1],
                radians=0.2 * 3 / 0.5
            ),
            State.BodyRate([
                0.1 * 3 / 0.5,
                0.2 * 3 / 0.5,
                -0.5  * 3 / 0.5,
            ])
        )
        self.assertEquals(x_hat, x_hat_expected)

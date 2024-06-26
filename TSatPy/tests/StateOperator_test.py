import unittest
from mock import patch
from TSatPy import State, StateOperator
import numpy as np


class TestBodyRateGain(unittest.TestCase):
    def test_init(self):
        G = StateOperator.BodyRateGain([[1,0],[0,1]])
        self.assertTrue(np.all(G.K == np.mat([[1,0],[0,1]])))

    def test_str(self):
        G = StateOperator.BodyRateGain([[1,0],[0,1]])
        g_str = '[[1 0] [0 1]]'
        self.assertEquals(g_str, str(G))

    def test_mul(self):
        w = State.BodyRate([1,-1,0])
        G = StateOperator.BodyRateGain([[1,2,3],[4,5,6],[10,8,9]])
        w_new = G * w
        w_expected = State.BodyRate([-1,-1,2])
        self.assertEquals(w_expected, w_new)


class TestQuaternionGain(unittest.TestCase):
    def test_init(self):
        G = StateOperator.QuaternionGain(0.5)
        self.assertEquals(G.K, 0.5)

    def test_str(self):
        G = StateOperator.QuaternionGain(0.5)
        g_str = '0.5'
        self.assertEquals(g_str, str(G))

    def test_gain(self):
        q = State.Quaternion([0,0,1], radians=np.pi/10)
        qg = StateOperator.QuaternionGain(0.25)
        q_new = (qg * q)
        q_expected = State.Quaternion([0,0,1], radians=np.pi/40)
        self.assertEquals(q_new, q_expected)

    def test_identity(self):
        q = State.Identity()
        qg = StateOperator.QuaternionGain(0.25)
        q_new = (qg * q)
        q_expected = State.Identity()
        self.assertEquals(q_new, q_expected)

    def test_floating_point_domain_error(self):
        q = State.Quaternion([0,0,0], 1 + 2.22044604925e-16)
        qg = StateOperator.QuaternionGain(0.25)
        q_new = (qg * q)
        q_expected = State.Identity()
        self.assertEquals(q_new, q_expected)

        q = State.Quaternion([0,0,0], -1 - 2.22044604925e-16)
        qg = StateOperator.QuaternionGain(0.25)
        q_new = (qg * q)
        q_expected = State.Identity()
        self.assertEquals(q_new, q_expected)

        q = State.Quaternion([0,0,1E-14], 1)
        qg = StateOperator.QuaternionGain(0.25)
        q_new = (qg * q)
        q_expected = State.Identity()
        self.assertEquals(q_new, q_expected)


class TestStateGain(unittest.TestCase):
    def test_init(self):
        Kq = StateOperator.QuaternionGain(0.5)
        Kw = StateOperator.BodyRateGain([[1,0],[0,1]])
        Kx = StateOperator.StateGain(Kq, Kw)
        self.assertEquals(Kx.Kq, Kq)
        self.assertEquals(Kx.Kw, Kw)

    def test_str(self):
        Kq = StateOperator.QuaternionGain(0.5)
        Kw = StateOperator.BodyRateGain([[1,0],[0,1]])
        Kx = StateOperator.StateGain(Kq, Kw)
        g_str = '<StateGain <Kq 0.5>, <Kw = [[1 0] [0 1]]>>'
        self.assertEquals(g_str, str(Kx))

    def test_gain(self):
        w = State.BodyRate([1,-1,0])
        q = State.Quaternion([0,0,1], radians=np.pi/10)
        x = State.State(q, w)
        Kq = StateOperator.QuaternionGain(0.25)
        Kw = StateOperator.BodyRateGain([[1,2,3],[4,5,6],[10,8,9]])
        Kx = StateOperator.StateGain(Kq, Kw)

        w_expected = State.BodyRate([-1,-1,2])
        q_expected = State.Quaternion([0,0,1], radians=np.pi/40)
        x_expected = State.State(q_expected, w_expected)

        self.assertEquals(x_expected, Kx * x)

    def test_no_Kq(self):
        w = State.BodyRate([1,-1,0])
        q = State.Quaternion([0,0,1], radians=np.pi/10)
        x = State.State(q, w)
        Kw = StateOperator.BodyRateGain([[1,2,3],[4,5,6],[10,8,9]])
        Kx = StateOperator.StateGain(None, Kw)

        w_expected = State.BodyRate([-1,-1,2])
        q_expected = State.Identity()
        x_expected = State.State(q_expected, w_expected)

        self.assertEquals(x_expected, Kx * x)

    def test_no_Kw(self):
        w = State.BodyRate([1,-1,0])
        q = State.Quaternion([0,0,1], radians=np.pi/10)
        x = State.State(q, w)
        Kq = StateOperator.QuaternionGain(0.25)
        Kx = StateOperator.StateGain(Kq, None)

        w_expected = State.BodyRate()
        q_expected = State.Quaternion([0,0,1], radians=np.pi/40)
        x_expected = State.State(q_expected, w_expected)

        self.assertEquals(x_expected, Kx * x)



class TestQuaternionSaturation(unittest.TestCase):

    def test_init(self):
        s = StateOperator.QuaternionSaturation(4)
        self.assertEquals(4.0, s.rho)

    def test_str(self):
        s = StateOperator.QuaternionSaturation(4)
        self.assertEquals('<QuaternionSaturation <rho 4.0>>', str(s))

    def test_limit(self):
        s = StateOperator.QuaternionSaturation(1.1)

        # Positive quaternion angle below the threshold
        q = State.Quaternion([0,0,1], radians=0.7)
        q_sat = s * q
        self.assertEquals(State.Quaternion([0,0,1], radians=0.7/1.1), q_sat)

        # Positive quaternion angle above the threshold
        q = State.Quaternion([0,0,1], radians=1.7)
        q_sat = s * q
        self.assertEquals(State.Quaternion([0,0,1], radians=1), q_sat)

        # Negative quaternion angle below the threshold
        q = State.Quaternion([0,0,1], radians=-0.7)
        q_sat = s * q
        self.assertEquals(State.Quaternion([0,0,1], radians=-0.7/1.1), q_sat)

        # Negative quaternion angle above the threshold
        q = State.Quaternion([0,0,1], radians=-1.7)
        q_sat = s * q
        self.assertEquals(State.Quaternion([0,0,1], radians=-1), q_sat)

        # Positive quaternion angle greater than 180
        q = State.Quaternion([0,0,1], radians=4)
        q_sat = s * q
        self.assertEquals(State.Quaternion([0,0,1], radians=-1), q_sat)

        # Negative quaternion angle less than -180
        q = State.Quaternion([0,0,1], radians=-4)
        q_sat = s * q
        self.assertEquals(State.Quaternion([0,0,1], radians=1), q_sat)


class TestBodyRateSaturation(unittest.TestCase):

    def test_init(self):
        s = StateOperator.BodyRateSaturation(0.3)
        self.assertEquals(s.rho, 0.3)

    def test_str(self):
        s = StateOperator.BodyRateSaturation(2)
        self.assertEquals('<BodyRateSaturation <rho 2.0>>', str(s))

    def test_limit(self):
        s = StateOperator.BodyRateSaturation(1.3)

        w = State.BodyRate([-1,-2,3])
        w_sat = s * w
        self.assertEquals(State.BodyRate([-1/1.3,-1,1]), w_sat)



class TestStateSaturation(unittest.TestCase):

    def test_init(self):
        Sq = StateOperator.QuaternionSaturation(4)
        Sw = StateOperator.BodyRateSaturation(0.3)
        Sx = StateOperator.StateSaturation(Sq, Sw)
        self.assertEquals(4.0, Sx.Sq.rho)
        self.assertTrue(np.all(Sx.Sw.rho == np.mat([0.3,0.3,0.3]).T))

    def test_str(self):
        Sq = StateOperator.QuaternionSaturation(4)
        Sw = StateOperator.BodyRateSaturation(0.3)
        Sx = StateOperator.StateSaturation(Sq, Sw)

        msg = '<StateSaturation <Sq <QuaternionSaturation <rho 4.0>>>, ' \
            '<Sw = <BodyRateSaturation <rho 0.3>>>>'
        self.assertEquals(str(Sx), msg)

    def test_limit(self):
        Sq = StateOperator.QuaternionSaturation(1.1)
        Sw = StateOperator.BodyRateSaturation(1.3)
        Sx = StateOperator.StateSaturation(Sq, Sw)

        x = State.State(
            State.Quaternion([0,0,1], radians=1.7),
            State.BodyRate([-1,-2,3]))
        x_sat = Sx * x
        x_expected = State.State(
            State.Quaternion([0,0,1], radians=1),
            State.BodyRate([-1/1.3,-1,1]))

        self.assertEquals(x_expected, x_sat)

    def test_no_q(self):
        Sw = StateOperator.BodyRateSaturation(1.3)
        Sx = StateOperator.StateSaturation(None, Sw)

        x = State.State(
            State.Quaternion([0,0,1], radians=1.7),
            State.BodyRate([-1,-2,3]))
        x_sat = Sx * x
        x_expected = State.State(
            State.Quaternion([0,0,1], radians=1.7),
            State.BodyRate([-1/1.3,-1,1]))

        self.assertEquals(x_expected, x_sat)

    def test_no_w(self):
        Sq = StateOperator.QuaternionSaturation(1.1)
        Sx = StateOperator.StateSaturation(Sq, None)

        x = State.State(
            State.Quaternion([0,0,1], radians=1.7),
            State.BodyRate([-1,-2,3]))
        x_sat = Sx * x
        x_expected = State.State(
            State.Quaternion([0,0,1], radians=1),
            State.BodyRate([-1,-2,3]))

        self.assertEquals(x_expected, x_sat)


class TestQuaternionToMoment(unittest.TestCase):

    def test_init(self):
        qm = StateOperator.QuaternionToMoment(0.4)
        self.assertEquals(0.4, qm.K)

    def test_str(self):
        qm = StateOperator.QuaternionToMoment(0.4)
        msg = '<QuaternionToMoment <K 0.4>>'
        self.assertEquals(str(qm), msg)

    def test_mul(self):
        qm = StateOperator.QuaternionToMoment(0.5)

        q = State.Quaternion([0.1, -0.2, 0], radians=3)

        M = qm * q
        v = q.vector / np.sqrt(q.vector.T * q.vector)
        self.assertTrue(np.all(M.M == (-v * 0.5 * 3)))


class TestBodyRateToMoment(unittest.TestCase):

    def test_init(self):
        br2m = StateOperator.BodyRateToMoment(np.eye(3) * 3.2)
        self.assertTrue(np.all(br2m.K == np.eye(3) * 3.2))

    def test_str(self):
        br2m = StateOperator.BodyRateToMoment(np.eye(3) * 3.2)
        str_expected = '<BodyRateToMoment <K [[ 3.2 0. 0. ] ' \
            '[ 0. 3.2 0. ] [ 0. 0. 3.2]]>>'
        self.assertEquals(str_expected, str(br2m))

    def test_mul(self):
        br2m = StateOperator.BodyRateToMoment(np.eye(3) * 3.2)
        w = State.BodyRate([3, -1, 8])
        self.assertEquals(br2m * w, State.Moment([9.6, -3.2, 25.6]))


class TestStateToMoment(unittest.TestCase):

    def test_init(self):
        qm = StateOperator.QuaternionToMoment(0.4)
        br2m = StateOperator.BodyRateToMoment(np.eye(3) * 3.2)
        xm = StateOperator.StateToMoment(qm, br2m)

        self.assertEquals(0.4, xm.Kq.K)
        self.assertTrue(np.all(xm.Kw.K == np.eye(3) * 3.2))

    def test_str(self):
        qm = StateOperator.QuaternionToMoment(0.4)
        br2m = StateOperator.BodyRateToMoment(np.eye(3) * 3.2)
        xm = StateOperator.StateToMoment(qm, br2m)

        msg = '<StateToMoment <Kq <QuaternionToMoment <K 0.4>>>, ' \
            '<Kw = <BodyRateToMoment <K [[ 3.2 0. 0. ] ' \
            '[ 0. 3.2 0. ] [ 0. 0. 3.2]]>>>>'
        self.assertEquals(str(xm), msg)

    def test_mul(self):
        qm = StateOperator.QuaternionToMoment(0.5)
        br2m = StateOperator.BodyRateToMoment(np.eye(3) * 3.2)
        xm = StateOperator.StateToMoment(qm, br2m)

        q = State.Quaternion([0.1, -0.2, 0], radians=3)
        w = State.BodyRate([3, -1, 8])
        x = State.State(q, w)

        v = q.vector / np.sqrt(q.vector.T * q.vector)
        M = State.Moment(-v * 0.5 * 3)
        M += State.Moment([9.6, -3.2, 25.6])

        self.assertEquals(xm * x, M)

    def test_no_kq(self):
        br2m = StateOperator.BodyRateToMoment(np.eye(3) * 3.2)
        xm = StateOperator.StateToMoment(None, br2m)

        q = State.Quaternion([0.1, -0.2, 0], radians=3)
        w = State.BodyRate([3, -1, 8])
        x = State.State(q, w)

        M = State.Moment([9.6, -3.2, 25.6])

        self.assertEquals(xm * x, M)

    def test_no_kw(self):
        qm = StateOperator.QuaternionToMoment(0.5)
        xm = StateOperator.StateToMoment(qm, None)

        q = State.Quaternion([0.1, -0.2, 0], radians=3)
        w = State.BodyRate([3, -1, 8])
        x = State.State(q, w)

        v = q.vector / np.sqrt(q.vector.T * q.vector)
        M = State.Moment(-v * 0.5 * 3)

        self.assertEquals(xm * x, M)


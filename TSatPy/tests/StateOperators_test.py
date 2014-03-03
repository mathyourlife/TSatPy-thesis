import unittest
from mock import patch
from TSatPy import State, StateOperators, Clock
import numpy as np


class TestBodyRateGain(unittest.TestCase):
    def test_init(self):
        G = StateOperators.BodyRateGain([[1,0],[0,1]])
        self.assertTrue(np.all(G.K == np.mat([[1,0],[0,1]])))

    def test_str(self):
        G = StateOperators.BodyRateGain([[1,0],[0,1]])
        g_str = '[[1 0] [0 1]]'
        self.assertEquals(g_str, str(G))

    def test_mul(self):
        w = State.BodyRate([1,-1,0])
        G = StateOperators.BodyRateGain([[1,2,3],[4,5,6],[10,8,9]])
        w_new = G * w
        w_expected = State.BodyRate([-1,-1,2])
        self.assertEquals(w_expected, w_new)


class TestQuaternionGain(unittest.TestCase):
    def test_init(self):
        G = StateOperators.QuaternionGain(0.5)
        self.assertEquals(G.K, 0.5)

    def test_str(self):
        G = StateOperators.QuaternionGain(0.5)
        g_str = '0.5'
        self.assertEquals(g_str, str(G))

    def test_gain(self):
        q = State.Quaternion([0,0,1], radians=np.pi/10)
        qg = StateOperators.QuaternionGain(0.25)
        q_new = (qg * q)
        q_expected = State.Quaternion([0,0,1], radians=np.pi/40)
        self.assertEquals(q_new, q_expected)

    def test_identity(self):
        q = State.Identity()
        qg = StateOperators.QuaternionGain(0.25)
        q_new = (qg * q)
        q_expected = State.Identity()
        self.assertEquals(q_new, q_expected)


class TestStateGain(unittest.TestCase):
    def test_init(self):
        Kq = StateOperators.QuaternionGain(0.5)
        Kw = StateOperators.BodyRateGain([[1,0],[0,1]])
        Kx = StateOperators.StateGain(Kq, Kw)
        self.assertEquals(Kx.Kq, Kq)
        self.assertEquals(Kx.Kw, Kw)

    def test_str(self):
        Kq = StateOperators.QuaternionGain(0.5)
        Kw = StateOperators.BodyRateGain([[1,0],[0,1]])
        Kx = StateOperators.StateGain(Kq, Kw)
        g_str = '<StateGain <Kq 0.5>, <Kw = [[1 0] [0 1]]>>'
        self.assertEquals(g_str, str(Kx))

    def test_gain(self):
        w = State.BodyRate([1,-1,0])
        q = State.Quaternion([0,0,1], radians=np.pi/10)
        x = State.State(q, w)
        Kq = StateOperators.QuaternionGain(0.25)
        Kw = StateOperators.BodyRateGain([[1,2,3],[4,5,6],[10,8,9]])
        Kx = StateOperators.StateGain(Kq, Kw)

        w_expected = State.BodyRate([-1,-1,2])
        q_expected = State.Quaternion([0,0,1], radians=np.pi/40)
        x_expected = State.State(q_expected, w_expected)

        self.assertEquals(x_expected, Kx * x)

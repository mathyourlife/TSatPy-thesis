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
        g_str = '[[1 0]\n [0 1]]'
        self.assertTrue(g_str, str(G))

    def test_mul(self):
        w = State.BodyRate([1,-1,0])
        G = StateOperators.BodyRateGain([[1,2,3],[4,5,6],[10,8,9]])
        w_new = G * w
        w_expected = State.BodyRate([-1,-1,2])
        self.assertEquals(w_expected, w_new)

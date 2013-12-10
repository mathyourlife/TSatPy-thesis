import unittest
from TSatPy.Quaternion import Quaternion
import numpy as np


class TestQuaternionBasics(unittest.TestCase):

    def test_init(self):
        vec = [1, 2, 3]
        q = Quaternion(vec,  4)
        self.assertTrue(np.all(vec == q.vector))
        self.assertEquals(4, q.scalar)

    def test_mag(self):
        vec = [1, 2, 3]
        q = Quaternion(vec,  4)
        self.assertEquals(np.sqrt(30), q.mag())

    def test_normalize(self):
        vec = [1, 2, 3]
        q = Quaternion(vec,  4)
        q.normalize()

        m = np.sqrt(30)
        t_vec = [1/m, 2/m, 3/m]
        self.assertTrue(np.all(t_vec == q.vector))
        self.assertEquals(4/m, q.scalar)

    def test_conj(self):

        vec = [1, 2, 3]
        q = Quaternion(vec,  4)

        r = q.conj()
        self.assertTrue(np.all([-1, -2, -3] == r.vector))
        self.assertEquals(4, r.scalar)

    def test_str(self):
        vec = [1, 2, 3]
        q = Quaternion(vec,  4)

        q_str = '<Quaternion <1 2 3>, 4>'

        self.assertEquals(q_str, str(q))

    def test_definition(self):

        i = Quaternion([1,0,0],0)
        j = Quaternion([0,1,0],0)
        k = Quaternion([0,0,1],0)
        q_neg = Quaternion([0,0,0],-1)

        self.assertEquals(i*i, q_neg)
        self.assertEquals(j*j, q_neg)
        self.assertEquals(k*k, q_neg)
        self.assertEquals(i*j*k, q_neg)
        self.assertEquals(i*j, k)
        self.assertEquals(j*k, i)
        self.assertEquals(k*i, j)

def within_threshold(a, b):
    return (a-b).mag() < 1e-15

class TestQuaternionOperations(unittest.TestCase):

    def test_add(self):
        a = Quaternion([1,0.2,-3], 0.3)
        b = Quaternion([2,0.1,-2], 0.8)

        self.assertTrue(
            within_threshold(
                a + b,
                Quaternion([3.0, 0.3, -5.0], 1.1)
            ))

        a += b
        self.assertTrue(
            within_threshold(
                a,
                Quaternion([3.0, 0.3, -5.0], 1.1)
            ))

    def test_sub(self):
        a = Quaternion([1,0.2,-3], 0.3)
        b = Quaternion([2,0.1,-2], 0.8)
        self.assertTrue(
            within_threshold(
                a - b,
                Quaternion([-1, 0.1, -1], -0.5)
            ))

        a -= b
        self.assertTrue(
            within_threshold(
                a,
                Quaternion([-1, 0.1, -1], -0.5)
            ))


class TestQuaternionAngles(unittest.TestCase):

    def test_from_rotation(self):
        q = Quaternion([0,0,1],radians=0)
        self.assertEquals(Quaternion([0,0,0],1), q)

    def test_partial_turn(self):
        q1 = Quaternion([0,0,1],radians=np.pi/2)
        q2 = Quaternion([0,0,1],radians=np.pi/2 + np.pi * 2)

        self.assertTrue(
            within_threshold(q1, -q2)
        )


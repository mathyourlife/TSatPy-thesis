import unittest
from TSatPy.Quaternion import Quaternion, Identity
import numpy as np


class TestQuaternionBasics(unittest.TestCase):

    def test_init(self):
        vec = np.mat([1, 2, 3]).T
        q = Quaternion([1, 2, 3],  4)

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
        t_vec = np.mat([1/m, 2/m, 3/m]).T
        self.assertTrue(np.all(t_vec == q.vector))
        self.assertEquals(4/m, q.scalar)

    def test_conj(self):

        vec = [1, 2, 3]
        q = Quaternion(vec,  4)

        r = q.conj()
        self.assertTrue(np.all(np.matrix([-1, -2, -3]).T == r.vector))
        self.assertEquals(4, r.scalar)

    def test_str(self):
        vec = [1, 2, 3]
        q = Quaternion(vec,  4)

        q_str = '<Quaternion <1 2 3>, 4>'

        self.assertEquals(q_str, str(q))

    def test_definition(self):

        i = Quaternion([1, 0, 0], 0)
        j = Quaternion([0, 1, 0], 0)
        k = Quaternion([0, 0, 1], 0)
        q_neg = Quaternion([0, 0, 0], -1)

        self.assertEquals(i*i, q_neg)
        self.assertEquals(j*j, q_neg)
        self.assertEquals(k*k, q_neg)
        self.assertEquals(i*j*k, q_neg)
        self.assertEquals(i*j, k)
        self.assertEquals(j*k, i)
        self.assertEquals(k*i, j)


def within_threshold(a, b):
    return (a-b).mag() < Quaternion.float_threshold


class TestQuaternionOperations(unittest.TestCase):

    def test_eq(self):

        a = Quaternion([1, 2, -3], 0.4)
        b = Quaternion([1, 2, -3], 0.4)
        self.assertEquals(a, b)

        a = Quaternion([1, 2, -3], 0.4)
        b = Quaternion([-1, -2, 3], -0.4)
        self.assertEquals(a, b)

        a = Quaternion([1, 2, -3], -0.4)
        b = Quaternion([-1, -2, 3], -0.4)
        self.assertFalse(a == b)

    def test_neq(self):

        a = Quaternion([1, 2, -3], -0.4)
        b = Quaternion([-1, -2, 3], -0.4)
        self.assertNotEquals(a, b)

    def test_add(self):
        a = Quaternion([1, 0.2, -3], 0.3)
        b = Quaternion([2, 0.1, -2], 0.8)

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
        a = Quaternion([1, 0.2, -3], 0.3)
        b = Quaternion([2, 0.1, -2], 0.8)
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

    def test_mul(self):
        a = Quaternion([1, 2, -3], 4)
        b = Quaternion([2, -1, -4], 1)

        # q = a * b
        # scalar = a.scalar * b.scalar - dot(a.vector, b.vector)
        # vector = a.vector * b.scalar + b.vector * a.scalar + cross(a.vector,b.vector)

        truth = Quaternion([-2, -4, -24], -8)
        self.assertEquals(a * b, truth)

    def test_x(self):
        q = Quaternion([1, 2, 3], 4)
        truth = np.mat([
            [0, -3, 2],
            [3, 0, -1],
            [-2, 1, 0],
        ], dtype=np.float)

        self.assertTrue((q.x == truth).all())


class TestQuaternionAngles(unittest.TestCase):

    def test_from_rotation(self):
        q = Quaternion([0, 0, 1], radians=0)
        self.assertEquals(Quaternion([0, 0, 0], 1), q)

    def test_partial_turn(self):
        q1 = Quaternion([0, 0, 1], radians=np.pi/2)
        q2 = Quaternion([0, 0, 1], radians=np.pi/2 + np.pi * 2)

        self.assertTrue(
            within_threshold(q1, -q2)
        )

    def test_is_unit(self):

        units = [
            ([1, 0, 0], 0),
            ([0, 0, 0], 1),
            ([0, -1/np.sqrt(2), 0], -1/np.sqrt(2)),
        ]
        for unit in units:
            q = Quaternion(*unit)
            self.assertTrue(q.is_unit())

        non_units = [
            ([2, 0, 0], 0),
            ([0, 0, 0], 2),
            ([0, -1/np.sqrt(2), 0.1], -1/np.sqrt(2)),
        ]
        for non_unit in non_units:
            q = Quaternion(*non_unit)
            self.assertFalse(q.is_unit())

    def test_rotational_matrix(self):

        # Test a 1/4 turn about the z axis
        q = Quaternion([0, 0, 1], radians=np.pi/2)

        pt = np.mat([1, 0, 1]).T
        truth = np.mat([0, 1, 1]).T

        new_pt = q.rmatrix * pt
        self.assertLess(np.sum(np.abs(new_pt - truth)), Quaternion.float_threshold)

        # Test a -1/2 turn about the x axis
        q = Quaternion([1, 0, 0], radians=-np.pi)

        pt = np.mat([0.2, 0.5, 1]).T
        truth = np.mat([0.2, -0.5, -1]).T

        new_pt = q.rmatrix * pt

        self.assertLess(np.sum(np.abs(new_pt - truth)), Quaternion.float_threshold)

    def test_rotate_points(self):

        # Rotate a couple points 1/4 turn about the +z axis
        pts = np.mat([
            [1, 0, 1],
            [0.2, 0.5, 1],
        ])

        q = Quaternion([0, 0, 1], radians=np.pi/2)

        new_pts = q.rotate_points(pts)

        truth = np.mat([
            [0, 1, 1],
            [-0.5, 0.2, 1],
        ])

        self.assertLess(np.sum(np.abs(new_pts - truth)), Quaternion.float_threshold)

        pts = np.mat([
            [1, 0, 0],
            [0, 1, 0],
        ])
        q = Quaternion([1, 0, 0], radians=-np.pi/4)

        new_pts = q.rotate_points(pts)

        truth = np.mat([
            [1, 0, 0],
            [0, 1/np.sqrt(2), -1/np.sqrt(2)],
        ])

        for idx, pt in enumerate(truth):
            self.assertLess(
                np.sum(np.abs(new_pts[idx, :] - truth[idx, :])),
                Quaternion.float_threshold
            )

    def test_rotate_from_compound_quaternion(self):

        q1 = Quaternion([0, 0, 1], radians=np.pi/2)
        q2 = Quaternion([1, 0, 0], radians=np.pi/2)

        q = q2 * q1

        pts = np.mat([
            [1, 0, 0],
            [1, 0, 1],
            [0.2, 0.5, 1],
        ])

        new_pts = q.rotate_points(pts)

        truth = np.mat([
            [0, 1, 0],
            [1, 1, 0],
            [1, 0.2, 0.5],
        ])

        for idx, pt in enumerate(truth):
            self.assertLess(
                np.sum(np.abs(new_pts[idx, :] - truth[idx, :])),
                Quaternion.float_threshold
            )


class TestIdentityQuaternion(unittest.TestCase):

    def test_identity(self):

        a = Identity()
        b = Quaternion([0, 0, 0], 1)

        self.assertEquals(a, b)

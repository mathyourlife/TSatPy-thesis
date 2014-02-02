import unittest
from mock import patch
from TSatPy.State import Quaternion, Identity, QuaternionDynamics, BodyRate, Plant, EulerMomentEquations
from TSatPy.Clock import Metronome
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
        q_str = '<Quaternion [1 2 3], 4>'
        self.assertEquals(q_str, str(q))

    def test_latex(self):
        vec = [1, 2, 3]
        q = Quaternion(vec,  4)
        q_str = '1 \\textbf{i} +2 \\textbf{j} +3 \\textbf{k} +4'
        self.assertEquals(q_str, q.latex())


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

    def test_decompose(self):

        qr = Quaternion([0, 0, 1], radians=np.pi/4)
        qn = Quaternion([3, 1, 0], radians=np.pi/10)

        q = qn * qr

        qr_check, qn_check = q.decompose()

        self.assertEquals(qn, qn_check)
        self.assertEquals(qr, qr_check)


class TestIdentityQuaternion(unittest.TestCase):

    def test_identity(self):
        a = Identity()
        b = Quaternion([0, 0, 0], 1)

        self.assertEquals(a, b)


class TestQuaternionDynamics(unittest.TestCase):

    def test_init(self):
        clock = Metronome()
        q = Quaternion([0, 0, 1], radians=0)
        qd = QuaternionDynamics(q, clock)

        self.assertEquals(q, qd.q)
        self.assertEquals(Quaternion([0, 0, 0], 0), qd.q_dot)

    @patch('time.time', return_value=12)
    def test_propagate_from_default(self, MockTime):
        # Initialize the system clock
        clock = Metronome()

        # Setup for 1/4 turn each sec about the +z axis
        q = Quaternion([0, 0, 1], radians=0)
        qd = QuaternionDynamics(q, clock)
        w = BodyRate([0, 0, np.pi/2])

        # First propagation is a gimmie since last time is not set
        # no dt know since the initialization time of the instance may
        # not be trustworthy for simulations
        MockTime.return_value = 13
        q = qd.propagate(w)
        self.assertEquals(q, Quaternion([0, 0, 1], radians=0))

        # First quater turn happens on the second propagation call
        MockTime.return_value = 14
        q = qd.propagate(w)
        self.assertEquals(q, Quaternion([0, 0, 1], radians=np.pi/2))

    @patch('time.time', return_value=12)
    def test_propagate_non_default_state(self, MockTime):
        # Initialize the system clock
        clock = Metronome()

        # Setup for 1/4 turn each sec about the +z axis
        q = Quaternion([0, 0, 1], radians=np.pi/2)
        qd = QuaternionDynamics(q, clock)
        w = BodyRate([0, 0, np.pi/2])

        # First propagation is a gimmie since last time is not set
        # no dt know since the initialization time of the instance may
        # not be trustworthy for simulations
        MockTime.return_value = 13
        q = qd.propagate(w)
        self.assertEquals(q, Quaternion([0, 0, 1], radians=np.pi/2))

        # First quater turn happens on the second propagation call
        MockTime.return_value = 14
        q = qd.propagate(w)
        self.assertEquals(q, Quaternion([0, 0, 1], radians=np.pi))

    @patch('time.time', return_value=12)
    def test_propagate_linearinterpolate_body_rate(self, MockTime):
        # Initialize the system clock
        clock = Metronome()

        # Setup for 1/4 turn each sec about the +z axis
        q = Quaternion([0, 0, 1], radians=np.pi/2)
        qd = QuaternionDynamics(q, clock)
        w = BodyRate([0, 0, np.pi/2])

        MockTime.return_value = 13
        q = qd.propagate(w)
        MockTime.return_value = 14
        q = qd.propagate(w)
        MockTime.return_value = 15
        q = qd.propagate(w)

        self.assertEquals(q, Quaternion([0, 0, 1], radians=1.5 * np.pi))

    @patch('time.time', return_value=12)
    def test_zero_dt(self, MockTime):
        # Initialize the system clock
        clock = Metronome()

        # Setup for 1/4 turn each sec about the +z axis
        q = Quaternion([0, 0, 1], radians=np.pi/2)
        qd = QuaternionDynamics(q, clock)
        w = BodyRate([0, 0, np.pi/2])

        q = qd.propagate(w)
        q = qd.propagate(w)

        self.assertEquals(q, Quaternion([0, 0, 1], radians=np.pi/2))


class TestBodyRate(unittest.TestCase):

    def test_body_rate(self):
        w_check = np.mat([1, 2, 3]).T
        w = BodyRate([1, 2, 3])

        self.assertTrue(np.all(w_check == w.w))

    def test_add(self):
        w1 = BodyRate([1, 2, 3])
        w2 = BodyRate([4, -2, 5])
        w3 = w1 + w2
        self.assertEquals(w3, BodyRate([5, 0, 8]))

    def test_iadd(self):
        w1 = BodyRate([1, 2, 3])
        pre_id = id(w1)
        w2 = BodyRate([4, -2, 5])
        w1 += w2
        self.assertEquals(w1, BodyRate([5, 0, 8]))
        self.assertEquals(pre_id, id(w1))

    def test_x(self):
        w = BodyRate([1, 2, 3])
        test = np.mat([[0, -3,  2],
                       [3,  0, -1],
                       [-2,  1,  0]])

        self.assertTrue(np.all(test == w.x))

    def test_str(self):
        w = BodyRate([1, -2, 3.5])
        self.assertEquals('<BodyRate [1 -2 3.5]>', str(w))

    def test_latex(self):
        w = BodyRate([1, -2, 3.5])
        self.assertEquals('1 \\textbf{i} -2 \\textbf{j} +3.5 \\textbf{k}', w.latex())

class TestEulerMomentEquations(unittest.TestCase):

    @patch('time.time', return_value=12)
    def test_moment_equations_init(self, MockTime):
        # Initialize the system clock
        clock = Metronome()

        # Setup for 1/4 turn each sec about the +z axis
        w = BodyRate([0.5, 0.1, 0.75])
        eme = EulerMomentEquations([[5, 0, 0], [0, 4, 0], [0, 0, 2.25]], w, clock)

        # Initial propagate to set the last time updated
        MockTime.return_value = 13
        w = eme.propagate([-0.08125, 1.15125, 1.075])
        self.assertEquals(w, BodyRate([0.5, 0.1, 0.75]))

        # First propagate
        MockTime.return_value = 14
        w = eme.propagate([-0.08125, 1.15125, 1.075])

        # Some floating point errors exist so account for slight variations
        w_check = BodyRate([0.51, 0.13, 1.25])
        self.assertLess(np.sum(np.abs(w.w - w_check.w)), 1e-14)


class TestPlant(unittest.TestCase):

    def test_plant_init(self):
        clock = Metronome()
        q = Quaternion([0, 0, 1], radians=np.pi/2)
        w = BodyRate([0, 0, np.pi/4])
        I = [[4,0,0],[0,4,0],[0,0,4]]

        p = Plant(I, q, w, clock)

    def test_str(self):
        clock = Metronome()
        q = Quaternion([-0.5, -2.5, 1], -3)
        w = BodyRate([0, 0, -2])
        I = [[4,0,0],[0,4,0],[0,0,4]]

        p = Plant(I, q, w, clock)
        expected = '<Plant <Quaternion [-0.5 -2.5 1], -3>, <BodyRate [0 0 -2]>>'
        self.assertEquals(str(p), expected)

    def test_latex(self):
        clock = Metronome()
        q = Quaternion([-0.5, -2.5, 1], -3)
        w = BodyRate([0, 0, -2])
        I = [[4,0,0],[0,4,0],[0,0,4]]

        p = Plant(I, q, w, clock)
        expected = {
            'q': '-0.5 \\textbf{i} -2.5 \\textbf{j} +1 \\textbf{k} -3',
            'w': '0 \\textbf{i} +0 \\textbf{j} -2 \\textbf{k}',
        }
        self.assertEquals(p.latex(), expected)

    @patch('time.time', return_value=12)
    def test_propagate(self, MockTime):
        clock = Metronome()

        dt = 0.1
        duration = 4
        end_time = clock.tick() + duration

        q = Quaternion([0, 0, 1], radians=0)
        w = BodyRate([0, 0, 0])
        I = [[2, 0, 0], [0, 2, 0], [0, 0, 2]]

        p = Plant(I, q, w, clock)

        while clock.tick() <= end_time:
            MockTime.return_value += dt
            p.propagate([0, 0, 10])

        err = np.sum(np.abs(p.vel.w.w - BodyRate([0,0,20]).w))

        self.assertLess(err, 1e-12)


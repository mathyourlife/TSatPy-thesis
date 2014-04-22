import unittest
from mock import patch
from TSatPy import State
from TSatPy.Clock import Metronome
import numpy as np


class TestQuaternionBasics(unittest.TestCase):

    def test_init(self):
        vec = np.mat([1, 2, 3]).T
        q = State.Quaternion([1, 2, 3],  4)

        self.assertTrue(np.all(vec == q.vector))
        self.assertEquals(4, q.scalar)

    def test_mag(self):
        vec = [1, 2, 3]
        q = State.Quaternion(vec,  4)
        self.assertEquals(np.sqrt(30), q.mag)

    def test_normalize(self):
        vec = [1, 2, 3]
        q = State.Quaternion(vec,  4)
        q.normalize()

        m = np.sqrt(30)
        t_vec = np.mat([1/m, 2/m, 3/m]).T
        self.assertTrue(np.all(t_vec == q.vector))
        self.assertEquals(4/m, q.scalar)

    def test_conj(self):
        vec = [1, 2, 3]
        q = State.Quaternion(vec,  4)

        r = q.conj
        self.assertTrue(np.all(np.matrix([-1, -2, -3]).T == r.vector))
        self.assertEquals(4, r.scalar)

    def test_str(self):
        vec = [1, 2, 3]
        q = State.Quaternion(vec,  4)
        q_str = '<Quaternion [1 2 3], 4>'
        self.assertEquals(q_str, str(q))

    def test_latex(self):
        vec = [1, 2, 3]
        q = State.Quaternion(vec,  4)
        q_str = r'1 \boldsymbol{i} +2 \boldsymbol{j} +3 \boldsymbol{k} +4'
        self.assertEquals(q_str, q.latex())

    def test_definition(self):
        i = State.Quaternion([1, 0, 0], 0)
        j = State.Quaternion([0, 1, 0], 0)
        k = State.Quaternion([0, 0, 1], 0)
        q_neg = State.Quaternion([0, 0, 0], -1)

        self.assertEquals(i*i, q_neg)
        self.assertEquals(j*j, q_neg)
        self.assertEquals(k*k, q_neg)
        self.assertEquals(i*j*k, q_neg)
        self.assertEquals(i*j, k)
        self.assertEquals(j*k, i)
        self.assertEquals(k*i, j)


def within_threshold(a, b):
    return (a-b).mag < State.Quaternion.float_threshold


class TestQuaternionOperations(unittest.TestCase):

    def test_eq(self):
        a = State.Quaternion([1, 2, -3], 0.4)
        b = State.Quaternion([1, 2, -3], 0.4)
        self.assertEquals(a, b)

        a = State.Quaternion([1, 2, -3], radians=0.1)
        b = State.Quaternion([-1, -2, 3], radians=-0.1)
        self.assertEquals(a, b)

        a = State.Quaternion([1, 2, -3], radians=0.1)
        b = State.Quaternion([-1, -2, 3], radians=0.1)
        self.assertFalse(a == b)

    def test_neq(self):
        a = State.Quaternion([1, 2, -3], -0.4)
        b = State.Quaternion([-1, -2, 3], -0.4)
        self.assertNotEquals(a, b)

    def test_add(self):
        a = State.Quaternion([0, 0, 1], radians=2*np.pi/10)
        b = State.Quaternion([0, 0, 1], radians=3*np.pi/10)

        self.assertEquals(
            a + b,
            State.Quaternion([0, 0, 1], radians=5*np.pi/10)
        )

    def test_iadd(self):
        a = State.Quaternion([0, 0, 1], radians=2*np.pi/10)
        pre_id = id(a)
        b = State.Quaternion([0, 0, 1], radians=3*np.pi/10)

        a += b
        self.assertEquals(
            a,
            State.Quaternion([0, 0, 1], radians=5*np.pi/10)
        )
        self.assertEquals(pre_id, id(a))

    def test_sub(self):
        a = State.Quaternion([0, 0, 1], radians=5*np.pi/10)
        b = State.Quaternion([0, 0, 1], radians=3*np.pi/10)

        self.assertEquals(
            a - b,
            State.Quaternion([0, 0, 1], radians=2*np.pi/10)
        )

    def test_isub(self):
        a = State.Quaternion([0, 0, 1], radians=5*np.pi/10)
        pre_id = id(a)
        b = State.Quaternion([0, 0, 1], radians=3*np.pi/10)

        a -= b
        self.assertEquals(
            a,
            State.Quaternion([0, 0, 1], radians=2*np.pi/10)
        )
        self.assertEquals(pre_id, id(a))

    def test_mul(self):
        a = State.Quaternion([1, 2, -3], 4)
        b = State.Quaternion([2, -1, -4], 1)

        # q = a * b
        # scalar = a.scalar * b.scalar - dot(a.vector, b.vector)
        # vector = a.vector * b.scalar + b.vector * a.scalar + cross(a.vector,b.vector)

        truth = State.Quaternion([-2, -4, -24], -8)
        self.assertEquals(a * b, truth)

    def test_x(self):
        q = State.Quaternion([1, 2, 3], 4)
        truth = np.mat([
            [0, -3, 2],
            [3, 0, -1],
            [-2, 1, 0],
        ], dtype=np.float)

        self.assertTrue((q.x == truth).all())


class TestQuaternionAngles(unittest.TestCase):

    def test_from_rotation(self):
        q = State.Quaternion([0, 0, 1], radians=0)
        self.assertEquals(State.Quaternion([0, 0, 0], 1), q)

    def test_to_rotation(self):
        vector = [np.sqrt(1/2.0), -np.sqrt(1/3.0), np.sqrt(1/6.0)]
        radians = 1.4

        q = State.Quaternion(vector, radians=radians)
        v, r =  q.to_rotation()

        r_err = np.abs(r - radians)
        self.assertTrue(r_err < State.Quaternion.float_threshold)

        dot = np.abs(np.dot(np.mat(vector), v)[0, 0])
        vector_err = np.abs(dot - 1)
        self.assertTrue(vector_err < State.Quaternion.float_threshold)

    def test_idenitiy_to_rotation(self):
        q = State.Identity()
        v, r = q.to_rotation()

        r_err = np.abs(r - 0)
        self.assertTrue(r_err < State.Quaternion.float_threshold)
        self.assertTrue(np.all(np.mat([0,0,0]).T == v))

    def test_to_rotation_scalar_float(self):
        q = State.Quaternion([0,0,0], 1 + 1E15)
        e, r = q.to_rotation()
        self.assertEquals(r, 0)

        q = State.Quaternion([0,0,0], -1 - 1E15)
        e, r = q.to_rotation()
        self.assertEquals(r, 2 * np.pi)

    def test_partial_turn(self):
        q1 = State.Quaternion([0, 0, 1], radians=np.pi/2)
        q2 = State.Quaternion([0, 0, 1], radians=np.pi/2 + np.pi * 2)
        self.assertEquals(q1, -q2)

    def test_is_unit(self):
        units = [
            ([1, 0, 0], 0),
            ([0, 0, 0], 1),
            ([0, -1/np.sqrt(2), 0], -1/np.sqrt(2)),
        ]
        for unit in units:
            q = State.Quaternion(*unit)
            self.assertTrue(q.is_unit())

        non_units = [
            ([2, 0, 0], 0),
            ([0, 0, 0], 2),
            ([0, -1/np.sqrt(2), 0.1], -1/np.sqrt(2)),
        ]
        for non_unit in non_units:
            q = State.Quaternion(*non_unit)
            self.assertFalse(q.is_unit())

    def test_rotational_matrix(self):
        # Test a 1/4 turn about the z axis
        q = State.Quaternion([0, 0, 1], radians=np.pi/2)

        pt = np.mat([1, 0, 1]).T
        truth = np.mat([0, 1, 1]).T

        new_pt = q.rmatrix * pt
        self.assertLess(np.sum(np.abs(new_pt - truth)), State.Quaternion.float_threshold)

        # Test a -1/2 turn about the x axis
        q = State.Quaternion([1, 0, 0], radians=-np.pi)

        pt = np.mat([0.2, 0.5, 1],).T
        truth = np.mat([0.2, -0.5, -1]).T

        new_pt = q.rmatrix * pt

        self.assertLess(np.sum(np.abs(new_pt - truth)), State.Quaternion.float_threshold)

    def test_rotate_points(self):
        # Rotate a couple points 1/4 turn about the +z axis
        pts = np.mat([
            [1, 0, 1],
            [0.2, 0.5, 1],
        ])

        q = State.Quaternion([0, 0, 1], radians=np.pi/2)

        new_pts = q.rotate_points(pts)

        truth = np.mat([
            [0, 1, 1],
            [-0.5, 0.2, 1],
        ])

        self.assertLess(np.sum(np.abs(new_pts - truth)), State.Quaternion.float_threshold)

        pts = np.mat([
            [1, 0, 0],
            [0, 1, 0],
        ])
        q = State.Quaternion([1, 0, 0], radians=-np.pi/4)

        new_pts = q.rotate_points(pts)

        truth = np.mat([
            [1, 0, 0],
            [0, 1/np.sqrt(2), -1/np.sqrt(2)],
        ])

        for idx, pt in enumerate(truth):
            self.assertLess(
                np.sum(np.abs(new_pts[idx, :] - truth[idx, :])),
                State.Quaternion.float_threshold
            )

    def test_rotate_from_compound_quaternion(self):
        q1 = State.Quaternion([0, 0, 1], radians=np.pi/2)
        q2 = State.Quaternion([1, 0, 0], radians=np.pi/2)

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
                State.Quaternion.float_threshold
            )

    def test_decompose(self):
        qr = State.Quaternion([0, 0, 1], radians=np.pi/4)
        qn = State.Quaternion([3, 1, 0], radians=np.pi/10)
        q = qn * qr
        qr_check, qn_check = q.decompose()

        self.assertEquals(qn, qn_check)
        self.assertEquals(qr, qr_check)

    def test_decompose_rotation_only(self):
        qr = State.Quaternion([0, 0, 1], radians=np.pi/4)
        qn = State.Identity()
        q = qn * qr
        qr_check, qn_check = q.decompose()

        self.assertEquals(qn, qn_check)
        self.assertEquals(qr, qr_check)


class TestQuaternionError(unittest.TestCase):

    def test_small_error(self):
        v = [1, -2, 4]

        q_hat = State.Quaternion(v, radians=4 * np.pi / 10.0)
        q = State.Quaternion(v, radians=3 * np.pi / 10.0)
        qe_expected = State.Quaternion(v, radians=1 * np.pi / 10.0)
        qe = State.QuaternionError(q_hat, q)

        self.assertEquals(qe, qe_expected)

    def test_large_error(self):
        v = [1, -2, 4]

        q_hat = State.Quaternion(v, radians=3 * np.pi / 10.0)
        q = State.Quaternion(v, radians=18 * np.pi / 10.0)

        # The shorter quaternion is actually going backwards
        qe_expected = State.Quaternion(v, radians=5 * np.pi / 10.0)
        qe = State.QuaternionError(q_hat, q)

        self.assertEquals(qe, qe_expected)


class TestIdentityQuaternion(unittest.TestCase):

    def test_identity(self):
        a = State.Identity()
        b = State.Quaternion([0, 0, 0], 1)

        self.assertEquals(a, b)


class TestQuaternionDynamics(unittest.TestCase):

    def test_init(self):
        clock = Metronome()
        q = State.Quaternion([0, 0, 1], radians=0)
        qd = State.QuaternionDynamics(q, clock)
        self.assertEquals(q, qd.q)

    @patch('time.time', return_value=12)
    def test_propagate_from_default(self, MockTime):
        # Initialize the system clock
        clock = Metronome()

        # Setup for 1/4 turn each sec about the +z axis
        q = State.Quaternion([0, 0, 1], radians=0)
        qd = State.QuaternionDynamics(q, clock)
        w = State.BodyRate([0, 0, np.pi/2])

        # First propagation is a gimmie since last time is not set
        # no dt know since the initialization time of the instance may
        # not be trustworthy for simulations
        MockTime.return_value = 13
        q = qd.propagate(w)
        self.assertEquals(q, State.Quaternion([0, 0, 1], radians=0))

        # First quater turn happens on the second propagation call
        MockTime.return_value = 14
        q = qd.propagate(w)
        self.assertEquals(q, State.Quaternion([0, 0, 1], radians=np.pi/2))

    @patch('time.time', return_value=12)
    def test_propagate_non_default_state(self, MockTime):
        # Initialize the system clock
        clock = Metronome()

        inc = np.pi / 10

        # Setup for 1/4 turn each sec about the +z axis
        q = State.Quaternion([0, 0, 1], radians=inc * 3)
        qd = State.QuaternionDynamics(q, clock)
        w = State.BodyRate([0, 0, inc])

        # First propagation is a gimmie since last time is not set
        # no dt know since the initialization time of the instance may
        # not be trustworthy for simulations
        MockTime.return_value = 13
        q = qd.propagate(w)
        self.assertEquals(q, State.Quaternion([0, 0, 1], radians=inc * 3))

        # First quater turn happens on the second propagation call
        MockTime.return_value = 14
        q = qd.propagate(w)
        self.assertEquals(q, State.Quaternion([0, 0, 1], radians=inc * 4))

    @patch('time.time', return_value=12)
    def test_propagate_linearinterpolate_body_rate(self, MockTime):
        # Initialize the system clock
        clock = Metronome()

        inc = np.pi / 10

        # Setup for 1/4 turn each sec about the +z axis
        q = State.Quaternion([0, 0, 1], radians=inc * 3)
        qd = State.QuaternionDynamics(q, clock)
        w = State.BodyRate([0, 0, inc])

        MockTime.return_value = 13
        q = qd.propagate(w)
        MockTime.return_value = 14
        q = qd.propagate(w)
        MockTime.return_value = 15
        q = qd.propagate(w)
        q_check = State.Quaternion([0, 0, 1], radians=inc * 5)
        self.assertEquals(q, q_check)

    @patch('time.time', return_value=12)
    def test_zero_dt(self, MockTime):
        # Initialize the system clock
        clock = Metronome()

        # Setup for 1/4 turn each sec about the +z axis
        q = State.Quaternion([0, 0, 1], radians=np.pi/2)
        qd = State.QuaternionDynamics(q, clock)
        w = State.BodyRate([0, 0, np.pi/2])

        q = qd.propagate(w)
        q = qd.propagate(w)

        self.assertEquals(q, State.Quaternion([0, 0, 1], radians=np.pi/2))


class TestBodyRate(unittest.TestCase):

    def test_body_rate(self):
        w_check = np.mat([1, 2, 3]).T
        w = State.BodyRate([1, 2, 3])

        self.assertTrue(np.all(w_check == w.w))

    def test_add(self):
        w1 = State.BodyRate([1, 2, 3])
        w2 = State.BodyRate([4, -2, 5])
        w3 = w1 + w2
        self.assertEquals(w3, State.BodyRate([5, 0, 8]))

    def test_iadd(self):
        w1 = State.BodyRate([1, 2, 3])
        pre_id = id(w1)
        w2 = State.BodyRate([4, -2, 5])
        w1 += w2
        self.assertEquals(w1, State.BodyRate([5, 0, 8]))
        self.assertEquals(pre_id, id(w1))

    def test_x(self):
        w = State.BodyRate([1, 2, 3])
        test = np.mat([[0, -3,  2],
                       [3,  0, -1],
                       [-2,  1,  0]])

        self.assertTrue(np.all(test == w.x))

    def test_str(self):
        w = State.BodyRate([1, -2, 3.5])
        self.assertEquals('<BodyRate [1 -2 3.5]>', str(w))

    def test_latex(self):
        w = State.BodyRate([1, -2, 3.5])
        latex = r'1 \boldsymbol{i} -2 \boldsymbol{j} +3.5 \boldsymbol{k}'
        self.assertEquals(latex, w.latex())


class TestEulerMomentEquations(unittest.TestCase):

    @patch('time.time', return_value=12)
    def test_moment_equations_init(self, MockTime):
        # Initialize the system clock
        clock = Metronome()

        # Setup for 1/4 turn each sec about the +z axis
        w = State.BodyRate([0.5, 0.1, 0.75])
        eme = State.EulerMomentEquations([[5, 0, 0], [0, 4, 0], [0, 0, 2.25]], w, clock)

        # Initial propagate to set the last time updated
        MockTime.return_value = 13
        M = State.Moment([-0.08125, 1.15125, 1.075])
        w = eme.propagate(M)
        self.assertEquals(w, State.BodyRate([0.5, 0.1, 0.75]))

        # First propagate
        MockTime.return_value = 14
        M = State.Moment([-0.08125, 1.15125, 1.075])
        w = eme.propagate(M)

        # Some floating point errors exist so account for slight variations
        w_check = State.BodyRate([0.51, 0.13, 1.25])
        self.assertLess(np.sum(np.abs(w.w - w_check.w)), 1e-14)


class TestState(unittest.TestCase):

    def test_state_init(self):
        x1 = State.State()
        q = State.Quaternion([0,0,0],1)
        w = State.BodyRate([0,0,0])
        x2 = State.State(q,w)

        self.assertEquals(x1, x2)

    def test_str(self):
        q = State.Quaternion([1,2,3],4)
        w = State.BodyRate([5,6,7])
        x = State.State(q, w)
        x_str = '<Quaternion [1 2 3], 4>, <BodyRate [5 6 7]>'
        self.assertEquals(x_str, str(x))

    def test_add(self):
        q1 = State.Quaternion([0,0,1],radians=2*np.pi/10)
        w1 = State.BodyRate([5,6,7])
        x1 = State.State(q1, w1)
        q2 = State.Quaternion([0,0,1],radians=3*np.pi/10)
        w2 = State.BodyRate([-3,1,0])
        x2 = State.State(q2, w2)

        q = State.Quaternion([0,0,1],radians=5*np.pi/10)
        w = State.BodyRate([2,7,7])
        x = State.State(q, w)

        self.assertEquals(x, x1 + x2)

    def test_iadd(self):
        q1 = State.Quaternion([0,0,1],radians=2*np.pi/10)
        w1 = State.BodyRate([5,6,7])
        x1 = State.State(q1, w1)
        pre_id = id(x1)
        q2 = State.Quaternion([0,0,1],radians=3*np.pi/10)
        w2 = State.BodyRate([-3,1,0])
        x2 = State.State(q2, w2)

        x1 += x2

        q = State.Quaternion([0,0,1],radians=5*np.pi/10)
        w = State.BodyRate([2,7,7])
        x = State.State(q, w)

        self.assertEquals(x, x1)
        self.assertEquals(pre_id, id(x1))

    def test_sub(self):
        q1 = State.Quaternion([0,0,1],radians=5*np.pi/10)
        w1 = State.BodyRate([2,7,7])
        x1 = State.State(q1, w1)
        q2 = State.Quaternion([0,0,1],radians=3*np.pi/10)
        w2 = State.BodyRate([-3,1,0])
        x2 = State.State(q2, w2)

        q = State.Quaternion([0,0,1],radians=2*np.pi/10)
        w = State.BodyRate([5,6,7])
        x = State.State(q, w)

        self.assertEquals(x, x1 - x2)

    def test_isub(self):
        q1 = State.Quaternion([0,0,1],radians=5*np.pi/10)
        w1 = State.BodyRate([2,7,7])
        x1 = State.State(q1, w1)
        pre_id = id(x1)
        q2 = State.Quaternion([0,0,1],radians=3*np.pi/10)
        w2 = State.BodyRate([-3,1,0])
        x2 = State.State(q2, w2)

        x1 -= x2

        q = State.Quaternion([0,0,1],radians=2*np.pi/10)
        w = State.BodyRate([5,6,7])
        x = State.State(q, w)

        self.assertEquals(x, x1)
        self.assertEquals(pre_id, id(x1))

    def test_latex(self):
        vec = [1, 2, 3]
        q = State.Quaternion(vec,  4)
        w = State.BodyRate([1, -2, 3.5])
        x = State.State(q, w)

        latex = (r'1 \boldsymbol{i} +2 \boldsymbol{j} +3 \boldsymbol{k} +4',
            r'1 \boldsymbol{i} -2 \boldsymbol{j} +3.5 \boldsymbol{k}')
        self.assertEquals(latex, x.latex())


class TestStateError(unittest.TestCase):
    def test_state_error(self):
        x_hat = State.State(
            State.Quaternion([0,0,1],radians=np.pi/10),
            State.BodyRate([1,-2,3]))
        x = State.State(
            State.Quaternion([0,0,1],radians=np.pi/15),
            State.BodyRate([0.1,2,3]))
        x_err_expected = State.State(
            State.Quaternion([0,0,1],radians=np.pi/30),
            State.BodyRate([0.9,-4,0]))
        x_err = State.StateError(x_hat, x)

        self.assertEquals(x_err_expected, x_err)



class TestPlant(unittest.TestCase):

    def test_plant_init(self):
        clock = Metronome()
        q = State.Quaternion([0, 0, 1], radians=np.pi/2)
        w = State.BodyRate([0, 0, np.pi/4])
        x = State.State(q, w)
        I = [[4, 0, 0], [0, 4, 0], [0, 0, 4]]

        p = State.Plant(I, x, clock)
        self.assertEquals(p.x, x)

    def test_str(self):
        clock = Metronome()
        q = State.Quaternion([-0.5, -2.5, 1], -3)
        w = State.BodyRate([0, 0, -2])
        x = State.State(q, w)
        I = [[4, 0, 0], [0, 4, 0], [0, 0, 4]]

        p = State.Plant(I, x, clock)
        expected = '<Plant <Quaternion [-0.5 -2.5 1], -3>, <BodyRate [0 0 -2]>>'
        self.assertEquals(str(p), expected)

    def test_latex(self):
        clock = Metronome()
        q = State.Quaternion([-0.5, -2.5, 1], -3)
        w = State.BodyRate([0, 0, -2])
        x = State.State(q, w)
        I = [[4, 0, 0], [0, 4, 0], [0, 0, 4]]

        p = State.Plant(I, x, clock)
        expected = {
            'q': r'-0.5 \boldsymbol{i} -2.5 \boldsymbol{j} +1 \boldsymbol{k} -3',
            'w': r'0 \boldsymbol{i} +0 \boldsymbol{j} -2 \boldsymbol{k}',
        }
        self.assertEquals(p.latex(), expected)

    @patch('time.time', return_value=12)
    def test_propagate(self, MockTime):
        clock = Metronome()

        dt = 0.1
        duration = 4
        end_time = clock.tick() + duration

        x = State.State(
            State.Quaternion([0, 0, 1], radians=0),
            State.BodyRate([0, 0, 0]))
        I = [[2, 0, 0], [0, 2, 0], [0, 0, 2]]

        p = State.Plant(I, x, clock)

        M = State.Moment([0, 0, 10])
        while clock.tick() <= end_time:
            MockTime.return_value += dt
            p.propagate(M)

        err = np.sum(np.abs(p.vel.w.w - State.BodyRate([0, 0, 20]).w))

        self.assertLess(err, 1e-12)

    def test_set_state(self):

        clock = Metronome()
        I = [[2, 0, 0], [0, 2, 0], [0, 0, 2]]
        p = State.Plant(I, State.State(), clock)

        x = State.State(
            State.Quaternion([2, 4, 1], radians=4),
            State.BodyRate([3, 4, 5]))

        p.set_state(x)

        self.assertEquals(p.x, x)

    @patch('time.time', return_value=12)
    def test_propagate(self, MockTime):
        clock = Metronome()
        x = State.State(
            State.Quaternion([0, 5, 1], radians=40),
            State.BodyRate([0, 0, 1]))
        I = [[2, 0, 0], [0, 2, 0], [0, 0, 2]]
        p = State.Plant(I, x, clock)

        x_pre = p.x
        p.propagate()

        self.assertEquals(p.x, x_pre)

class TestMoment(unittest.TestCase):

    def test_init(self):
        M = State.Moment([1,2,3])
        self.assertTrue(np.all(M.M == np.mat([1,2,3]).T))
        M = State.Moment()
        self.assertTrue(np.all(M.M == np.mat([0,0,0]).T))

    def test_moment_sum_diff(self):
        M1 = State.Moment([1,-2,3])
        M2 = State.Moment([3,-5,6])

        self.assertEquals(M1 + M2, State.Moment([4,-7,9]))
        self.assertEquals(M1 - M2, State.Moment([-2,3,-3]))

    def test_iadd(self):
        M1 = State.Moment([1,-2,3])
        M2 = State.Moment([3,-5,6])

        m1id = id(M1)
        M1 += M2

        self.assertEquals(m1id, id(M1))
        self.assertEquals(M1, State.Moment([4,-7,9]))

    def test_iadd(self):
        M1 = State.Moment([1,-2,3])
        M2 = State.Moment([3,-5,6])

        m1id = id(M1)
        M1 -= M2

        self.assertEquals(m1id, id(M1))
        self.assertEquals(M1, State.Moment([-2,3,-3]))

    def test_latex(self):
        M = State.Moment([3,-5.2,6])
        msg = r'3 \boldsymbol{i} -5.2 \boldsymbol{j} +6 \boldsymbol{k}'
        self.assertEquals(M.latex(), msg)

    def test_str(self):
        M = State.Moment([3,-5.2,6])
        msg = '<Moment [3 -5.2 6]>'
        self.assertEquals(str(M), msg)

"""
Satellite state classes

This logic is targeted mainly for rotational quaternions and
angular body rates which make up the system's state,
but can be used for more general calculations.
"""

import numpy as np
from scipy.linalg import expm

class Quaternion(object):
    """
    Quaternion class

    :param vector: quaternion vector or the axis of rotation (3x1)
    :type  vector: np.mat
    :param scalar: quaternion scalar value.  If none is set, radians
                   should be specified
    :type  scalar: numeric
    :param radians: Specify a rotation about the vector (axis of rotation)
    :type  radians: numeric
    """

    float_threshold = 1e-13

    def __init__(self, vector, scalar=None, radians=None):

        if scalar is None:
            self.from_rotation(vector, radians)
        else:
            self.vector = np.mat(vector, dtype=np.float)
            self.scalar = float(scalar)

        if self.vector.shape == (1, 3):
            self.vector = self.vector.T

    def __eq__(self, q):

        qi = self * q.conj()

        return np.sum(np.abs(qi.vector) + np.abs(qi.scalar)
                      - np.power(self.mag(), 2)) < Quaternion.float_threshold

    def __ne__(self, q):
        return not self.__eq__(q)

    def mag(self):
        """
        Calculate the magnitude of the quaternion by finding its euclidean norm.

        :return: Magnitude of the quaternion
        :rtype:  float
        """
        return np.sqrt(np.sum(self.vector.T * self.vector) + self.scalar**2)

    def normalize(self):
        """
        Normalize this quaternion instance.
        """

        mag = self.mag()
        self.vector /= mag
        self.scalar /= mag

    def is_unit(self):
        """
        Is this quaternion a unit quaternion with magnitude 1
        """

        return np.abs(self.mag() - 1) < self.float_threshold

    def conj(self):
        """
        Create a conjugate quaternion with the same scalar and the negative vector.
        """
        return Quaternion(-self.vector, self.scalar)

    @property
    def x(self):
        """
        Skew-symetric cross product matrix
        """
        return np.mat([
            [0, -self.vector[2, 0], self.vector[1, 0]],
            [self.vector[2, 0], 0, -self.vector[0, 0]],
            [-self.vector[1, 0], self.vector[0, 0], 0],
        ])

    @property
    def rmatrix(self):
        """
        Create a 3x3 rotational matrix based on this quaternion.
        """

        s = self.scalar
        v = self.vector
        x1 = (s**2 - (v.T * v)[0, 0]) * np.eye(3)
        x2 = 2 * self.vector * self.vector.T
        x3 = 2 * s * self.x

        return x1 + x2 - x3

    def rotate_points(self, pts):
        """
        Rotate a series of points based on this quaternion.

        :param pts: Points to be rotated in R3 [[x1, y1, z1],[x2, y2, z2],...]
        :type  pts: np.mat

        :returns: 3x3 rotational matrix for this rotational quaternion
        :rtype: np.mat
        """
        r_pts = self.rmatrix * pts.T
        return r_pts.T

    def from_rotation(self, vector, radians):
        """
        Define an instance of the rotational quaternion with an axis of rotation
        and the angle of rotation.

        :param vector: axis of rotation 3x1
        :type  vector: np.mat
        :param radians: angle of rotation
        :type  radians: float
        """

        v = np.matrix(vector, dtype=np.float)
        v = v / np.sqrt((v*v.T)[0, 0])

        self.vector = v * np.sin(-radians/2)
        self.scalar = np.cos(-radians/2)

    def decompose(self):
        """
        Take a single quaternion representing a state rotation and decompose
        it into two rotational quaternions.  A pure rotation about z
        followed by a rotation about an axis in the x-y plane.

        :return: pair of rotational quaternions (q_z, q_n)
                 q_z: rotation about the body z axis
                 q_n: nutation - rotation about an axis in the xy plane
        :rtype: (quaternion, quaternion)
        """

        Q = (
            self.scalar * self.vector[0, 0]
            - self.vector[1, 0] * self.vector[2, 0]
        )/float(
            self.scalar * self.vector[1, 0]
            + self.vector[0, 0] * self.vector[2, 0]
        )
        n0 = np.sqrt(self.scalar**2 + self.vector[2, 0]**2)
        r0 = self.scalar / n0
        r3 = self.vector[2, 0] / n0
        n2 = np.sqrt((1 - n0**2) / (Q**2 + 1))
        n1 = Q * n2

        q_r = Quaternion([0, 0, r3], r0)

        q_n = Quaternion([n1, n2, 0], n0)
        q_check = q_n * q_r

        if not (np.sum(np.sign(q_check.vector[0:2, 0]) == np.sign(self.vector[0:2, 0])) > 0):
            q_n.vector = -q_n.vector

        return q_r, q_n

    @property
    def mat(self):

        return np.mat([[self.vector[0, 0]],
                       [self.vector[1, 0]],
                       [self.vector[2, 0]],
                       [self.scalar]])

    def __neg__(self):

        return Quaternion(-self.vector, -self.scalar)

    def __add__(self, q):

        return Quaternion(self.vector + q.vector, self.scalar + q.scalar)

    def __sub__(self, q):

        return Quaternion(self.vector - q.vector, self.scalar - q.scalar)

    def __mul__(self, q):
        #here
        s = self.scalar * q.scalar - (self.vector.T * q.vector)[0, 0]
        v = self.vector * q.scalar + q.vector * self.scalar + np.cross(self.vector.T, q.vector.T).T
        return Quaternion(v.T, s)

    def __str__(self):
        """
        :return: representation of the quaternion
        :rtype:  str
        """

        return "<%s <%g %g %g>, %g>" % (
            self.__class__.__name__,
            self.vector[0, 0], self.vector[1, 0], self.vector[2, 0],
            self.scalar)

    __repr__ = __str__


class Identity(Quaternion):
    """
    The identity quaternion <0, 0, 0>, 1
    """

    def __init__(self):
        super(Identity, self).__init__([0, 0, 0], 1)


class QuaternionDynamics(object):

    def __init__(self, q, clock):
        self.q = q
        self.clock = clock
        self.q_dot = Quaternion([0, 0, 0], 0)
        self.last_update = None
        self.w = None

    def propagate(self, w):
        t = self.clock.tick()
        try:
            dt = t - self.last_update
        except TypeError:
            self.last_update = t
            return self.q

        omega2 = self._omega(-w.w)
        try:
            omega1 = self._omega(-self.w.w)
            omega_bar = (omega1 + omega2) / 2
        except AttributeError:
            omega1 = omega2
            omega_bar = omega2

        phi = expm(0.5 * omega_bar * dt) + 1/48 * (omega2 * omega1 - omega1 * omega2) * dt**2

        q2mat = phi * self.q.mat
        q2 = Quaternion(q2mat[0:3, 0], q2mat[3, 0])
        q2.normalize()

        q_dot = q2 - self.q
        try:
            q_dot.vector /= dt
            q_dot.scalar /= dt
            self.q_dot = q_dot
        except ZeroDivisionError:
            pass
        self.q = q2

        self.w = w
        return self.q

    def _omega(self, w):
        wx = w[0, 0]
        wy = w[1, 0]
        wz = w[2, 0]

        return np.mat([[0, wz, -wy, wx],
                       [-wz, 0, wx, wy],
                       [wy, -wx, 0, wz],
                       [-wx, -wy, -wz, 0]])


class BodyRate(object):
    """
    Track body rates about the body principle axes.

    Rates are measured in radians per second.

    :param w: Body rates (3x1) [wx, wy, wz]
    :type  w: list
    """
    def __init__(self, w):

        self.w = np.mat(w, dtype=np.float)

        if self.w.shape == (1, 3):
            self.w = self.w.T

    def __add__(self, w):
        """
        Sum two BodyRate instances
        """
        return BodyRate(self.w + w.w)

    def __iadd__(self, w):
        """
        Useful if adding deltas to an existing BodyRate instead of creating
        a new instance each time.
        """
        self.w += w.w
        return self

    def __eq__(self, w):
        """
        Body rates are equivalent if their vectors are identical
        """
        return np.all(self.w == w.w)

    @property
    def x(self):
        """
        Skew-symetric cross product matrix
        """
        return np.mat([
            [0, -self.w[2, 0], self.w[1, 0]],
            [self.w[2, 0], 0, -self.w[0, 0]],
            [-self.w[1, 0], self.w[0, 0], 0],
        ])

    def __str__(self):
        """
        :return: representation of the body rate
        :rtype:  str
        """

        return "<%s <%g %g %g>>" % (
            self.__class__.__name__,
            self.w[0, 0], self.w[1, 0], self.w[2, 0])

    __repr__ = __str__


class EulerMomentEquations(object):
    """
    Euler's equations describe the rotation of a rigid body, using a
    rotating reference frame with its axes fixed to the body and parallel
    to the body's principal axes of inertia.
    """

    def __init__(self, I, w, clock):
        self.I = np.mat(I, dtype=np.float)
        self.w = w
        self.clock = clock
        self.last_update = None

    def propagate(self, M):
        t = self.clock.tick()
        try:
            dt = t - self.last_update
        except TypeError:
            self.last_update = t
            return self.w

        w_dot = BodyRate([
            M[0] / self.I[0, 0] - (self.I[2, 2] - self.I[1, 1]) * self.w.w[1, 0] * self.w.w[2, 0] / self.I[0, 0],
            M[1] / self.I[1, 1] - (self.I[0, 0] - self.I[2, 2]) * self.w.w[0, 0] * self.w.w[2, 0] / self.I[1, 1],
            M[2] / self.I[2, 2] - (self.I[1, 1] - self.I[0, 0]) * self.w.w[0, 0] * self.w.w[1, 0] / self.I[2, 2],
        ])

        # Update body rate rate on the class.
        self.w_dot = w_dot

        # Update the body rate state
        w_delta = w_dot.w * dt

        self.w.w += w_delta
        self.last_update = t
        return self.w


class Plant(object):
    """
    Tracks the full system state of the TableSat
    """

    def __init__(self, I, q, w, clock):
        self.pos = QuaternionDynamics(q, clock)
        self.vel = EulerMomentEquations(I, w, clock)

    def propagate(self, M):

        w = self.vel.propagate(M);
        q = self.pos.propagate(w);

        return q, w

    def __str__(self):
        """
        :return: representation of the body rate
        :rtype:  str
        """

        return "<%s %s, %s>" % (
            self.__class__.__name__,
            self.pos.q, self.vel.w)

    __repr__ = __str__

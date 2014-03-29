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
    Quaternion class.  Based on William Rowan Hamilton's definition
    of the 4-tuple as an extension of the common complex number (a+bi)

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
        """
        Equality fits under 2 camps.  General equality where the components
        for both quaternions have identical values, and rotational equality
        where the twe quaternions represent the same orientation.

        :param q: Quaternion to compare to the current instance
        :type  q: Quaternion
        :return: equal status
        :rtype: bool
        """

        # Compare for strict equality
        test = (np.all(self.vector == q.vector) and self.scalar == q.scalar)
        if test:
            return True

        # Compare for rotational equality
        qe = QuaternionError(self, q)

        return (np.sum(np.abs(qe.vector)) < self.float_threshold and
            np.abs(qe.scalar - 1) < self.float_threshold)

    def __ne__(self, q):
        return not self.__eq__(q)

    @property
    def mag(self):
        """
        Calculate the magnitude of the quaternion by finding its euclidean norm

        :return: Magnitude of the quaternion
        :rtype:  float
        """
        return np.sqrt(np.sum(self.vector.T * self.vector) + self.scalar ** 2)

    def normalize(self):
        """
        Normalize this quaternion instance.
        """

        mag = self.mag
        self.vector /= mag
        self.scalar /= mag

    def is_unit(self):
        """
        Is this quaternion a unit quaternion with magnitude 1
        """

        return np.abs(self.mag - 1) < self.float_threshold

    @property
    def conj(self):
        """
        Create a conjugate quaternion with the same scalar and the
        negative vector.
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
        x1 = (s ** 2 - (v.T * v)[0, 0]) * np.eye(3)
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
        Define an instance of the rotational quaternion with an axis of
        rotation and the angle of rotation.

        :param vector: axis of rotation 3x1
        :type  vector: np.mat
        :param radians: angle of rotation
        :type  radians: float
        """
        v = np.matrix(vector, dtype=np.float)
        if v.shape == (1, 3):
            v = v.T

        v = v / np.sqrt((v.T * v)[0, 0])

        self.vector = v * np.sin(-radians / 2)
        self.scalar = np.cos(-radians / 2)

    def to_rotation(self):
        """
        Convert the current quaternion into a vector and angle of rotation.
        This is the inverse to self.from_rotation.

        :return: (axis of rotation, angle of rotation)
        :rtype: tuple
        """

        v = self.vector
        v = v / np.sqrt((v.T * v)[0, 0])
        radians = np.arccos(self.scalar) * 2
        return (v, radians)

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

        n0 = np.sqrt(self.scalar ** 2 + self.vector[2, 0] ** 2)
        r0 = self.scalar / n0
        r3 = self.vector[2, 0] / n0

        divisor = float(self.scalar * self.vector[1, 0]
            + self.vector[0, 0] * self.vector[2, 0])

        if divisor == 0.0:
            q_r = Quaternion([0, 0, r3], r0)
            return q_r, Identity()

        Q = (
            self.scalar * self.vector[0, 0]
            - self.vector[1, 0] * self.vector[2, 0]
        ) / divisor

        n2 = np.sqrt((1 - n0 ** 2) / (Q ** 2 + 1))
        n1 = Q * n2

        q_r = Quaternion([0, 0, r3], r0)
        q_n = Quaternion([n1, n2, 0], n0)
        q_check = q_n * q_r

        if not (np.sum(np.sign(q_check.vector[0:2, 0]) ==
                np.sign(self.vector[0:2, 0])) > 0):

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
        return self * q

    def __iadd__(self, q):
        q_new = q * self
        self.vector = q_new.vector
        self.scalar = q_new.scalar
        return self

    def __sub__(self, q):
        return q.conj * self

    def __isub__(self, q):
        q_new = q.conj * self
        self.vector = q_new.vector
        self.scalar = q_new.scalar
        return self

    def __mul__(self, q):
        s = self.scalar * q.scalar - (self.vector.T * q.vector)[0, 0]
        v = (self.x + np.eye(3) * self.scalar) * q.vector
        v += self.vector * q.scalar
        return Quaternion(v, s)

    def latex(self):
        """
        Create a LaTeX representation of the current state of the quaternion

        :return: LaTeX quaternion str
        :rtype: str
        """
        msg = '%g \\textbf{i} %+g \\textbf{j} %+g \\textbf{k} %+g' % (
            self.vector[0, 0], self.vector[1, 0], self.vector[2, 0],
            self.scalar
        )
        return msg

    def __str__(self):
        """
        :return: representation of the quaternion
        :rtype:  str
        """

        return "<%s [%g %g %g], %g>" % (
            self.__class__.__name__,
            self.vector[0, 0], self.vector[1, 0], self.vector[2, 0],
            self.scalar)

    __repr__ = __str__


def Identity():
    """
    Helper method to create an identity quaternion [0, 0, 0], 1
    """
    return Quaternion([0, 0, 0], 1)


def QuaternionError(q_hat, q):
    """
    Create an error quaternion that could be used to move a onto b.

    :param q_hat: The estimated attitude quaternion
    :type  q_hat: Quaternion
    :param q: The measured/actual attitude quaternion
    :type  q: Quaternion
    :returns: The error quaternion
    :rtype: Quaternion

    Usage::

        q_hat = Quaternion([0, 0, 1], radians=3*np.pi/6)
        q = Quaternion([0, 0, 1], radians=4*np.pi/6)
        print('q_hat = %s' % q_hat)
        print('q = %s' % q)
        qe = QuaternionError(q_hat, q)
        print('q_err = %s' % qe)
        print('Take error off the estimated quaternion to get the measured q')
        print('q_err.conj * q_hat = q = %s' % (qe.conj * q_hat))
        # q_hat = <Quaternion [-0 -0 -0.707107], 0.707107>
        # q = <Quaternion [-0 -0 -0.866025], 0.5>
        # q_err = <Quaternion [0 0 0.258819], 0.965926>
        # Take error off the estimated quaternion to get the measured q
        # q_err.conj * q_hat = q = <Quaternion [0 0 -0.866025], 0.5>

    The quaternion error will return a rotational quaternion < 180 deg::

        v = [1, -2, 4]
        q_hat = Quaternion(v, radians=3 * np.pi / 10.0)
        q = Quaternion(v, radians=18 * np.pi / 10.0)
        qe = QuaternionError(q_hat, q)
        # The shorter quaternion is rotating through the 360
        print('q_hat(3pi/10) =%s' % q_hat)
        print('q(18pi/10) = %s' % q)
        print('q_err   = %s' % qe)
        print('q(pi/2) = %s' % Quaternion(v, radians=5 * np.pi / 10.0))
        # q_hat(3pi/10) =<Quaternion [-0.0990688 0.198138 -0.396275], 0.891007>
        # q(18pi/10) = <Quaternion [-0.067433 0.134866 -0.269732], -0.951057>
        # q_err   = <Quaternion [-0.154303 0.308607 -0.617213], 0.707107>
        # q(pi/2) = <Quaternion [-0.154303 0.308607 -0.617213], 0.707107>

    """

    qe = q.conj * q_hat

    # To keep error signals from trying to turn > 180 degrees
    # Keep the scalar value for the error quaternion positive.
    if qe.scalar < 0:
        return -qe
    return qe


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
            self.w = w
            self.last_update = t
            return self.q

        omega2 = self._omega(-w.w)
        omega1 = self._omega(-self.w.w)
        omega_bar = (omega1 + omega2) / 2

        phi = expm(0.5 * omega_bar * dt) + 1 / 48 * (
            omega2 * omega1 - omega1 * omega2) * dt ** 2
        q2mat = phi * self.q.mat
        q2 = Quaternion(q2mat[0:3, 0], q2mat[3, 0])
        q2.normalize()

        q_dot = q2 - self.q

        if dt > 0:
            q_dot.vector /= dt
            q_dot.scalar /= dt
            self.q_dot = q_dot

        self.q = q2

        self.w = w
        self.last_update = t
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

    float_threshold = 1e-12

    def __init__(self, w=None):

        if w is None:
            w = [0, 0, 0]

        self.w = np.mat(w, dtype=np.float)

        if self.w.shape == (1, 3):
            self.w = self.w.T

    def __add__(self, w):
        """
        Sum two BodyRate instances
        """
        return BodyRate(self.w + w.w)

    def __sub__(self, w):
        """
        Diff of two BodyRate instances
        """
        return BodyRate(self.w - w.w)

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
        return np.sum(np.abs(self.w - w.w)) < self.float_threshold

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

    def latex(self):
        """
        Create a LaTeX representation of the current state of the quaternion

        :return: LaTeX quaternion str
        :rtype: str
        """
        msg = '%g \\textbf{i} %+g \\textbf{j} %+g \\textbf{k}' % (
            self.w[0, 0], self.w[1, 0], self.w[2, 0],
        )
        return msg

    def __str__(self):
        """
        :return: representation of the body rate
        :rtype:  str
        """

        return "<%s [%g %g %g]>" % (
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
        """
        Propagate a rigid body's angular rates based on Euler's
        Moment Equations.

        :param M: Applied moment about the rigid body's principal axes (3x1)
        :type  M: 3 element list
        :return: new body rate
        :rtype: BodyRate
        """
        t = self.clock.tick()
        try:
            dt = t - self.last_update
        except TypeError:
            self.last_update = t
            return self.w

        w_dot = BodyRate([
            M[0] / self.I[0, 0] - (self.I[2, 2] - self.I[1, 1]) *
                self.w.w[1, 0] * self.w.w[2, 0] / self.I[0, 0],
            M[1] / self.I[1, 1] - (self.I[0, 0] - self.I[2, 2]) *
                self.w.w[0, 0] * self.w.w[2, 0] / self.I[1, 1],
            M[2] / self.I[2, 2] - (self.I[1, 1] - self.I[0, 0]) *
                self.w.w[0, 0] * self.w.w[1, 0] / self.I[2, 2],
        ])

        # Update body rate rate on the class.
        self.w_dot = w_dot

        # Update the body rate state
        w_delta = w_dot.w * dt

        self.w.w += w_delta
        self.last_update = t
        return self.w


class State(object):
    """
    A full state object.

    :param q: Attitude portion of the state
    :type  q: Quaternion
    :param w: Body rate portion of the state
    :type  w: BodyRate
    """

    def __init__(self, q=None, w=None):
        if q is None:
            q = Identity()
        if w is None:
            w = BodyRate()
        self.q = q
        self.w = w

    def __eq__(self, x):
        """
        Determine if two states are equivalent.  Body rates must be
        equal and quaternions must represent the same orientation.
        """
        return self.w == x.w and self.q == x.q

    def __str__(self):
        """
        See the current state
        """
        return "%s, %s" % (self.q, self.w)

    __repr__ = __str__

    def __add__(self, x):
        q_new = self.q + x.q
        w_new = self.w + x.w
        return State(q_new, w_new)

    def __iadd__(self, x):
        self.q += x.q
        self.w += x.w
        return self

    def __sub__(self, x):
        q_new = self.q - x.q
        w_new = self.w - x.w
        return State(q_new, w_new)

    def __isub__(self, x):
        self.q -= x.q
        self.w -= x.w
        return self


def StateError(x_hat, x):
    """
    Create an error representation between two full states.

    :param x_hat: Estimated state
    :type  x_hat: State
    :param x_hat: Actual/Measured state
    :type  x_hat: State
    :returns: error generated from a quaternion multiplicative error
              and body rate diff
    :rtype: State
    """
    return State(
        QuaternionError(x_hat.q, x.q),
        x_hat.w - x.w)


class Plant(object):
    """
    Tracks the full system state of the TableSat
    """

    def __init__(self, I, x, clock):
        self.pos = QuaternionDynamics(x.q, clock)
        self.vel = EulerMomentEquations(I, x.w, clock)

    @property
    def x(self):
        return State(self.pos.q, self.vel.w)

    def propagate(self, M):
        """
        Propagate the state of the plant.  Based on an applied moment,
        propagate the body rate then quaternion states.

        :param M: Applied moment about the rigid body's principal axes (3x1)
        :type  M: 3 element list
        :return: new body rate and quaternion state (w, q)
        :rtype: w (BodyRate), q (Quaternion)
        """
        w = self.vel.propagate(M)
        q = self.pos.propagate(w)
        return q, w

    def latex(self):
        """
        :return: LaTeX representation of the plant's state
        :rtype:  dict
        """
        return {
            'q': self.pos.q.latex(),
            'w': self.vel.w.latex(),
        }

    def __str__(self):
        """
        :return: representation of the plant
        :rtype:  str
        """
        return "<%s %s, %s>" % (
            self.__class__.__name__,
            self.pos.q, self.vel.w)

    __repr__ = __str__

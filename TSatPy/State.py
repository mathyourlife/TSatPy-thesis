"""
Satellite state classes

This logic is targeted mainly for rotational quaternions and
angular body rates which make up the system's state,
but can be used for more general calculations.
"""

import numpy as np


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


class BodyRate(object):

    def __init__(self, w):

        self.w = np.mat(w, dtype=np.float)

        if self.w.shape == (1, 3):
            self.w = self.w.T

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


"""
Attitude Quaternion
"""

import numpy as np


class Quaternion(object):
    """
    Attitude quaternion class
    """

    float_threshold = 1e-15

    def __init__(self, vector, scalar=None, radians=None):

        if scalar is None:
            self.from_rotation(vector, radians)
        else:
            self.vector = np.mat(vector, dtype=np.float).T
            self.scalar = float(scalar)

        if self.vector.shape == (1, 3):
            self.vector = self.vector.T

    def __eq__(self, q):

        # Exactly equal
        if self.scalar == q.scalar and np.all(self.vector == q.vector):
            return True

        # Equal but opposite signs
        if -self.scalar == q.scalar and np.all(-self.vector == q.vector):
            return True

        return False

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

        s = self.scalar
        v = self.vector
        x1 = (s**2 - (v.T * v)[0,0]) * np.eye(3)
        x2 = 2 * self.vector * self.vector.T
        x3 = 2 * s * self.x

        return x1 + x2 - x3

    def rotate_points(self, pts):

        r_pts = self.rmatrix * pts.T
        return r_pts.T

    def from_rotation(self, vector, radians):

        v = np.matrix(vector, dtype=np.float)
        v = v/(v*v.T)[0, 0]

        self.vector = v * np.sin(-radians/2)
        self.scalar = np.cos(-radians/2)

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

    def __init__(self):
        self.vector = np.mat([0, 0, 0])
        self.scalar = 1


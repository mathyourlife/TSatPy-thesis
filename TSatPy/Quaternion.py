"""
Attitude Quaternion
"""

import numpy as np


class Quaternion(object):
    """
    Attitude quaternion class
    """

    def __init__(self, vector, scalar=None, radians=None):

        if scalar is None:
            self.from_rotation(vector, radians)
        else:
            self.vector = np.mat(vector, dtype=np.float)
            self.scalar = float(scalar)

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
        return np.sqrt(np.sum(self.vector * self.vector.T) + self.scalar**2)

    def normalize(self):
        """
        Normalize this quaternion instance.
        """

        mag = self.mag()
        self.vector /= mag
        self.scalar /= mag

    def conj(self):
        """
        Create a conjugate quaternion with the same scalar and the negative vector.
        """
        return Quaternion(-self.vector, self.scalar)

    def from_rotation(self, vector, radians):

        v = np.matrix(vector, dtype=np.float)
        v = v/(v*v.T)[0,0]

        self.vector = v * np.sin(-radians/2)
        self.scalar = np.cos(-radians/2)

    def __neg__(self):

        return Quaternion(-self.vector, -self.scalar)

    def __add__(self, q):

        return Quaternion(self.vector + q.vector, self.scalar + q.scalar)

    def __sub__(self, q):

        return Quaternion(self.vector - q.vector, self.scalar - q.scalar)

    def __mul__(self, q):
        s = self.scalar * q.scalar - (self.vector * q.vector.T)[0,0]
        v = self.vector * q.scalar + q.vector * self.scalar + np.cross(self.vector, q.vector)
        return Quaternion(v, s)

    def __str__(self):
        """
        :return: representation of the quaternion
        :rtype:  str
        """

        return "<%s <%g %g %g>, %g>" % (
            self.__class__.__name__,
            self.vector[0,0], self.vector[0,1], self.vector[0,2],
            self.scalar)

    __repr__ = __str__

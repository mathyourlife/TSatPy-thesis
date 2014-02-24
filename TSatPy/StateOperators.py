
import numpy as np
from TSatPy import State


class BodyRateGain(object):
    """
    Gain matrices for BodyRate instances

    :param K: 3x3 matrix for scaling BodyRate values
    :type  K: list

    Sample::

        w = State.BodyRate([1,-1,0])
        G = StateOperators.BodyRateGain([[1,2,3],[4,5,6],[10,8,9]])
        print(G * w)
        # <BodyRate [-1 -1 2]>

    """

    def __init__(self, K):
        self.update_gain(K)

    def update_gain(self, K):
        """
        Update the gain matrix

        :param K: 3x3 matrix for scaling BodyRate values
        :type  K: list
        """
        self.K = np.matrix(K)

    def __mul__(self, w):
        """
        Matrix based multiplication for a BodyRate instance

        :param w: BodyRate instance to be multiplied
        :type  w: BodyRate
        """
        return State.BodyRate(self.K * w.w)

    def __str__(self):
        """
        Return a string representation of the gain numpy matrix.

        :return: gain matrix representation
        :rtype: str
        """
        return str(self.K)


class QuaternionRotationGain(object):
    """
    Gain instance to scale a quaternion rotational matrix.  Gain values
    will scale out the magnitude of the rotation.

    """
    def __init__(self, K):
        self.update_gain(K)

    def update_gain(self, K):
        """
        Update the gain matrix

        :param K: 3x3 matrix for scaling BodyRate values
        :type  K: list
        """
        self.K = K

    def __mul__(self, q):
        """
        Matrix based multiplication for a BodyRate instance

        :param w: BodyRate instance to be multiplied
        :type  w: BodyRate
        """

        s = q.scalar
        print(np.arccos(s) / np.pi * 180 )
        s = np.cos(np.arccos(q.scalar) * self.K)
        print(np.arccos(s) / np.pi * 180)

        print (q.vector.T * q.vector)[0,0]
        c = (q.vector.T * q.vector)[0,0] / np.sqrt(1 - s**2)
        print c

        return State.Quaternion(q.vector / c, s)

    def __str__(self):
        """
        Return a string representation of the gain numpy matrix.

        :return: gain matrix representation
        :rtype: str
        """
        return str(self.K)

def main():
    q = State.Quaternion([0,0,1], radians=np.pi/10)
    print q
    qg = QuaternionRotationGain(0.5)
    print qg * q
    print State.Quaternion([0,0,1], radians=np.pi/20)

    print 'aoeu'

if __name__ == '__main__':
    main()
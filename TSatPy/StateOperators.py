
import numpy as np
from TSatPy import State


class BodyRateGain(object):
    """
    Gain matrices for BodyRate instances

    :param K: 3x3 matrix for scaling BodyRate values
    :type  K: list

    Sample::

        w = State.BodyRate([1,-1,0])
        print('w = %s' % w)
        Kw = BodyRateGain([[1,2,3],[4,5,6],[10,8,9]])
        print('Kw = %s' % Kw)
        print('Kw * w = %s' % (Kw * w))
        # w = <BodyRate [1 -1 0]>
        # Kw = [[ 1  2  3]  [ 4  5  6]  [10  8  9]]
        # Kw * w = <BodyRate [-1 -1 2]>

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
        return str(self.K).replace('\n', ' ')


class QuaternionGain(object):
    """
    Gain instance to scale a quaternion rotational matrix.  Gain values
    will scale out the magnitude of the rotation.

    Usage::

        q = State.Quaternion([0,0,1], radians=np.pi/10)
        print('q(pi/10) = %s' % q)
        Kq = QuaternionGain(0.25)
        print('Kq = %s' % Kq)
        print('Kq * q = %s' % (Kq * q))
        print('q(pi/40) = %s' % State.Quaternion([0,0,1], radians=np.pi/40))
        # q(pi/10) = <Quaternion [-0 -0 -0.156434], 0.987688>
        # Kq = 0.25
        # Kq * q = <Quaternion [-0 -0 -0.0392598], 0.999229>
        # q(pi/40) = <Quaternion [-0 -0 -0.0392598], 0.999229>

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
        s = np.cos(np.arccos(q.scalar) * self.K)

        c = np.sqrt((q.vector.T * q.vector)[0,0] / (1 - s**2))

        return State.Quaternion(q.vector / c, s)

    def __str__(self):
        """
        Return a string representation of the gain numpy matrix.

        :return: gain matrix representation
        :rtype: str
        """
        return str(self.K).replace('\n', ' ')


class StateGain(object):
    """
    A gain instance for a full state

    :param Kq: Quaternion gain
    :type  Kq: QuaternionGain
    :param Kw: Body rate gain
    :type  Kw: BodyRateGain

    Usage::

        w = State.BodyRate([1,-1,0])
        q = State.Quaternion([0,0,1], radians=np.pi/10)
        x = State.State(q, w)
        print('x = %s' % x)
        Kq = QuaternionGain(0.25)
        print('Kq = %s' % Kq)
        print('Kq * q = %s' % (Kq * q))
        Kw = BodyRateGain([[1,2,3],[4,5,6],[10,8,9]])
        print('Kw = %s' % Kw)
        print('Kw * w = %s' % (Kw * w))
        Kx = StateGain(Kq, Kw)
        print('Kx = %s' % Kx)
        print('Kx * x = %s' % (Kx * x))
        x = <Quaternion [-0 -0 -0.156434], 0.987688>, <BodyRate [1 -1 0]>
        Kq = 0.25
        Kq * q = <Quaternion [-0 -0 -0.0392598], 0.999229>
        Kw = [[ 1  2  3]  [ 4  5  6]  [10  8  9]]
        Kw * w = <BodyRate [-1 -1 2]>
        Kx = <StateGain <Kq 0.25>, <Kw = [[ 1  2  3]  [ 4  5  6]  [10  8  9]]>>
        Kx * x = <Quaternion [-0 -0 -0.0392598], 0.999229>, <BodyRate [-1 -1 2]>

    """

    def __init__(self, Kq=None, Kw=None):
        self.Kq = Kq
        self.Kw = Kw

    def __mul__(self, x):
        q_new = self.Kq * x.q
        w_new = self.Kw * x.w
        return State.State(q_new, w_new)

    def __str__(self):
        return '<%s <Kq %s>, <Kw = %s>>' % (
            self.__class__.__name__,
            str(self.Kq), str(self.Kw))

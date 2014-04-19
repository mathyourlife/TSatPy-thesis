
import numpy as np
from TSatPy import State


class OperatorError(Exception):
    pass


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
        Kw_str = str(self.K).replace('\n', ' ')
        while '  ' in Kw_str:
            Kw_str = Kw_str.replace('  ', ' ')
        return Kw_str


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

        :param K: 3x3 matrix for scaling the rotational quaternion
        :type  K: list
        """
        self.K = K

    def __mul__(self, q):
        """
        Angle Multiplier with Vector Magnitude Normalization

        :param q: Quaternion instance to be multiplied
        :type  q: Quaternion
        """
        # Floating point errors can cause the domain to exceed |q.scalar| <= 1
        if q.scalar > 1:
            s = 1.0
        elif q.scalar < -1:
            s = -1.0
        else:
            s = q.scalar

        kpc = self.K * np.arccos(s)
        if kpc == 0:
            return State.Identity()
        gamma = np.sqrt((q.vector.T * q.vector)[0,0] / (np.sin(kpc))**2)

        return State.Quaternion(
            q.vector / gamma,
            np.cos(kpc)
        )

    def __str__(self):
        """
        Return a string representation of the gain numpy matrix.

        :return: gain matrix representation
        :rtype: str
        """
        return str(self.K)


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
        print('Kx=%s' % Kx)
        print('Kx*x=%s' % (Kx * x))
        # x = <Quaternion [-0 -0 -0.156434], 0.987688>, <BodyRate [1 -1 0]>
        # Kq = 0.25
        # Kq * q = <Quaternion [-0 -0 -0.0392598], 0.999229>
        # Kw = [[ 1  2  3]  [ 4  5  6]  [10  8  9]]
        # Kw * w = <BodyRate [-1 -1 2]>
        # Kx=<StateGain <Kq 0.25>, <Kw = [[ 1  2  3]  [ 4  5  6]  [10  8  9]]>>
        # Kx*x=<Quaternion [-0 -0 -0.0392598], 0.999229>, <BodyRate [-1 -1 2]>

    """

    def __init__(self, Kq=None, Kw=None):
        self.Kq = Kq
        self.Kw = Kw

    def __mul__(self, x):
        if self.Kq is None:
            q_new = State.Quaternion()
        else:
            q_new = self.Kq * x.q

        if self.Kw is None:
            w_new = State.BodyRate()
        else:
            w_new = self.Kw * x.w

        return State.State(q_new, w_new)

    def __str__(self):
        return '<%s <Kq %s>, <Kw = %s>>' % (
            self.__class__.__name__,
            str(self.Kq), str(self.Kw))


class QuaternionSaturation(object):

    def __init__(self, rho):
        self.update_rho(rho)

    def update_rho(self, rho):
        """
        Update the threshold for the saturation function

        :param rho: threshold for saturation function
        :type  rho: numeric
        """
        self.rho = np.abs(float(rho))

    def __mul__(self, q):
        """
        Return the saturation result of the quaternion.  Unchanged if the
        rotational angle is below the rho threshold. And capped at the
        threshold if above.

        :param q: quaternion to be saturated
        :type  q: Quaternion
        """

        # to_rotation returns an angle 0 < r < 2pi
        e, r = q.to_rotation()

        # compensate for r > 180
        if r > np.pi:
            r = r - 2 * np.pi
            e = -e

        # to saturate?
        if np.abs(r) > self.rho:
            return State.Quaternion(e, radians=-self.rho)
        # or not
        return q

    def __str__(self):
        return '<%s <rho %s>>' % (self.__class__.__name__, str(self.rho))


class BodyRateSaturation(object):

    def __init__(self, rho):
        self.update_rho(rho)

    def update_rho(self, rho):
        """
        Update the threshold for the saturation function

        :param rho: threshold for saturation function
        :type  rho: numeric
        """
        self.rho = np.ones((3,1)) * float(rho)

    def __mul__(self, w):
        """
        Return the saturation result of the body rate.  Saturation is performed
        on an element-wise basis for each of the 3 body rate values.

        :param w: body rate to be saturated
        :type  w: BodyRate
        """
        w_sat = np.multiply(np.minimum.reduce([np.abs(w.w), self.rho]),
            np.sign(w.w))
        return State.BodyRate(w_sat)

    def __str__(self):
        return '<%s <rho %s>>' % (self.__class__.__name__, str(self.rho[0,0]))


class StateSaturation(object):

    def __init__(self, Sq=None, Sw=None):
        self.Sq = Sq
        self.Sw = Sw

    def __mul__(self, x):
        try:
            q_new = self.Sq * x.q
        except TypeError:
            q_new = State.Identity()

        try:
            w_new = self.Sw * x.w
        except TypeError:
            w_new = State.BodyRate()
        return State.State(q_new, w_new)

    def __str__(self):
        return '<%s <Sq %s>, <Sw = %s>>' % (
            self.__class__.__name__,
            str(self.Sq), str(self.Sw))


class BodyRateToMoment(object):
    """
    Create the mapping between a body rate measure (or error) to
    an associated moment tuple.

    :param K: 3x3 gain matrix for the straight forward multiplication
    :type  K: numpy.matrix
    """
    def __init__(self, K):
        self.K = K

    def __mul__(self, w):
        return State.Moment(self.K * w.w)

    def __str__(self):
        """
        Return a string representation of the gain numpy matrix.

        :return: gain matrix representation
        :rtype: str
        """
        K_str = str(self.K).replace('\n', ' ')
        while '  ' in K_str:
            K_str = K_str.replace('  ', ' ')
        return '<%s <K %s>>' % (
            self.__class__.__name__, K_str)


class QuaternionToMoment(object):
    pass


class StateToMoment(object):

    def __init__(self, Kq=None, Kw=None):
        self.Kq = Kq
        self.Kw = Kw

    def __mul__(self, x):
        M = State.Moment()
        if self.Kq is not None:
            M += self.Kq * x.q
        if self.Kw is not None:
            M += self.Kw * x.w
        return M

    def __str__(self):
        return '<%s <Kq %s>, <Kw = %s>>' % (
            self.__class__.__name__,
            str(self.Kq), str(self.Kw))

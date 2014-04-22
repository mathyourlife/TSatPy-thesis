"""
Satellite state classes

This logic is targeted mainly for rotational quaternions and
angular body rates which make up the system's state,
but can be used for more general calculations.

System property                       Class
------------------------------------------------------------------
Attitude                              Quaternion
Spin rates                            BodyRate
Difference in attitudes               QuaternionError
How body rates change the attitude    QuaternionDynamics
How moments change the body rates     EulerMomentEquations
Position and velocity                 State - Couples the position (Quaternion)
                                       with velocity (BodyRate)
Differences in position and velocity  StateError
In-memory model of the satellite      Plant
Applied torques                       Moment

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
        """
        Negative test for equality.  Returns True if the two quaternions
        do not represent the same attitude.

        :param q: Quaternion to compare to the current instance
        :type  q: Quaternion
        :return: not equal status
        :rtype: bool
        """
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
        Normalize this quaternion instance.  This should be rarely needed
        if using the quaternion multiplicative correction.

        :return: This quaternion scaled by it's magnitude
        :rtype: Quaternion
        """

        mag = self.mag
        self.vector /= mag
        self.scalar /= mag

    def is_unit(self):
        """
        Is this quaternion a unit quaternion with magnitude 1

        :return: Am I a unit vector?
        :rtype: bool
        """

        return np.abs(self.mag - 1) < self.float_threshold

    @property
    def conj(self):
        """
        Create a conjugate quaternion with the same scalar and the
        negative vector.  Used for quaternion error calculations.

        :return: conjugate quaternion
        :rtype: Quaternion
        """
        return Quaternion(-self.vector, self.scalar)

    @property
    def x(self):
        """
        Skew-symetric cross product matrix.  A form used for a few calculations

        :return: Skew-symetric matrix from this quaternion's vector.
        :rtype: np.matrix
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

        :return: rotate points around by multiplying by this 3x3 matrix
        :rtype: np.matrix
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

        :return: 3x3 rotational matrix for this rotational quaternion
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

        self.vector = v * np.sin(-float(radians) / 2)
        self.scalar = np.cos(-float(radians) / 2)

    def to_rotation(self):
        """
        Convert the current quaternion into a vector and angle of rotation.
        This is the inverse to self.from_rotation.  The angle returned
        is in the range [0, 2pi)

        :return: (Euler axis of rotation, angle of rotation in radians)
        :rtype: tuple
        """

        v = self.vector
        v_mag = np.sqrt((v.T * v)[0, 0])
        if v_mag == 0:
            v = np.mat([0, 0, 0]).T
        else:
            v = v / v_mag

        if self.scalar < -1:
            s = -1
        elif self.scalar > 1:
            s = 1
        else:
            s = self.scalar
        radians = np.arccos(s) * 2
        return (v, radians)

    def decompose(self):
        """
        Take a single quaternion representing a state rotation and decompose
        it into two rotational quaternions.  A pure rotation about z
        followed by a rotation about an axis in the x-y plane.

        :return: pair of rotational quaternions (q_r, q_n)
                 q_r: rotation about the body z axis
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

        return q_r, -q_n

    @property
    def mat(self):
        """
        If we need to fall back and get the data in a singe matrix format.

        :return: scalar last matrix form
        :rtype: np.matrix
        """

        return np.mat([[self.vector[0, 0]],
                       [self.vector[1, 0]],
                       [self.vector[2, 0]],
                       [self.scalar]])

    def __neg__(self):
        """
        The negative quaternion negates all parameters

        :return: the neg quaternion
        :rtype: Quaternion
        """
        return Quaternion(-self.vector, -self.scalar)

    def __add__(self, q):
        """
        One does not simply add quaternions together.  Addition is just
        remapped to __mul__

        :param q: Quaternion rotation to add on
        :type  q: Quaternion
        :return: A multiplicative quaternion combination
        :rtype: Quaternion
        """
        return self * q

    def __iadd__(self, q):
        """
        Same as + but returns self in case the object ref integrity needs
        to be maintained.

        :param q: Quaternion rotation to add on
        :type  q: Quaternion
        :return: A multiplicative quaternion combination
        :rtype: Quaternion
        """
        q_new = q * self
        self.vector = q_new.vector
        self.scalar = q_new.scalar
        return self

    def __sub__(self, q):
        """
        The opposite of a quaternion is it's conjugate.

        :param q: Quaternion to take off
        :type  q: Quaternion
        :return: q* x self
        :rtype: Quaternion
        """
        return q.conj * self

    def __isub__(self, q):
        """
        Same as __sub__, but keeps this instance intact.

        :param q: Quaternion to take off
        :type  q: Quaternion
        :return: q* x self
        :rtype: Quaternion
        """
        q_new = q.conj * self
        self.vector = q_new.vector
        self.scalar = q_new.scalar
        return self

    def __mul__(self, q):
        """
        This is the way you combine quaternions.  None of that additive method!

        :param q: Quaternion rotation to be combined with
        :type  q: Quaternion
        :return: the composite quaternion
        :rtype: Quaternion
        """
        s = self.scalar * q.scalar - (self.vector.T * q.vector)[0, 0]
        v = (self.x + np.eye(3) * self.scalar) * q.vector
        v += self.vector * q.scalar
        return Quaternion(v, s)

    def latex(self):
        """
        Create a LaTeX representation of the current state of the quaternion

        :return: LaTeX representation of this quaternion instance
        :rtype: str
        """
        msg = '%g \\boldsymbol{i} %+g \\boldsymbol{j} %+g \\boldsymbol{k} %+g'
        data = (self.vector[0, 0], self.vector[1, 0], self.vector[2, 0],
            self.scalar)
        return msg % data

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
    :return: The error quaternion
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
    """
    Given a starting quaternion (postition) and current body rate (velocity),
    determine the new quaternion.

    :param q: Initial condition for the dynamics
    :type  q: Quaternion
    :param clock: The system clock so we can watch time progress
    :type  clock: Clock.Metronome
    """

    def __init__(self, q, clock):
        self.q = q
        self.clock = clock
        self.last_update = None
        self.w = None

    def propagate(self, w):
        """
        Use the time elapsed since last update and the supplied body rates
        to determine where the next quaternion position will be.

        This method of propagating the discrete was drawn from the work of
        Nikolas Trawny and Stergios I. Roumeliotis in "Indirect Kalman Filter
        for 3D Attitude Estimation A Tutorial for Quaternion Algebra"
        Multiple Autonomous Robotic Systems Laboratory - Technical Report
        Sep 2008

        :param w: system's body rates
        :type  w: BodyRate
        :return: the next quaternion attitude
        :rtype: Quaternion
        """
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

        self.q = q2

        self.w = w
        self.last_update = t
        return self.q

    def _omega(self, w):
        """
        Helper method for the propagate function.

        :param w: A body rate value
        :type  w: BodyRate
        :return: The Omega matrix
        :rtype: np.matrix
        """
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

        :param w: A body rate to sum with
        :type  w: BodyRate
        :return: the sum
        :rtype: BodyRate
        """
        return BodyRate(self.w + w.w)

    def __sub__(self, w):
        """
        Diff of two BodyRate instances

        :param w: Egh, what's the diff, man??
        :type  w: BodyRate
        :return: the difference
        :rtype: BodyRate
        """
        return BodyRate(self.w - w.w)

    def __iadd__(self, w):
        """
        Useful if adding deltas to an existing BodyRate instead of creating
        a new instance each time.

        :param w: Same as addition just no new instance
        :type  w: BodyRate
        :return: myself, just changed
        :rtype: BodyRate
        """
        self.w += w.w
        return self

    def __eq__(self, w):
        """
        Body rates are equivalent if their vectors are identical

        :param w: Test for equalityish (allow for some fp routing)
        :type  w: BodyRate
        :return: equal or not
        :rtype: bool
        """
        return np.sum(np.abs(self.w - w.w)) < self.float_threshold

    @property
    def x(self):
        """
        Skew-symetric cross product matrix

        :return: A 3x3 matrix used in a variety of calculations
        :rtype: np.matrix
        """
        return np.mat([
            [0, -self.w[2, 0], self.w[1, 0]],
            [self.w[2, 0], 0, -self.w[0, 0]],
            [-self.w[1, 0], self.w[0, 0], 0],
        ])

    def latex(self):
        """
        Create a LaTeX representation of the current state of the body rate

        :return: LaTeX quaternion str
        :rtype: str
        """
        msg = '%g \\boldsymbol{i} %+g \\boldsymbol{j} %+g \\boldsymbol{k}' % (
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

    :param I: the 3x3 moment of intertia matrix
    :type  I: np.matrix or list of lists
    :param w: Body rate initial condition
    :type  w: BodyRate
    :param clock: The system clock to quantify the time steps
    :type  clock: Clock.Metronome
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
            (M.M[0, 0] - (self.I[2, 2] - self.I[1, 1]) *
                self.w.w[1, 0] * self.w.w[2, 0]) / self.I[0, 0],
            (M.M[1, 0] - (self.I[0, 0] - self.I[2, 2]) *
                self.w.w[0, 0] * self.w.w[2, 0]) / self.I[1, 1],
            (M.M[2, 0] - (self.I[1, 1] - self.I[0, 0]) *
                self.w.w[0, 0] * self.w.w[1, 0]) / self.I[2, 2],
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

        :param x: The state to compare this instance to
        :type  x: State
        :return: Equal or not?
        :rtype: bool
        """
        return self.w == x.w and self.q == x.q

    def __str__(self):
        """
        See the current state in string format

        :return: nicer way to print the instances parameters
        :rtype: str
        """
        return "%s, %s" % (self.q, self.w)

    def latex(self):
        """
        Create the LaTeX representation for the state

        :return: the LaTeX representation of the quaternion and body rate (q,w)
        :rtype: (str, str)
        """
        return (self.q.latex(), self.w.latex())

    __repr__ = __str__

    def __add__(self, x):
        """
        Create a combined state by summing the current instance with
        one provided.

        :param x: state to be added to the current
        :type  x: State
        :return: the combined states
        :rtype: State
        """
        q_new = self.q + x.q
        w_new = self.w + x.w
        return State(q_new, w_new)

    def __iadd__(self, x):
        """
        Same as the addition just maintains the current instance.

        :param x: state to be added onto me
        :type  x: State
        :return: the summed states
        :rtype: State
        """
        self.q += x.q
        self.w += x.w
        return self

    def __sub__(self, x):
        """
        Take the passed state off this instance.

        :param x: state to be taken off
        :type  x: State
        :return: reduced state
        :rtype: State
        """
        q_new = self.q - x.q
        w_new = self.w - x.w
        return State(q_new, w_new)

    def __isub__(self, x):
        """
        Same as the __sub__ method but maintains the current instance.

        :param x: state to be taken off
        :type  x: State
        :return: reduced state
        :rtype: State
        """
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
    :return: error generated from a quaternion multiplicative error
              and body rate diff
    :rtype: State
    """
    return State(
        QuaternionError(x_hat.q, x.q),
        x_hat.w - x.w)


class Plant(object):
    """
    Tracks the full system state of the TableSat

    :param I: the 3x3 moment of intertia matrix
    :type  I: np.matrix or list of lists
    :param x: initial condition
    :type  x: State
    :param clock: The system clock to quantify the time steps
    :type  clock: Clock.Metronome
    """

    def __init__(self, I, x, clock):
        self.pos = QuaternionDynamics(x.q, clock)
        self.vel = EulerMomentEquations(I, x.w, clock)

    @property
    def x(self):
        """
        Combine the quaternion and body rate from the QuaternionDynamics
        and Euler Moment Equations instances.

        :return: Current plant state
        :rtype: State
        """
        return State(self.pos.q, self.vel.w)

    def set_state(self, x):
        """
        When used for state estimation, the state of the plant may need to
        be set to a new value.

        :param x: set the plant to a new state
        :type  x: State
        """
        self.pos.q.vector = x.q.vector
        self.pos.q.scalar = x.q.scalar
        self.vel.w.w = x.w.w

    def propagate(self, M=None):
        """
        Propagate the state of the plant.  Based on an applied moment,
        propagate the body rate then quaternion states.

        :param M: Applied moment about the rigid body's principal axes (3x1)
        :type  M: 3 element list
        :return: new body rate and quaternion state (w, q)
        :rtype: w (BodyRate), q (Quaternion)
        """

        if M is None:
            M = Moment([0, 0, 0])
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


class Moment(object):
    """
    Represents moment couples about the body's principal axes.

    :param M: moments about each axis (3x1) (Mx, My, Mz)
    :type  M: list
    """

    float_threshold = 1e-12

    def __init__(self, M=None):
        if M is None:
            M = [0, 0, 0]

        self.M = np.mat(M, dtype=np.float)
        if self.M.shape == (1, 3):
            self.M = self.M.T

    def __add__(self, M):
        """
        Sum two moments

        :param M: moment to be added to the current instance
        :type  M: Moment
        :return: The summed moment
        :rtype: Moment
        """
        return Moment(self.M + M.M)

    def __sub__(self, M):
        """
        Diff of two moments

        :param M: moment to be subtracted from the current instance
        :type  M: Moment
        :return: The moment difference
        :rtype: Moment
        """
        return Moment(self.M - M.M)

    def __iadd__(self, M):
        """
        Useful if adding deltas to an existing moments instead of creating
        a new instance each time.

        :param M: moment to be added to the current instance
        :type  M: Moment
        :return: The summed moment
        :rtype: Moment
        """
        self.M += M.M
        return self

    def __isub__(self, M):
        """
        Useful if deduct deltas from an existing moments instead of creating
        a new instance each time.

        :param M: moment to be subtracted from the current instance
        :type  M: Moment
        :return: moment difference
        :rtype: Moment
        """
        self.M -= M.M
        return self

    def __eq__(self, M):
        """
        Helper function to test for equality considering floating point errors

        :param M: moment to be compared to the current instance
        :type  M: Moment
        :return: Are they equal within a threshold?
        :rtype: bool
        """
        return np.sum(np.abs(self.M - M.M)) < self.float_threshold

    def latex(self):
        """
        Create a LaTeX representation of the moment array

        :return: LaTeX quaternion str
        :rtype: str
        """
        msg = '%g \\boldsymbol{i} %+g \\boldsymbol{j} %+g \\boldsymbol{k}' % (
            self.M[0, 0], self.M[1, 0], self.M[2, 0],
        )
        return msg

    def __str__(self):
        """
        :return: representation of the moment
        :rtype:  str
        """
        return "<%s [%g %g %g]>" % (
            self.__class__.__name__,
            self.M[0, 0], self.M[1, 0], self.M[2, 0])

    __repr__ = __str__

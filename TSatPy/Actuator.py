
import numpy as np


class ActuatorException(Exception):
    pass


class Actuator(object):

    def __init__(self):
        self.actuators = []

    def add(self, type, set_level, kwargs):
        """
        Add an configured actuator to the array of actuators
        """
        if type.lower() == 'fan':
            act = self.config_fan(**kwargs)
        act._set_level = set_level
        self.actuators.append(act)

    def config_fan(self, name, center, direction):
        """
        Configure a fan to be added to the array of actuators.
        """
        return Fan(name, center, direction)

    def request_moment(self, M):
        """
        Request a moment from the actuators.
        * Determine which actuators can contribute
        * If multiple can contribute, divide up the work

        TODO: Generalize to allow actuators to be off axis
        """
        levels = []
        for idx in xrange(3):
            members = []
            axis = np.mat([0,0,0], dtype=np.float).T
            axis[idx, 0] = 1.0

            total = 0
            for act in self.actuators:
                if M[idx,0] == 0:
                    continue
                if not np.sign(M[idx,0]) == np.sign(act.moment[idx,0]):
                    continue
                total += act.moment[idx,0]
                members.append(act)

            if total == 0:
                levels.append((0, 0))
                continue
            level = min(M[idx,0] / total, 1.0)

            for act in members:
                act.set_level(act, level)
            levels.append((level, total))

        return np.mat([
            [levels[0][0] * levels[0][1]],
            [levels[1][0] * levels[1][1]],
            [levels[2][0] * levels[2][1]],
        ])

    def __str__(self):
        act_str = [self.__class__.__name__]
        for act in self.actuators:
            act_str.append(' ' + str(act))
        return '\n'.join(act_str)


class ActuatorBase(object):

    def set_level(self, act, level):
        self._set_level(act, level)


class Fan(ActuatorBase):

    def __init__(self, name, center, direction):
        self.name = name
        self.center = np.mat(center, dtype=float)
        self.direction = np.mat(direction, dtype=float)
        self.moment = np.cross(self.center, self.direction).T
        if not np.sum(self.moment == 0) == 2:
            msg = 'Actuator.request_moment requires that fans be mounted ' \
                  'to control a single body axis'
            raise ActuatorException(msg)

        if self.center.shape == (1, 3):
            self.center = self.center.T
        if self.direction.shape == (1, 3):
            self.direction = self.direction.T

        # Make sure it's a unit vector
        self.direction = self.direction/np.sqrt(
            self.direction.T * self.direction)

    def __str__(self):
        moment = '(%g, %g, %g)' % (
            self.moment[0,0], self.moment[1,0], self.moment[2,0])
        fan_str = '<%s %s moment=%s>' % (
            self.__class__.__name__, self.name, moment)
        return fan_str

    __repr__ = __str__

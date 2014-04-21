"""
The Actuator module is responsible for converting a moment that the
active control algorithm is requesting and figure out which actuators
are required to fulfill that request.  If the request is not possible,
attempt to create a moment that is close to the one requested.  Return
the actual moment applied to the estimator, controller for feedback loop.


Example::

    def msg_handler(act, power_level):
        print 'Setting power level=%g for: %s' % (power_level, act)

    configs = [{'type': 'fan', 'args': {'name': 'CW',
      'center': (0.2, 0, 0), 'direction': (0, 1, 0), 'F': 0.8}
    },{'type': 'fan', 'args': {'name': 'CCW',
      'center': (-0.2, 0, 0), 'direction': (0, 1, 0), 'F': 0.8}}]

    act = Actuator()
    for config in configs:
        act.add(config['type'], msg_handler, config['args'])
    print act
    M = np.mat([0, 0, 0.2])   # Request a moment that's too high
    print("Request moment: %s" % (M))
    print("Applied moment: %s" % (act.request_moment(M.T).T))
    M = np.mat([0, 0, -0.1])  # Request a sane moment
    print("Request moment: %s" % (M))
    print("Applied moment: %s" % (act.request_moment(M.T).T))

    Actuator
     <Fan CW moment=(0, 0, 0.16)>
     <Fan CCW moment=(0, 0, -0.16)>
    Request moment: [[ 0.   0.   0.2]]
    Setting power level=1 for: <Fan CW moment=(0, 0, 0.16)>
    Applied moment: [[ 0.    0.    0.16]]
    Request moment: [[ 0.   0.  -0.1]]
    Setting power level=0.625 for: <Fan CCW moment=(0, 0, -0.16)>
    Applied moment: [[ 0.   0.  -0.1]]
"""


import numpy as np


class ActuatorException(Exception):
    pass


class Actuator(object):
    """
    Main Actuator module.  All interactions from outside the actuators
    should go through here.
    """

    def __init__(self):
        # List of actuators that get added
        self.actuators = []

    def add(self, type, set_level, kwargs):
        """
        Add an configured actuator to the array of actuators

        :param type: Class of actuator being added ('fan')
        :type  type: str
        :param set_level: callback method for communication with the device
                          the actuator instance and set level [0-1] are passed
        :type  set_level: function
        :param kwargs: Arguments to be passed to the configuration method
        :type  kwargs: dict
        """
        if type.lower() == 'fan':
            # Only one type of actuator for now
            act = self.config_fan(**kwargs)

        # Set the callback function and add to the array of actuators
        act._set_level = set_level
        self.actuators.append(act)

    def config_fan(self, name, center, direction, F):
        """
        Configure a fan to be added to the array of actuators.

        :param name: Unique name for the fan
        :type  name: str
        :param center: Location of the fan's center (x,y,z)
        :type  center: list/tuple
        :param direction: vector defining the direction of force (x,y,z)
        :type  direction: list/tuple
        :param F: max force capable
        :type  F: numeric
        :return: configured fan instance
        :rtype: Actuator.Fan
        """
        # No pre processing needed here yet
        return Fan(name, center, direction, F)

    def request_moment(self, M):
        """
        The controller will call this method with the moment that it would
        like to see produced on the system.  This method will use the loaded
        configuration of actuators to produce as close to the requested
        moment as possible, call the set_level callback, and return the
        actual moment generated.

        Note:
            If multiple actuators can help, work should be distributed
            Current implementation requires actuators only control 1 axis

        :param M: moment requested (3x1)
        :type  M: numpy.matrix
        :return: Actual moment (3x1)
        :rtype: numpy.matrix
        """
        levels = []
        # Loop through the moments for each axis
        for idx in xrange(3):
            members = []
            # define the axis being calculated
            axis = np.mat([0, 0, 0], dtype=np.float).T
            axis[idx, 0] = 1.0

            # Find actuators that can contribute and the max
            # if they were all on
            total = 0
            for act in self.actuators:
                if M[idx, 0] == 0:
                    continue
                if not np.sign(M[idx, 0]) == np.sign(act.moment[idx, 0]):
                    continue
                total += act.moment[idx, 0]
                members.append(act)

            # Calculate the percent of the total moment needed
            if total == 0:
                levels.append((0, 0))
                continue
            level = min(M[idx, 0] / total, 1.0)

            # Send the level needed via callback method
            for act in members:
                act.set_level(act, level)
            levels.append((level, total))

        # Return what moment was actually set
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
    """
    Base level actuator
    """
    def set_level(self, act, level):
        """
        Helper method so the instance and level can be passed back
        to the callback method.

        :param act: Individual actuator instance to be controlled
        :type  act: ActuatorBase, Fan
        :param level: Fraction of max moment required
        :type  level: numeric
        """
        self._set_level(act, level)


class Fan(ActuatorBase):
    """
    A variable speed fan for thrust

    :param name: Unique name for the fan
    :type  name: str
    :param center: Location of the fan's center (x,y,z)
    :type  center: list/tuple
    :param direction: vector defining the direction of force (x,y,z)
    :type  direction: list/tuple
    :param F: max force capable
    :type  F: numeric
    """

    def __init__(self, name, center, direction, F):
        self.name = name
        self.center = np.mat(center, dtype=float)
        if self.center.shape == (1, 3):
            self.center = self.center.T
        self.direction = np.mat(direction, dtype=float)
        if self.direction.shape == (1, 3):
            self.direction = self.direction.T

        # Make sure the direction is a unit vector or the answer will
        # get scaled incorrectly
        self.direction = self.direction / np.sqrt(
            self.direction.T * self.direction)

        # Calculate the max moment possible via moment arm
        self.F = self.direction * F
        self.moment = np.cross(self.center.T, self.F.T).T
        if not np.sum(self.moment == 0) == 2:
            msg = 'Actuator.request_moment requires that fans be mounted ' \
                  'to control a single body axis'
            raise ActuatorException(msg)

    def __str__(self):
        moment = '(%g, %g, %g)' % (
            self.moment[0, 0], self.moment[1, 0], self.moment[2, 0])
        fan_str = '<%s %s moment=%s>' % (
            self.__class__.__name__, self.name, moment)
        return fan_str

    __repr__ = __str__

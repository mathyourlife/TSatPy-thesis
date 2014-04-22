"""
This module receives raw voltage measurements from either a simulated
truth model of the system or from the Comm module polling sensor voltage
data off the experimental system.

Each class represents a different sensor type (course sun sensor,
magnetometer, gyroscope, ...) and contain the logic to convert sensor
readings from that sensor into a state representation x with quaternion
and body rates.

* input: voltages (V)
* output: measured state (x)

"""

import numpy as np
from TSatPy.State import State


class Sensors(object):

    def __init__(self):
        self.v = None
        self.x = State()
        self.sensors = {
            'css': PhotoDiodeArray(),
            'mag': TripleAxisMagnetometer(),
        }

    def v_to_x(self, v):

        # Update CSS sensor with 1st 6 voltage readings
        self.sensors['css'].update_state(v[:6])
        # Then the triple threat from the magnetometer
        self.sensors['mag'].update_state(v[11:14])

        # TODO: Update state here??
        #       Probably not.  Leave this for the estimators if state
        #       information is redundant between sensors

        return self.x

    def __str__(self):
        states = []
        for sensor in self.sensors.values():
            states.append("<%s %s, %s>" % (
                sensor.__class__.__name__,
                sensor.x.q, sensor.x.w))
        return '\n'.join(states)


class SensorBase(object):
    def __init__(self):
        self.x = State()
        self.v = None

    def update_state(self, v):
        self.v = v

    def __str__(self):
        return "<%s %s, %s>" % (
            self.__class__.__name__,
            self.x.q, self.x.w)


class TripleAxisMagnetometer(SensorBase):
    pass


class PhotoDiodeArray(SensorBase):
    def __init__(self, diode_count=6):

        SensorBase.__init__(self)
        self.diode_count = diode_count
        self.angles = np.array([t * (2 * np.pi / self.diode_count)
            for t in range(self.diode_count)],
            dtype=np.float)
        self.angles_x = np.cos(self.angles)
        self.angles_y = np.sin(self.angles)
        self.theta = None

    def update_state(self, v):
        self.v = np.array(v, dtype=np.float)

        css_x = (self.angles_x * self.v).sum()
        css_y = (self.angles_y * self.v).sum()

        css_theta = np.arctan2(css_y, css_x)

        if css_theta < 0:
            css_theta += 2 * np.pi

        self.theta = css_theta
        self.x.q.from_rotation([0, 0, 1], radians=self.theta)

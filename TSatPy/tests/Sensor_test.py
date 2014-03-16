import unittest
from TSatPy import Sensor
import numpy as np


class TestPhotoDiodeArray(unittest.TestCase):
    def test_init(self):
        pd = Sensor.PhotoDiodeArray()

        self.assertEquals(6, pd.diode_count)
        self.assertTrue(
            np.all(np.abs(
                [0, np.pi/3, 2*np.pi/3, 3*np.pi/3, 4*np.pi/3, 5*np.pi/3] -
                pd.angles
            ) < 1E-14))
        self.assertTrue(
            np.all(np.abs(
                [1, 0.5, -0.5, -1, -0.5, 0.5] -
                pd.angles_x
            ) < 1E-14))

        y = np.sqrt(3)/2
        self.assertTrue(
            np.all(np.abs(
                [0, y, y, 0, -y, -y] -
                pd.angles_y
            ) < 1E-14))

    def test_update_state(self):
        pd = Sensor.PhotoDiodeArray()

        angles = [
            (0 * np.pi / 3, [1,0,0,0,0,0]),
            (1 * np.pi / 3, [0,1,0,0,0,0]),
            (2 * np.pi / 3, [0,0,1,0,0,0]),
            (3 * np.pi / 3, [0,0,0,1,0,0]),
            (4 * np.pi / 3, [0,0,0,0,1,0]),
            (5 * np.pi / 3, [0,0,0,0,0,1]),
        ]

        for angle in angles:
            t = pd.update_state(angle[1])
            self.assertTrue(np.abs(angle[0] - pd.theta) < 1E-14)

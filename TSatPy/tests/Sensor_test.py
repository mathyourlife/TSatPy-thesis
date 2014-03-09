import unittest
from TSatPy import Sensor
import numpy as np


class TestPhotoDiodeArray(unittest.TestCase):
    def test_init(self):
        pd = Sensor.PhotoDiodeArray()

        self.assertEquals(6, pd.diode_count)
        print pd.theta
        pd.update_state([1,0,0,0,0,0])
        print pd.theta
        pd.update_state([0,1,0,0,0,0])
        print pd.theta / np.pi * 180

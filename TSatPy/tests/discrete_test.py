import unittest
from mock import patch
from TSatPy import discrete
import time


class TestDerivative(unittest.TestCase):

    @patch('time.time')
    def test_derivative(self, mock_time, *args):

        mock_time.return_value = 1234

        d = discrete.Derivative()
        self.assertEquals(None, d.last_time)
        self.assertEquals(None, d.last_value)
        self.assertEquals(None, d.val)

        d.update(4)
        self.assertEquals(1234, d.last_time)
        self.assertEquals(4, d.last_value)
        self.assertEquals(None, d.val)

        d.update(6)
        self.assertEquals(1234, d.last_time)
        self.assertEquals(6, d.last_value)
        self.assertEquals(None, d.val)

        mock_time.return_value = 1237

        d.update(10)
        self.assertEquals(1237, d.last_time)
        self.assertEquals(10, d.last_value)
        self.assertEquals(4/3.0, d.val)

        s = '<Derivative rate:1.33333333333>'
        self.assertEquals(s, str(d))



if __name__ == "__main__":
    unittest.main()

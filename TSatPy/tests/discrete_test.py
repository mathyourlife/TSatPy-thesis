import unittest
from mock import patch
from TSatPy import discrete


class TestDerivative(unittest.TestCase):

    @patch('time.time')
    def test_derivative(self, mock_time):

        mock_time.return_value = 1234

        der = discrete.Derivative()
        self.assertEquals(None, der.last_time)
        self.assertEquals(None, der.last_value)
        self.assertEquals(None, der.val)

        der.update(4)
        self.assertEquals(1234, der.last_time)
        self.assertEquals(4, der.last_value)
        self.assertEquals(None, der.val)

        der.update(6)
        self.assertEquals(1234, der.last_time)
        self.assertEquals(6, der.last_value)
        self.assertEquals(None, der.val)

        mock_time.return_value = 1237

        der.update(10)
        self.assertEquals(1237, der.last_time)
        self.assertEquals(10, der.last_value)
        self.assertEquals(4/3.0, der.val)

        d_str = '<Derivative rate:1.33333333333>'
        self.assertEquals(d_str, str(der))

        der.reset()
        self.assertEquals(None, der.last_time)
        self.assertEquals(None, der.last_value)
        self.assertEquals(None, der.val)


if __name__ == "__main__":
    unittest.main()

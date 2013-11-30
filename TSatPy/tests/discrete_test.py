import unittest
from TSatPy import discrete

class TestDerivative(unittest.TestCase):

    def test_derivative(self):

        print 'aoue'
        d = discrete.Derivative()
        return
        d.update(4)
        print d.val, d
        self.assertTrue(True)

if __name__ == "__main__":
    unittest.main()

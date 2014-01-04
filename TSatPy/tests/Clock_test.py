import unittest
from mock import patch
from TSatPy.Clock import Metronome


class TestMetronome(unittest.TestCase):

    @patch('time.time')
    def test_ticks(self, MockTime, *args):

        # metronome starts at 3
        MockTime.return_value = 3
        clock = Metronome()

        # 8 seconds is 5 elapsed
        self.assertEquals(0, clock.tick())
        MockTime.return_value = 8
        self.assertEquals(5, clock.tick())

    @patch('time.time')
    def test_speed(self, MockTime, *args):

        # metronome starts at 3
        MockTime.return_value = 3
        clock = Metronome()
        clock.set_speed(3)

        # 3 for 5 seconds should count to 15 ticks
        self.assertEquals(0, clock.tick())
        MockTime.return_value = 8
        self.assertEquals(15, clock.tick())

        # 0.5 for 2 seconds should only add 1 tick
        clock.set_speed(0.5)
        MockTime.return_value = 10
        self.assertEquals(16, clock.tick())

        # Reverse time -2 for 3 seconds gets back to 10
        clock.set_speed(-2)
        MockTime.return_value = 13
        self.assertEquals(10, clock.tick())



"""
Simulation clock.   Control the flow of time.
"""

import time


class Metronome(object):
    """
    A metronome to track the passage of time.  Use the alter the flow of
    time for variable step control and for altered speed simulations.
    """

    def __init__(self):
        self.speed = 1
        self.speed_changed = 0
        self.start_marker = time.time()

    def tick(self):
        """
        Get the current clock time.  Take into consideration
        requests for speed changes so that any discrete derivative/integral
        calculations based on the clock work smoothly through the speed change

        If SPEED = 1 ticks are equivalent to seconds

        :return: Clock ticks
        :rtype:  float
        """

        return (time.time() - self.start_marker
            ) * self.speed + self.speed_changed

    def set_speed(self, speed):
        """
        Set the speed of the simulation clock.

        Note: speed parameter can go negative but may have adverse
        affects on simulation and controls logic.

        :param speed: Rate of time (ticks = seconds * speed)
        :type  speed: numeric
        """

        self.speed_changed = self.tick()
        self.start_marker = time.time()
        self.speed = speed

    def __str__(self):
        """
        Create a string representation of the clock time

        :return: system time
        :rtype: str
        """
        return "%gs" % self.tick()

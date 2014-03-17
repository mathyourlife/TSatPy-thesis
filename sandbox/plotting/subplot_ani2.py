import numpy as np
import matplotlib.pyplot as plt
from matplotlib.lines import Line2D
import matplotlib.animation as animation

# This example uses subclassing, but there is no reason that the proper function
# couldn't be set up and then use FuncAnimation. The code is long, but not
# really complex. The length is due solely to the fact that there are a total
# of 9 lines that need to be changed for the animation as well as 3 subplots
# that need initial set up.
class SubplotAnimation(animation.TimedAnimation):
    def __init__(self):
        fig = plt.figure()
        ax3 = fig.add_subplot(111)

        self.t = np.linspace(0, 50, 100)
        self.x = np.cos(2 * np.pi * self.t / 10.)
        self.y = np.sin(2 * np.pi * self.t / 10.)
        self.z = 10 * self.t

        ax3.set_xlabel('x')
        ax3.set_ylabel('z')
        self.line3 = Line2D([], [], color='black')
        ax3.add_line(self.line3)
        ax3.set_xlim(-1, 1)
        ax3.set_ylim(0, 800)

        animation.TimedAnimation.__init__(self, fig, interval=50, blit=True)

    def _draw_frame(self, framedata):
        i = framedata
        head = i - 1
        head_len = 10
        head_slice = (self.t > self.t[i] - 1.0) & (self.t < self.t[i])

        self.line3.set_data(self.x[:i], self.z[:i])

        #self._drawn_artists = [self.line3]

    def new_frame_seq(self):
        return iter(range(self.t.size))

    def _init_draw(self):
        lines =  [self.line3]
        for l in lines:
            l.set_data([], [])

ani = SubplotAnimation()
#ani.save('test_sub.mp4')
plt.show()

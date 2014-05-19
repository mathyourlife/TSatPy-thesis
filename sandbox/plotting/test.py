import numpy as np
import matplotlib.pyplot as plt
import matplotlib.animation as animation
from twisted.internet.task import LoopingCall

def update_line(line):
    line.set_data(np.random.rand(2, 25))

fig = plt.figure()

data = np.random.rand(2, 25)
l, = plt.plot([], [], 'r-')
plt.xlim(0, 1)
plt.ylim(0, 1)
plt.xlabel('x')
plt.title('test')

event_source = fig.canvas.new_timer()
event_source.interval = 100
def print_hi():
    print("hi")
event_source.add_callback(print_hi)

fig.canvas.mpl_connect('draw_event', event_source.start)

plt.show()


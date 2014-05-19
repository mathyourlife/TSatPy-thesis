from twisted.internet import tksupport, reactor
import matplotlib
from matplotlib.figure import Figure
import numpy as np
from matplotlib.backends.backend_tkagg import FigureCanvasTkAgg, NavigationToolbar2TkAgg
from twisted.internet.task import LoopingCall
import matplotlib.pyplot as plt

def testing():
    print("here")


def create_figure():
    f = Figure(figsize=(5,4), dpi=100)
    a = f.add_subplot(111)
    t = np.arange(0.0,3.0,0.01)
    s = np.sin(2*np.pi*t)

    l, = a.plot(t,s)

    return l, f


def update_it(l):
    print("update_it")
    t = np.arange(0.0,3.0,0.01)
    s = np.sin(2*np.pi*t)
    l.set_ydata(s)


l, f = create_figure()

lc = LoopingCall(update_it, (l))
lc.start(1)

plt.show()

# at this point build Tk app as usual using the root object,
# and start the program with "reactor.run()", and stop it
# with "reactor.stop()".

reactor.run()


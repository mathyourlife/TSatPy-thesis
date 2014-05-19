import Tkinter as Tk
from twisted.internet import tksupport, reactor
import matplotlib
from matplotlib.figure import Figure
import numpy as np
from matplotlib.backends.backend_tkagg import FigureCanvasTkAgg, NavigationToolbar2TkAgg
from twisted.internet.task import LoopingCall

def testing():
    print("here")


def create_figure():
    f = Figure(figsize=(5,4), dpi=100)
    a = f.add_subplot(111)
    t = np.arange(0.0,3.0,0.01)
    s = np.sin(2*np.pi*t)

    l, = a.plot(t,s)

    return l, f

def create_tk(f):

    root = Tk.Tk()
    root.wm_title("Embedding in TK")

    # a tk.DrawingArea
    canvas = FigureCanvasTkAgg(f, master=root)
    canvas.show()
    canvas.get_tk_widget().pack(side=Tk.TOP, fill=Tk.BOTH, expand=1)

    toolbar = NavigationToolbar2TkAgg( canvas, root )
    toolbar.update()
    canvas._tkcanvas.pack(side=Tk.TOP, fill=Tk.BOTH, expand=1)

    def _quit():
        root.quit()     # stops mainloop
        root.destroy()  # this is necessary on Windows to prevent
                        # Fatal Python Error: PyEval_RestoreThread: NULL tstate

    button = Tk.Button(master=root, text='Quit', command=_quit)
    button.pack(side=Tk.BOTTOM)

    return root


def update_it(l):
    print("update_it")
    t = np.arange(0.0,3.0,0.01)
    s = np.sin(2*np.pi*t)
    l.set_ydata(s)


l, f = create_figure()

lc = LoopingCall(update_it, (l))
lc.start(1)

root = create_tk(f)

# Install the Reactor support
tksupport.install(root)

# at this point build Tk app as usual using the root object,
# and start the program with "reactor.run()", and stop it
# with "reactor.stop()".

reactor.run()


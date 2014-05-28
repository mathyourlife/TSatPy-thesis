import sys
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.animation as animation
from matplotlib import rcParams
from mpl_toolkits.mplot3d import Axes3D
from TSatPy import State
from TSatPy import StateOperator

rcParams['text.usetex'] = True
rcParams['text.latex.unicode'] = True

def show(state):
    if isinstance(state, State.Quaternion):
        show_quaternion(state)

def show_quaternion(q):
    print("Quaternion\n\t%s" % q)
    sys.stdout.flush()
    refresh_rate = 0.1
    steps = 20

    fig, ax = new_figure()
    fig.subplots_adjust(left=0, bottom=0, right=1, top=1)
    ax.view_init(azim=-45, elev=15)

    info_text = q.latex().replace('boldsymbol', 'mathbf')
    info = ax.text(0.05, 0.9, 0,
        '$\mathbf{q} = %s$' % info_text, transform=ax.transAxes)
    info.set_x(1)
    info.set_y(1)
    help(info)
    add_rotation_axis(ax, q)

    model = TSatModel(ax)

    def frames():
        qg = StateOperator.QuaternionGain(1/float(steps))
        dq = qg * q
        q_viz = State.Identity()

        for i in range(steps):
            yield q_viz
            q_viz *= dq

    def func(q, model):
        model.update(q)

    kwargs = {
        'fig': fig,
        'func': func,
        'frames': frames,
        'blit': False,
        'interval': float(refresh_rate) * 1000,
        'fargs': [model],
    }
    ani = animation.FuncAnimation(**kwargs)

    ax.set_xlabel('x-axis')
    ax.set_ylabel('y-axis')
    ax.set_zlabel('z-axis')
    plt.show()


def new_figure():
    fig = plt.figure()
    ax = fig.add_subplot(111, projection='3d', aspect='equal')

    grid = {
        'grid' : {
            'color': (0, 0, 0, 0.2),
        }
    }
    ax.w_xaxis._axinfo.update(grid)
    ax.w_yaxis._axinfo.update(grid)
    ax.w_zaxis._axinfo.update(grid)

    ax.set_ylim(-1, 1)
    ax.set_xlim(-1, 1)
    ax.set_zlim(-1, 1)

    return fig, ax


class TSatModel():
    def __init__(self, ax, color='b'):
        self.ax = ax
        self.color = color
        self.series = {}
        self.radius = 0.2
        self.add_booms()
        self.setup_body()

    def update(self, q):
        for name, sdata in self.series.items():
            if sdata['type'] == 'line':
                p = q.rotate_points(sdata['points'])
                sdata['plot'].set_data(
                    np.asarray(p[:,0].T).reshape(-1),
                    np.asarray(p[:,1].T).reshape(-1))
                sdata['plot'].set_3d_properties(
                    np.asarray(p[:,2].T).reshape(-1))

    def setup_body(self):

        sides = 8
        self.series['body'] = {
            'type': 'line',
            'points': np.mat([
                self.radius * np.cos(np.linspace(0, 2 * np.pi, sides + 1)),
                self.radius * np.sin(np.linspace(0, 2 * np.pi, sides + 1)),
                np.zeros(sides + 1),
            ]).T,
            'plot': self.ax.plot([], [], [],
                color=self.color, ls='-', linewidth=2, ms=10)[0],
        }

    def add_booms(self):
        count = 2
        sdp_len = 0.6
        zeros = np.empty(count + 1)
        zeros.fill(0)

        # sdps
        pts = np.mat([
            np.arange(count + 1) * (sdp_len / float(count)) + self.radius,
            zeros.copy(),
            zeros.copy()]).T
        self.series['+x sdp'] = {
            'type': 'line',
            'points': pts,
            'plot': self.ax.plot([], [], [], color=self.color,
                ls='-', linewidth=2, ms=10)[0],
        }
        pts = np.mat([
            -(np.arange(count + 1) * (sdp_len / float(count)) + self.radius),
            zeros.copy(),
            zeros.copy()]).T
        self.series['-x sdp'] = {
            'type': 'line',
            'points': pts,
            'plot': self.ax.plot([], [], [], color=self.color,
                ls='-', linewidth=2, ms=10)[0],
        }
        pts = np.mat([
            zeros.copy(),
            np.arange(count + 1) * (sdp_len / float(count)) + self.radius,
            zeros.copy()]).T
        self.series['+y sdp'] = {
            'type': 'line',
            'points': pts,
            'plot': self.ax.plot([], [], [], color=self.color,
                ls='-', linewidth=2, ms=10)[0],
        }
        pts = np.mat([
            zeros.copy(),
            -(np.arange(count + 1) * (sdp_len / float(count)) + self.radius),
            zeros.copy()]).T
        self.series['-y sdp'] = {
            'type': 'line',
            'points': pts,
            'plot': self.ax.plot([], [], [], color=self.color,
                ls='-', linewidth=2, ms=10)[0],
        }

        # adps
        pts = np.mat([
            zeros.copy(),
            zeros.copy(),
            np.arange(count + 1) * (sdp_len / float(count)) + self.radius]).T
        self.series['+z adp'] = {
            'type': 'line',
            'points': pts,
            'plot': self.ax.plot([], [], [], color=self.color,
                ls='-', linewidth=2, ms=10)[0],
        }
        pts = np.mat([
            zeros.copy(),
            zeros.copy(),
            -(np.arange(count + 1) * (sdp_len / float(count)) + self.radius)]).T
        self.series['-z adp'] = {
            'type': 'line',
            'points': pts,
            'plot': self.ax.plot([], [], [], color=self.color,
                ls='-', linewidth=2, ms=10)[0],
        }

def add_rotation_axis(ax, q):

    vector, theta = q.to_rotation()
    qv = np.asarray(vector)
    r_axis = np.hstack([qv, -qv])

    ax.plot(r_axis[0,:], r_axis[1,:], r_axis[2,:], color='r',
        ls='--', linewidth=4, ms=10)



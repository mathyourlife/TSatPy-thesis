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

def show(state, title=None):
    if isinstance(state, State.Quaternion):
        show_quaternion(state, title)

def show_quaternion(q, title=None):
    print(q)
    sys.stdout.flush()
    refresh_rate = 0.1
    steps = 20

    fig, ax = new_figure()
    if title:
        ax.set_title(title)
    ax.view_init(azim=-45, elev=15)

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

def show_quaternion_multiplication(q, dq, title=None):
    print(q)
    print(dq)
    sys.stdout.flush()
    refresh_rate = 1
    steps = 20

    fig, ax = new_figure()
    if title:
        ax.set_title(title)
    ax.view_init(azim=-45, elev=15)

    add_rotation_axis(ax, dq)

    model = TSatModel(ax)

    def make_frames(q, dq):
        import sys
        def frames():
            for i in range(steps):
                yield q
                print('q ')
                sys.stdout.flush()
                q *= dq
        return frames

    def func(q, model):
        model.update(q)

    kwargs = {
        'fig': fig,
        'func': func,
        'frames': make_frames(q, dq),
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
    fig.subplots_adjust(left=0, bottom=0, right=1, top=1)

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
        self.labels = {}
        self.radius = 0.2
        self.adp_len = 0.4
        self.sdp_len = 0.6
        self.add_booms()
        self.add_body()
        self.add_labels()

    def update(self, q):
        for name, sdata in self.series.items():
            p = q.rotate_points(sdata['points'])
            sdata['plot'].set_data(
                np.asarray(p[:,0].T).reshape(-1),
                np.asarray(p[:,1].T).reshape(-1))
            sdata['plot'].set_3d_properties(
                np.asarray(p[:,2].T).reshape(-1))
        for name, sdata in self.labels.items():
            p = q.rotate_points(sdata['points'])
            sdata['plot'].set_x(p[0,0])
            sdata['plot'].set_y(p[0,1])
            sdata['plot'].set_3d_properties(p[0,2], sdata['zdir'])

    def add_labels(self):
        x_pt = np.mat([self.radius + self.sdp_len, 0, 0])
        y_pt = np.mat([0, self.radius + self.sdp_len, 0])
        z_pt = np.mat([0, 0, self.radius + self.adp_len])

        x_dir = tuple(np.asarray( x_pt / np.sqrt(x_pt * x_pt.T)[0,0] ).tolist()[0])
        y_dir = tuple(np.asarray( y_pt / np.sqrt(y_pt * y_pt.T)[0,0] ).tolist()[0])
        z_dir = tuple(np.asarray( z_pt / np.sqrt(z_pt * z_pt.T)[0,0] ).tolist()[0])

        self.labels = {
            'x': {
                'points': x_pt,
                'plot': self.ax.text(
                    x_pt[0, 0], x_pt[0, 1], x_pt[0, 2], '$\mathbf{x}$', x_dir),
                'zdir': x_dir,
            },
            'y': {
                'points': y_pt,
                'plot': self.ax.text(
                    y_pt[0, 0], y_pt[0, 1], y_pt[0, 2], '$\mathbf{y}$', y_dir),
                'zdir': y_dir,
            },
            'z': {
                'points': z_pt,
                'plot': self.ax.text(
                    z_pt[0, 0], z_pt[0, 1], z_pt[0, 2], '$\mathbf{z}$', x_dir),
                'zdir': x_dir,
            },
        }

    def add_body(self):

        sides = 8
        self.series['body'] = {
            'type': 'line',
            'points': np.mat([
                self.radius * np.cos(np.linspace(0, 2 * np.pi, sides + 1) + 2 * np.pi / sides / 2),
                self.radius * np.sin(np.linspace(0, 2 * np.pi, sides + 1) + 2 * np.pi / sides / 2),
                np.zeros(sides + 1),
            ]).T,
            'plot': self.ax.plot([], [], [],
                color=self.color, ls='-', linewidth=2, ms=10)[0],
        }

    def add_booms(self):
        count = 2
        zeros = np.empty(count + 1)
        zeros.fill(0)

        # sdps
        pts = np.mat([
            np.arange(count + 1) * (self.sdp_len / float(count)) + self.radius,
            zeros.copy(),
            zeros.copy()]).T
        self.series['+x sdp'] = {
            'type': 'line',
            'points': pts,
            'plot': self.ax.plot([], [], [], color=self.color,
                ls='-', linewidth=2, ms=10)[0],
        }
        pts = np.mat([
            -(np.arange(count + 1) * (self.sdp_len / float(count)) + self.radius),
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
            np.arange(count + 1) * (self.sdp_len / float(count)) + self.radius,
            zeros.copy()]).T
        self.series['+y sdp'] = {
            'type': 'line',
            'points': pts,
            'plot': self.ax.plot([], [], [], color=self.color,
                ls='-', linewidth=2, ms=10)[0],
        }
        pts = np.mat([
            zeros.copy(),
            -(np.arange(count + 1) * (self.sdp_len / float(count)) + self.radius),
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
            np.arange(count + 1) * (self.adp_len / float(count)) + self.radius]).T
        self.series['+z adp'] = {
            'type': 'line',
            'points': pts,
            'plot': self.ax.plot([], [], [], color=self.color,
                ls='-', linewidth=2, ms=10)[0],
        }
        pts = np.mat([
            zeros.copy(),
            zeros.copy(),
            -(np.arange(count + 1) * (self.adp_len / float(count)) + self.radius)]).T
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




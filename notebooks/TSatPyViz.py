import sys
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.animation as animation
from matplotlib import rcParams
from mpl_toolkits.mplot3d import Axes3D
from TSatPy import State, StateOperator, Estimator
from TSatPy.Clock import Metronome


rcParams['text.usetex'] = True
rcParams['text.latex.unicode'] = True

def show(state, title=None):
    if isinstance(state, State.Quaternion):
        show_quaternion(state, title)

def show_tmqvb(q):

    refresh_rate = 0.3
    steps = 20
    template = r"""Theta Multiplier with Quaternion Vector Balancing
$\mathbf{\psi}(\mathbf{q}, %g) = \left( \begin{array}{c} \mathbf{v} / \gamma \\ \cos ( %g \cdot \cos^{-1} (q_0))  \end{array} \right)$
$\gamma = \sqrt{\frac{\mathbf{v} \bullet \mathbf{v}}{\sin^2 ( %g \cdot \cos^{-1} (q_0))}}$"""
    fig, ax = new_figure()
    text = ax.text2D(0.5, 0.95, template % (0,0,0), fontsize=24, transform=ax.transAxes,
        horizontalalignment='center', verticalalignment='top')

    add_rotation_axis(ax, q)


    model = TSatModel(ax)

    def frames():
        qg = StateOperator.QuaternionGain(1/float(steps))
        dq = qg * q
        q_viz = State.Identity()

        for i in range(steps):
            yield i * 1/float(steps), q_viz
            q_viz *= dq

    def func(arg, model):
        k, q = arg
        text.set_text(template % (k,k,k))
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


def show_quaternion(q, title=None):

    if title:
        title += '\n$\mathbf{q} = %s$' % str(q.latex().replace('boldsymbol','mathbf'))
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

    refresh_rate = 1
    steps = 60

    fig, ax = new_figure()
    if title:
        ax.text2D(0.5, 0.95, title, fontsize=24, transform=ax.transAxes,
            horizontalalignment='center', verticalalignment='top')
    ax.view_init(azim=-45, elev=15)

    add_rotation_axis(ax, dq)

    model = TSatModel(ax)

    def frames():
        q_track = State.Quaternion(q.vector, q.scalar)
        for i in range(steps):
            yield q_track
            q_track *= dq


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
            sdata['plot'].set_3d_properties(p[0,2], zdir=None)

    def add_labels(self):
        x_pt = np.mat([self.radius + self.sdp_len, 0, 0])
        y_pt = np.mat([0, self.radius + self.sdp_len, 0])
        z_pt = np.mat([0, 0, self.radius + self.adp_len])

        self.labels = {
            'x': {
                'points': x_pt,
                'plot': self.ax.text(x_pt[0, 0], x_pt[0, 1], x_pt[0, 2],
                    '$\mathbf{x}$', zdir=None, fontsize=24),
            },
            'y': {
                'points': y_pt,
                'plot': self.ax.text(y_pt[0, 0], y_pt[0, 1], y_pt[0, 2],
                    '$\mathbf{y}$', zdir=None, fontsize=24),
            },
            'z': {
                'points': z_pt,
                'plot': self.ax.text(z_pt[0, 0], z_pt[0, 1], z_pt[0, 2],
                    '$\mathbf{z}$', zdir=None, fontsize=24),
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


from matplotlib.widgets import Slider
def dq_adjust():
    fontsize = 30

    fig, ax = plt.subplots()
    fig.subplots_adjust(bottom=0.3, left=0, top=1, right=1)

    e = [1,1,0]
    theta = -0.5
    q0 = State.Quaternion(e, radians=theta)

    ax.text(0.5, 0.9, 'Quaternion Sums and Differences Introduce Error', horizontalalignment='center', fontsize=fontsize)

    q0_angle_template = r'Rotation about $\mathbf{\hat{e}} = %g \mathbf{i} %+g \mathbf{j} %+g \mathbf{k}$ of %g radians'
    e, r = q0.to_rotation()
    q0_angle_template_text = ax.text(0.5, 0.7,
        q0_angle_template % (e[0], e[1], e[2], r),
        horizontalalignment='center', fontsize=fontsize)


    q0_text_template = r'$\mathbf{q}(0) = %g \mathbf{i} %+g \mathbf{j} %+g \mathbf{k} %+g$'
    q0_text = ax.text(0.5, 0.6, q0_text_template % tuple(q0.mat), horizontalalignment='center', fontsize=fontsize)

    dq_text_template = r'$\delta \mathbf{q}: \mathbf{v} = %g \mathbf{i} %+g \mathbf{j} %+g$ with rotation $\mathbf{\theta} = %g$ radians'
    dq_text = ax.text(0.5, 0.4, dq_text_template % (0,0,0,0), horizontalalignment='center', fontsize=fontsize)

    q1_norm_text_template = r'$norm(\mathbf{q}(0) + \delta \mathbf{q}) = %g \mathbf{i} %+g \mathbf{j} %+g \mathbf{k} %+g$'
    q1_norm_text = ax.text(0.5, 0.2, q1_norm_text_template % tuple(q0.mat), horizontalalignment='center', fontsize=fontsize)

    q1_angle_template = r'Rotation about $\mathbf{\hat{e}} = %g \mathbf{i} %+g \mathbf{j} %+g \mathbf{k}$ of %g radians'
    q1_angle = ax.text(0.5, 0.1, q1_angle_template % (e[0], e[1], e[2], r), horizontalalignment='center', fontsize=fontsize)

    def on_change(val):
        dq_text.set_text(dq_text_template % tuple([float(slider.val) for slider in sliders]))

        dq = np.array([float(slider.val) for slider in sliders])

        qsum = (np.array(q0.mat.T) + dq)
        q1 = State.Quaternion(qsum[0,0:3], np.cos(qsum[0,3] / 2))
        q1.normalize()
        e, r = q1.to_rotation()

        q1_angle.set_text(q1_angle_template % (e[0], e[1], e[2], r))

        mag = np.sqrt(np.sum(qsum * qsum))
        q1_mat = qsum / mag
        q1 = State.Quaternion(q1_mat[0,0:3], q1_mat[0,3])
        q1_norm_text.set_text(q1_norm_text_template % (q1.vector[0], q1.vector[1], q1.vector[2], q1.scalar))

    def make_slider(n):
        labels = ["$\mathbf{X}$", "$\mathbf{Y}$", "$\mathbf{Z}$", "$\mathbf{R}$"]
        slider_ax = plt.axes([0.1, 0.25 - n * 0.05, 0.8, 0.04])
        if n == 3:
            slider = Slider(slider_ax, labels[n], -2 * np.pi, 2 * np.pi, valinit=0, color='#AAAAEE')
        else:
            slider = Slider(slider_ax, labels[n], -1, 1, valinit=0, color='#AAAAEE')
        slider.on_changed(on_change)
        return slider

    sliders = []
    for n in range(4):
        sliders.append(make_slider(n))
    plt.show()


def show_pid():

    refresh_rate = 0.3
    steps = 400

    fig, ax = new_figure()
    fig.subplots_adjust(bottom=0.3, left=0, top=1, right=1)
    ax.view_init(azim=-45, elev=15)

    # add_rotation_axis(ax, q)
    model_meas = TSatModel(ax, 'b')
    model_est = TSatModel(ax, 'r')

    G = {
        'Kpq': 0,
        'Kpw': 0,
        'Kiq': 0,
        'Kiw': 0,
        'Kdq': 0,
        'Kdw': 0,
    }
    c = Metronome()

    x = State.State(
        State.Quaternion([0, 0, 1],radians=np.pi/15),
        State.BodyRate([0, 0, 0.3]))
    I = [[4, 0, 0], [0, 4, 0], [0, 0, 4]]
    p_meas = State.Plant(I, x, c)
    p_est = State.Plant(I, State.State(), c)


    pid = Estimator.PID(c, plant=p_est)

    def frames():
        for _ in range(steps):
            p_meas.propagate()
            x_hat = pid.update(p_meas.x)
            yield p_meas.x, x_hat

    def func(xs, model_meas, model_est):
        x_meas, x_est = xs
        model_meas.update(x_meas.q)
        model_est.update(x_est.q)

    kwargs = {
        'fig': fig,
        'func': func,
        'frames': frames,
        'blit': False,
        'interval': float(refresh_rate) * 1000,
        'fargs': [model_meas, model_est],
    }
    ani = animation.FuncAnimation(**kwargs)

    def on_change(val):

        for key in G.keys():
            G[key] = sliders[key].val

        Kp = StateOperator.StateGain(
            StateOperator.QuaternionGain(G['Kpq']),
            StateOperator.BodyRateGain(np.eye(3) * G['Kpw']))
        pid.set_Kp(Kp)

        Ki = StateOperator.StateGain(
            StateOperator.QuaternionGain(G['Kiq']),
            StateOperator.BodyRateGain(np.eye(3) * G['Kiw']))
        pid.set_Ki(Ki)

        Kd = StateOperator.StateGain(
            StateOperator.QuaternionGain(G['Kdq']),
            StateOperator.BodyRateGain(np.eye(3) * G['Kdw']))
        pid.set_Ki(Kd)

    sliders = {
        'Kpq': Slider(plt.axes([0.1, 0.25, 0.8, 0.03]), 'Kpq', 0, 1, valinit=0, color='#AAAAEE'),
        'Kpw': Slider(plt.axes([0.1, 0.22, 0.8, 0.03]), 'Kpw', 0, 1, valinit=0, color='#AAAAEE'),
        'Kiq': Slider(plt.axes([0.1, 0.19, 0.8, 0.03]), 'Kiq', 0, 0.01, valinit=0, color='#AAAAEE'),
        'Kiw': Slider(plt.axes([0.1, 0.16, 0.8, 0.03]), 'Kiw', 0, 0.01, valinit=0, color='#AAAAEE'),
        'Kdq': Slider(plt.axes([0.1, 0.13, 0.8, 0.03]), 'Kdq', 0, 0.01, valinit=0, color='#AAAAEE'),
        'Kdw': Slider(plt.axes([0.1, 0.10, 0.8, 0.03]), 'Kdw', 0, 0.01, valinit=0, color='#AAAAEE'),
    }

    for key in sliders.keys():
        sliders[key].on_changed(on_change)

    ax.set_xlabel('x-axis')
    ax.set_ylabel('y-axis')
    ax.set_zlabel('z-axis')
    plt.show()

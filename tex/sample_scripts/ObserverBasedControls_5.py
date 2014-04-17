from TSatPy import StateOperators, Estimator, State
from TSatPy.Clock import Metronome
import numpy as np
import matplotlib.pyplot as plt
from matplotlib import rc
rc('text', usetex=True)
import time

print('P-Estimator With a Propagated State')

x_ic = State.State(
    State.Quaternion([0,0,1],radians=190/180.0*np.pi),
    State.BodyRate([0,0,0.3]))

k = 0.2
Kp = StateOperators.StateGain(
    StateOperators.QuaternionGain(k),
    StateOperators.BodyRateGain(np.eye(3) * k))

c = Metronome()
pid = Estimator.PID(c, ic=x_ic)
pid.set_Kp(Kp)

x_m = State.State(
    State.Quaternion([0,0.1,1],radians=44/180.0*np.pi),
    State.BodyRate([0,0,3.1]))

I = [[2, 0, 0], [0, 2, 0], [0, 0, 2]]
p = State.Plant(I, x_m, c)

N = 10
ts = []
measured = {
    'eulers': [],
    'scalars': [],
    'bodyrates': [],
}
est = {
    'eulers': [],
    'scalars': [],
    'bodyrates': [],
}

end_time = c.tick() + N
while c.tick() <= end_time:
    p.propagate()
    pid.update(p.x)
    ts.append(c.tick())
    measured['eulers'].append(p.x.q.vector.T.tolist()[0])
    measured['scalars'].append(p.x.q.scalar)
    measured['bodyrates'].append(p.x.w.w.T.tolist()[0])
    est['eulers'].append(pid.x_hat.q.vector.T.tolist()[0])
    est['scalars'].append(pid.x_hat.q.scalar)
    est['bodyrates'].append(pid.x_hat.w.w.T.tolist()[0])
    time.sleep(0.1)


def state_parameter_timeseries(x, measured, est):

    axes = []
    fig = plt.figure(figsize=(11,9), dpi=80, facecolor='w', edgecolor='k')

    axes.append(fig.add_subplot(4,2,1))
    axes[-1].plot(x, [e[0] for e in measured['eulers']], c='r', lw=2)
    axes[-1].plot(x, [e[0] for e in est['eulers']], c='b', lw=2)
    axes.append(fig.add_subplot(4,2,3))
    axes[-1].plot(x, [e[1] for e in measured['eulers']], c='r', lw=2)
    axes[-1].plot(x, [e[1] for e in est['eulers']], c='b', lw=2)
    axes.append(fig.add_subplot(4,2,5))
    axes[-1].plot(x, [e[2] for e in measured['eulers']], c='r', lw=2)
    axes[-1].plot(x, [e[2] for e in est['eulers']], c='b', lw=2)

    axes.append(fig.add_subplot(4,2,7))
    axes[-1].plot(x, measured['scalars'], c='r', lw=2)
    axes[-1].plot(x, est['scalars'], c='b', lw=2)
    axes[-1].set_xlabel('$t(k)$')

    axes.append(fig.add_subplot(4,2,2))
    axes[-1].plot(x, [w[0] for w in measured['bodyrates']], c='r', lw=2)
    axes[-1].plot(x, [w[0] for w in est['bodyrates']], c='b', lw=2)
    axes.append(fig.add_subplot(4,2,4))
    axes[-1].plot(x, [w[1] for w in measured['bodyrates']], c='r', lw=2)
    axes[-1].plot(x, [w[1] for w in est['bodyrates']], c='b', lw=2)
    axes.append(fig.add_subplot(4,2,6))
    axes[-1].plot(x, [w[2] for w in measured['bodyrates']], c='r', lw=2)
    axes[-1].plot(x, [w[2] for w in est['bodyrates']], c='b', lw=2)
    axes[-1].set_xlabel('$t(k)$')

    for ax in axes:
        ax.grid(color='0.75', linestyle='--', linewidth=1)

    for ax, label in zip(axes, ['q_1','q_2','q_3','q_0','\omega_1','\omega_2','\omega_3']):
        ax.set_ylabel('$%s$' % label)

    plt.tight_layout()
    plt.show()


state_parameter_timeseries(ts, measured, est)

from TSatPy import StateOperators, Estimator, State
from TSatPy.Clock import Metronome
import numpy as np
import matplotlib.pyplot as plt
from matplotlib import rc
rc('text', usetex=True)

print('P-Estimator With a Static Measured State')

x_ic = State.State(
    State.Quaternion([0,0,1],radians=190/180.0*np.pi),
    State.BodyRate([0,0,3]))

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

N = 40
ks = range(N)
eulers = np.empty([N, 3], dtype=np.float)
scalars = np.empty(N, dtype=np.float)
bodyrates = np.empty([N, 3], dtype=np.float)
for k in xrange(N):
    pid.update(x_m)
    eulers[k,:] = pid.x_hat.q.vector.T
    scalars[k] = pid.x_hat.q.scalar
    bodyrates[k,:] = pid.x_hat.w.w.T

def state_parameter_timeseries(eulers, scalars, bodyrates):

    axes = []
    fig = plt.figure(figsize=(11,9), dpi=80, facecolor='w', edgecolor='k')

    axes.append(fig.add_subplot(4,2,1))
    axes[-1].plot(ks, eulers[:,0], c='b', lw=2)
    axes.append(fig.add_subplot(4,2,3))
    axes[-1].plot(ks, eulers[:,1], c='b', lw=2)
    axes.append(fig.add_subplot(4,2,5))
    axes[-1].plot(ks, eulers[:,2], c='b', lw=2)

    axes.append(fig.add_subplot(4,2,7))
    axes[-1].plot(ks, scalars, c='b', lw=2)
    axes[-1].set_xlabel('$k$')

    axes.append(fig.add_subplot(4,2,2))
    axes[-1].plot(ks, bodyrates[:,0], c='b', lw=2)
    axes.append(fig.add_subplot(4,2,4))
    axes[-1].plot(ks, bodyrates[:,1], c='b', lw=2)
    axes.append(fig.add_subplot(4,2,6))
    axes[-1].plot(ks, bodyrates[:,2], c='b', lw=2)
    axes[-1].set_xlabel('$k$')

    for ax in axes:
        ax.grid(color='0.75', linestyle='--', linewidth=1)

    for ax, label in zip(axes, ['q_1','q_2','q_3','q_0','\omega_x','\omega_y','\omega_z']):
        ax.set_ylabel('$%s$' % label)

    target = [x_m.q.vector[0,0],x_m.q.vector[1,0],x_m.q.vector[2,0],x_m.q.scalar,
        x_m.w.w[0,0],x_m.w.w[1,0],x_m.w.w[2,0]]
    for ax, y in zip(axes, target):
        ax.axhline(y=y, color='r', linewidth=2, zorder=1)

    plt.tight_layout()
    plt.show()


state_parameter_timeseries(eulers, scalars, bodyrates)


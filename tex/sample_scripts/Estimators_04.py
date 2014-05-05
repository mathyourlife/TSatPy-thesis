from TSatPy import Estimator, State, StateOperator
from TSatPy.Clock import Metronome
import numpy as np
import matplotlib.pyplot as plt
import time
import random

print('Derivative State Error')

c = Metronome()

def integrate_error(dt, varied=False):
    x_m = State.State(
        State.Identity(),
        State.BodyRate([0,0,0.01]))

    I = [[2, 0, 0], [0, 2, 0], [0, 0, 2]]
    p = State.Plant(I, x_m, c)

    k = 0.01
    Kd = StateOperator.StateGain(
        StateOperator.QuaternionGain(k),
        StateOperator.BodyRateGain(np.eye(3) * k))

    pid = Estimator.PID(c)
    pid.set_Kd(Kd)
    start_time = c.tick()
    dts = [0.05, 0.4]
    ts = []
    degs = []
    end_time = c.tick() + 3
    while c.tick() < end_time:
        q, w = p.propagate()
        x_m = State.State(q, w)

        pid.update(x_m)
        ts.append(c.tick() - start_time)

        e, r = pid.x_adj.q.to_rotation()
        degs.append(r)
        if varied:
            random.shuffle(dts)
            time.sleep(dts[0])
        else:
            time.sleep(dt)
    return ts, degs

fig = plt.figure(dpi=80, facecolor='w', edgecolor='k')

ax = fig.add_subplot(1,1,1)
ts, degs = integrate_error(0.4)
ax.scatter(ts, degs, c='b', label='$\Delta t=0.4s$')

ts, degs = integrate_error(0.1)
ax.scatter(ts, degs, c='r', label='$\Delta t=0.1s$')

ts, degs = integrate_error(0, True)
ax.scatter(ts, degs, c='g', label='$\Delta t=0.05,0.4s$')

ax.grid(color='0.75', linestyle='--', linewidth=1)
ax.set_ylabel(r'$\theta_{adj}$ radians')
ax.set_xlabel('$t(k)$ seconds')

plt.legend()
plt.tight_layout()
plt.show()
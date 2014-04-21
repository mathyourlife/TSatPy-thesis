from TSatPy import Estimator, State, StateOperator
from TSatPy.Clock import Metronome
import numpy as np
import matplotlib.pyplot as plt
import time
import random


print('Integrated State Error')


c = Metronome()

def integrate_error(dt, varied=False):

    x_m = State.State(
        State.Quaternion([0,0,1],radians=0.05),
        State.BodyRate([0,0,0.01]))

    k = 0.01
    Ki = StateOperator.StateGain(
        StateOperator.QuaternionGain(k),
        StateOperator.BodyRateGain(np.eye(3) * k))

    pid = Estimator.PID(c)
    pid.set_Ki(Ki)
    start_time = c.tick()
    dts = [0.05, 0.4]
    ts = []
    degs = []
    end_time = c.tick() + 30
    while c.tick() < end_time:
        pid.update(x_m)
        ts.append(c.tick() - start_time)

        e, r = pid.x_hat.q.to_rotation()
        degs.append(r)
        if varied:
            random.shuffle(dts)
            time.sleep(dts[0])
        else:
            time.sleep(dt)
    return ts, degs

fig = plt.figure(dpi=80, facecolor='w', edgecolor='k')

ts, degs = integrate_error(0.4)
ax = fig.add_subplot(1,1,1)
ax.scatter(ts, degs, c='b')

ts, degs = integrate_error(0.1)
ax.scatter(ts, degs, c='r')

ts, degs = integrate_error(0, True)
ax.scatter(ts, degs, c='g')

ax.grid(color='0.75', linestyle='--', linewidth=1)
ax.set_ylabel(r'$\hat{\theta}$ radians')
ax.set_xlabel('$t(k)$ seconds')

plt.tight_layout()
plt.show()

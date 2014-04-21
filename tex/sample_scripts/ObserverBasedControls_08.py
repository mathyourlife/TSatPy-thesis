import sys
from TSatPy import Estimator, State, StateOperator
from TSatPy.Clock import Metronome
import numpy as np
import matplotlib.pyplot as plt
import time
import random


print('PID Estimation - No state prediction')

speed = 10
c = Metronome()
c.set_speed(speed)

def grid_me(ax):
    ax.grid(color='0.75', linestyle='--', linewidth=1)

def run_test(p,i,d,plot=False):
    ts, q_tracking, w_tracking = integrate_error(p,i,d)

    if plot:
        fig = plt.figure(dpi=80, facecolor='w', edgecolor='k')
        ax1 = fig.add_subplot(4,1,1)
        ax1.scatter(ts, q_tracking['measured'], c='b', label='measured')
        ax1.scatter(ts, q_tracking['estimated'], c='r', label='estimated')
        grid_me(ax1)
        ax1.set_ylabel(r'$\theta$ (rad)')
        plt.legend()

        ax = fig.add_subplot(4,1,2,sharex=ax1)
        ax.scatter(ts, q_tracking['err'], c='g', label=r'$\theta_{e}$')
        grid_me(ax)
        ax.set_ylabel(r'$\theta_{e}$ (rad)')

        ax = fig.add_subplot(4,1,3,sharex=ax1)
        ax.scatter(ts, w_tracking['measured'], c='b', label='measured')
        ax.scatter(ts, w_tracking['estimated'], c='r', label='estimated')
        grid_me(ax)
        ax.set_ylabel(r'$\omega_z$ (rad/s)')
        plt.legend()

        ax = fig.add_subplot(4,1,4,sharex=ax1)
        ax.scatter(ts, w_tracking['err'], c='g', label=r'$\omega_{ze}$')
        grid_me(ax)
        ax.set_ylabel(r'$\omega_{ze}$ (rad/s)')
        ax.set_xlabel('$t(k)$ seconds')

        plt.tight_layout()
        plt.show()

    return ts, q_tracking, w_tracking


def integrate_error(p,i,d):

    x_m = State.State(
        State.Identity(),
        State.BodyRate([0,0,0.314]))

    I = [[2, 0, 0], [0, 2, 0], [0, 0, 2]]
    plant = State.Plant(I, x_m, c)

    kp = {'q': p, 'w': 0.7}
    Kp = StateOperator.StateGain(
        StateOperator.QuaternionGain(kp['q']),
        StateOperator.BodyRateGain(np.eye(3) * kp['w']))
    ki = {'q': i, 'w': 0.0}
    Ki = StateOperator.StateGain(
        StateOperator.QuaternionGain(ki['q']),
        StateOperator.BodyRateGain(np.eye(3) * ki['w']))
    kd = {'q': d, 'w': 0.0}
    Kd = StateOperator.StateGain(
        StateOperator.QuaternionGain(kd['q']),
        StateOperator.BodyRateGain(np.eye(3) * kd['w']))

    pid = Estimator.PID(c)
    pid.set_Kp(Kp)
    pid.set_Ki(Ki)
    pid.set_Kd(Kd)

    start_time = c.tick()
    ts = []
    q_tracking = {
        'measured': [],
        'estimated': [],
        'err': [],
    }
    w_tracking = {
        'measured': [],
        'estimated': [],
        'err': [],
    }
    dts = [0.8, 1.2]
    end_time = c.tick() + 120
    while c.tick() < end_time:
        # sys.stdout.write("\b\b\b\b%s" % int(c.tick() - start_time))
        # sys.stdout.flush()

        q, w = plant.propagate()

        # Create measurement noise
        offset = np.random.randn() * 20 / 180.0 * np.pi
        q_noise = State.Quaternion([0,0,1], radians=offset) * q

        x_m = State.State(q_noise, w)
        pid.update(x_m)

        ts.append(c.tick() - start_time)

        e, r = q.to_rotation()
        q_tracking['measured'].append(r)
        e, r = pid.x_hat.q.to_rotation()
        q_tracking['estimated'].append(r)

        q_e = State.QuaternionError(pid.x_hat.q, q)
        e, r = q_e.to_rotation()
        q_tracking['err'].append(r)

        w_tracking['measured'].append(x_m.w.w[2,0])
        w_tracking['estimated'].append(pid.x_hat.w.w[2,0])
        w_tracking['err'].append(pid.x_hat.w.w[2,0] - x_m.w.w[2,0])

        random.shuffle(dts)
        dt = dts[0]

        time.sleep(dt / float(speed))
    return ts, q_tracking, w_tracking


def vals():
    for p in range(0, -3, -1):
        for i in range(-3, -5, -1):
            for d in range(-3, -5, -1):
                yield p, i, d

def gradient_desc():
    pbase = 1.01
    ibase = 10
    dbase = 10
    for p, i, d in vals():
        ts, q_tracking, w_tracking = run_test(pbase**p,ibase**i,dbase**d)
        err = np.array(q_tracking['err'])
        print "%g,%g,%g,%g,%g" % (
            err.std(), err.mean(), pbase**p, ibase**i, dbase**d)


def main():
    # gradient_desc()
    run_test(0.98, 0.001,0.001, True)
    return 0

if __name__ == "__main__":
    exit(main())
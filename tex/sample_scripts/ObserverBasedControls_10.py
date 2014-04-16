import sys
from TSatPy import Estimator, State, StateOperators
from TSatPy.Clock import Metronome
import numpy as np
import matplotlib.pyplot as plt
import time
import random


print('Sliding Mode Observer')

speed = 10
c = Metronome()
c.set_speed(speed)

def grid_me(ax):
    ax.grid(color='0.75', linestyle='--', linewidth=1)

def run_test(L, K, S, plot=False):
    ts, q_tracking, w_tracking = test(L, K, S)

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


def vals():
    # for p in range(-14, -24, -1):
    for p in [p / 100.0 for p in range(7, 18)]:
        # for i in range(-6, -12, -1):
        for i in [i / 1000.0 for i in range(0, 9)]:
            # for d in range(-6, -12, -1):
            for d in [d / 1000.0 for d in range(0, 17)]:
                yield p, i, d

def gradient_desc():
    pbase = 1.1
    ibase = 2
    dbase = 2
    with open('%s-gradient-descent.csv' % __file__, 'a') as f:
        for p, i, d in vals():
            # ts, q_tracking, w_tracking = run_test(pbase**p,ibase**i,dbase**d)
            ts, q_tracking, w_tracking = run_test(p,i,d)
            err = np.array(q_tracking['err'])
            # f.write("%g,%g,%g,%g,%g\n" % (
            #     err.std(), err.mean(), pbase**p, ibase**i, dbase**d))
            f.write("%g,%g,%g,%g,%g\n" % (
                err.std(), err.mean(), p, i, d))
            f.flush()

def test(L, K, S):

    x_ic = State.State(
        State.Quaternion([0,0,1], radians=4),
        State.BodyRate([0,0,0.314]))

    I = [[2, 0, 0], [0, 2, 0], [0, 0, 2]]
    plant = State.Plant(I, x_ic, c)
    plant_est = State.Plant(I, State.State(), c)

    L = StateOperators.StateGain(
        StateOperators.QuaternionGain(L['q']),
        StateOperators.BodyRateGain(np.eye(3) * L['w']))
    K = StateOperators.StateGain(
        StateOperators.QuaternionGain(K['q']),
        StateOperators.BodyRateGain(np.eye(3) * K['w']))

    Sx = StateOperators.StateSaturation(
        StateOperators.QuaternionSaturation(S['q']),
        StateOperators.BodyRateSaturation(S['w']))

    smo = Estimator.SMO(c, plant=plant_est)
    smo.set_S(Sx)
    smo.set_L(L)
    smo.set_K(K)

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
    start_time = c.tick()
    end_time = c.tick() + 10
    while c.tick() < end_time:
        plant.propagate()

        offset = np.random.randn() * 20 / 180.0 * np.pi
        q_noise = State.Quaternion([0,0,1], radians=offset) * plant.x.q

        x_m = State.State(q_noise, plant.x.w)
        smo.update(x_m)

        ts.append(c.tick() - start_time)

        e, r = plant.x.q.to_rotation()
        q_tracking['measured'].append(r)
        e, r = smo.x_hat.q.to_rotation()
        q_tracking['estimated'].append(r)

        q_e = State.QuaternionError(smo.x_hat.q, plant.x.q)
        e, r = q_e.to_rotation()
        q_tracking['err'].append(r)

        w_tracking['measured'].append(x_m.w.w[2,0])
        w_tracking['estimated'].append(smo.x_hat.w.w[2,0])
        w_tracking['err'].append(smo.x_hat.w.w[2,0] - x_m.w.w[2,0])

        random.shuffle(dts)
        time.sleep(dts[0] / float(speed))

    return ts, q_tracking, w_tracking


def main():
    L = {'q':0,     'w':0}
    K = {'q':0.1,   'w':0.3}
    S = {'q':2,     'w':0.1}

    with open('%s-gradient-descent.csv' % __file__, 'a') as f:
        ts, q_tracking, w_tracking = run_test(L, K, S, True)

        err = np.array(q_tracking['err'])
        for stat in [err.std(), err.mean(), L['q'], L['w'],
            K['q'], K['w'], S['q'], S['w']]:
            f.write("%s," % stat)

        f.write("\n")
        f.flush()

    return 0

if __name__ == "__main__":
    exit(main())
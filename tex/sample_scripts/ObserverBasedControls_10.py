import sys
from TSatPy import Estimator, State, StateOperators
from TSatPy.Clock import Metronome
import numpy as np
import matplotlib.pyplot as plt
import time
import random
import json


print('Sliding Mode Observer')

run_time = 120
speed = 10
dts = [0.8, 1.2]
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
    start_time = c.tick()
    end_time = c.tick() + run_time
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


def create_test_args(*args):

    targs = {
        'L': {'q': args[0],'w': args[1]},
        'K': {'q': args[2],'w': args[3]},
        'S': {'q': args[4],'w': args[5]},
    }
    return targs


def next_test_args(arg_data):
    args = []

    for data in arg_data:
        if data[2] is None:
            m = (data[0] + data[1]) / 2.0
        else:
            m = data[2]

        if data[3] is None:
            s = (data[1] - data[0]) / 4.0
        else:
            s = data[3]

        val = None
        while val is None or not (data[0] < val < data[1]):
            val = np.random.randn() * s + m
        args.append(val)
    return args


def main():

    results = []
    arg_data = [
        [0, 1, None, None], # Lq
        [0, 1, None, None], # Lw
        [0, 1, None, None], # Kq
        [0, 1, None, None], # Kw
        [0, np.pi, None, None], # Sq
        [0, 10, None, None], # Sw
    ]

    N = 100
    thresh = N * 0.2
    if thresh < 10:
        thresh = N - 1

    for _ in range(N):
        args = next_test_args(arg_data)
        kwargs = create_test_args(*args)
        ts, q_tracking, w_tracking = run_test(**kwargs)
        err = np.array(q_tracking['err'])
        cost = np.abs(err).mean() * err.std()
        kwargs['cost'] = cost
        with open('%s-gradient-descent.csv' % __file__, 'a') as f:
            f.write(json.dumps(kwargs))
            f.write("\n")
            f.flush()
        args.append(cost)
        results.append(args)

        if len(results) > thresh:
            rdata = np.array(results)
            rdata = rdata[rdata[:,-1].argsort()]
            for idx, m in enumerate(rdata[0:thresh/2,:-1].mean(axis=0)):
                arg_data[idx][2] = m
            for idx, s in enumerate(rdata[0:thresh/2,:-1].std(axis=0)):
                arg_data[idx][3] = s

    kwargs = create_test_args(*[d[2] for d in arg_data])
    for data in arg_data:
        print data

    print kwargs
    return 0


if __name__ == "__main__":

    kwargs = {'S': {'q': 1.908376120345185, 'w': 6.5356517995605596}, 'K': {'q': 0.12520202719936652, 'w': 0.48433605036767613}, 'L': {'q': 0.41506774287666348, 'w': 0.35072151415483038}}
    # kwargs = {"S": {"q": 0.7324366102332057, "w": 0.5386880719560759}, "K": {"q": 0.6340430770694714, "w": 0.5821736289388915},  "L": {"q": 0.7814360951486294, "w": 0.736085136529068}}

    if kwargs is not None:
        kwargs['plot'] = True
        ts, q_tracking, w_tracking = run_test(**kwargs)
    else:
        exit(main())




from TSatPy import Estimator, State
from TSatPy.Clock import Metronome
import numpy as np
import matplotlib.pyplot as plt
import time
import random

print('PID / SMO Estimator Faceoff')

configs = [{'type': 'pid',
 'args': {'kpq': 0.0735,'kpw': 0.7,'kiq': 0.000863,
          'kiw': 0,'kdq': 0.00812,'kdw': 0}
},{'type': 'smo',
 'args': {'Lq': 0.282, 'Lw': 0.444, 'Kq': 0.307, 'Kw': 0.464,
    'Sq': 0.886, 'Sw': 0.569}}]

run_time = 120
speed = 20
dts = [0.8, 1.2]
c = Metronome()
c.set_speed(speed)

def setup_estimators(configs):
    x_ic = State.State()
    I = [[2, 0, 0], [0, 2, 0], [0, 0, 2]]
    plant_est = State.Plant(I, x_ic, c)

    est = Estimator.Estimator(c)
    for config in configs:
        est.add(config['type'], plant_est, config['args'])

    return est

def test(est):
    x_ic = State.State(
        State.Quaternion([0,0,1], radians=4),
        State.BodyRate([0,0,0.314]))

    I = [[2, 0, 0], [0, 2, 0], [0, 0, 2]]
    plant = State.Plant(I, x_ic, c)

    ts = []; smo_err = []; pid_err = []
    start_time = c.tick()
    end_time = c.tick() + run_time
    while c.tick() < end_time:
        plant.propagate()
        offset = np.random.randn() * 20 / 180.0 * np.pi
        q_noise = State.Quaternion([0,0,1], radians=offset) * plant.x.q

        x_m = State.State(q_noise, plant.x.w)

        est.update(x_m)
        ts.append(c.tick() - start_time)

        for model in est.estimators:
            q_e = State.QuaternionError(model.x_hat.q, plant.x.q)
            e, r = q_e.to_rotation()

            if type(model) is Estimator.PID:
                pid_err.append(r)
            elif type(model) is Estimator.SMO:
                smo_err.append(r)
        random.shuffle(dts)
        time.sleep(dts[0] / float(speed))

    return ts, pid_err, smo_err


def graph_it(ts, pid_err, smo_err):
    pid_np = np.array(pid_err)
    smo_np = np.array(smo_err)
    ss_pid = np.argmax(pid_np < pid_np.mean())
    ss_smo = np.argmax(smo_np < smo_np.mean())
    print(pid_np.std())
    print(smo_np.std())

    fig = plt.figure(dpi=80, facecolor='w', edgecolor='k')
    ax = fig.add_subplot(1,1,1)
    ax.plot(ts, pid_err, c='b', label=r'PID $\theta_e$', lw=2)
    ax.plot(ts, smo_err, c='r', label=r'SMO $\theta_e$', lw=2)
    ax.axhline(y=pid_np[ss_pid:].mean(), ls='--', lw=2, c='b',
        label=r'PID $\bar{\theta}_{sse}$ = %g' % pid_np[ss_pid:].mean())
    ax.axhline(y=smo_np[ss_smo:].mean(), ls='--', lw=2, c='r',
        label=r'SMO $\bar{\theta}_{sse}$ = %g' % smo_np[ss_smo:].mean())
    ax.grid(color='0.75', linestyle='--', linewidth=1)
    ax.set_ylabel(r'$\theta_e$ (rad)')
    plt.legend()
    ax.set_xlabel('$t(k)$ seconds')

    plt.tight_layout()
    plt.show()


def main():
    est = setup_estimators(configs)
    graph_it(*test(est))
    return 0


if __name__ == '__main__':
    main()

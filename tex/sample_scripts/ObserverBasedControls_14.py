
import time
import numpy as np
import matplotlib.pyplot as plt
from TSatPy import Controller, State
from TSatPy import StateOperators as SO
from TSatPy.Clock import Metronome

print("Test P Controller - Rate Control")

run_time = 40
speed = 10
c = Metronome()
c.set_speed(speed)
dt = 0.2


x_d = State.State(
    State.Identity(),
    State.BodyRate([0,0,0.314]))

def test():
    x_est = State.State(
        State.Quaternion([0,0,1],radians=1),
        State.BodyRate([0,0,0.31]))

    I = [[2, 0, 0], [0, 2, 0], [0, 0, 2]]
    plant_est = State.Plant(I, x_est, c)

    Kp = SO.BodyRateToMoment(np.eye(3) * 0.1)

    pid = Controller.PID(c)
    pid.set_Kp(Kp)

    pid.set_desired_state(x_d)

    M = State.Moment()
    ts = []
    Ms = []
    wx = []
    theta = []
    start_time = c.tick()
    end_time = c.tick() + run_time
    while c.tick() < end_time:
        time.sleep(dt / float(speed))
        plant_est.propagate(M)

        x_plant = plant_est.x
        print x_plant
        M = pid.update(x_plant)

        ts.append(c.tick() - start_time)
        Ms.append(M.M[2, 0])
        wx.append(x_plant.w.w[2,0])
        e, r = x_plant.q.to_rotation()
        theta.append(r)

    return ts, Ms, wx, theta

def graph_it(ts, Ms, wx, theta):
    fig = plt.figure(dpi=80, facecolor='w', edgecolor='k')
    ax = fig.add_subplot(1,1,1)
    ax.plot(ts, wx, c='b', label=r'PID $\theta_e$', lw=2)
    # ax.plot(ts, smo_err, c='r', label=r'SMO $\theta_e$', lw=2)
    # ax.axhline(y=pid_np[ss_pid:].mean(), ls='--', lw=2, c='b',
    #     label=r'PID $\bar{\theta}_{sse}$ = %g' % pid_np[ss_pid:].mean())
    # ax.axhline(y=smo_np[ss_smo:].mean(), ls='--', lw=2, c='r',
    #     label=r'SMO $\bar{\theta}_{sse}$ = %g' % smo_np[ss_smo:].mean())
    # ax.grid(color='0.75', linestyle='--', linewidth=1)
    # ax.set_ylabel(r'$\theta_e$ (rad)')
    plt.legend()
    ax.set_xlabel('$t(k)$ seconds')

    plt.tight_layout()
    plt.show()

def main():
    ts, Ms, wx, theta = test()
    graph_it(ts, Ms, wx, theta)
    return 0

if __name__ == '__main__':
    exit(main())
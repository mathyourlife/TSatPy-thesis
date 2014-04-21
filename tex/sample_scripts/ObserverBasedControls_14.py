
import time
import numpy as np
import matplotlib.pyplot as plt
from TSatPy import Controller, State
from TSatPy import StateOperators as SO
from TSatPy.Clock import Metronome
from GradientDescent import GradientDescent

print("Test P Controller - Rate Control")

run_time = 60
speed = 20
c = Metronome()
c.set_speed(speed)
dt = 0.5

x_d = State.State(
    State.Identity(),
    State.BodyRate([0,0,0.314]))


def run_test(Kx, Ky, Kz, plot=False):
    ts, Ms, ws = test(Kx, Ky, Kz)

    if plot:
        graph_it(ts, Ms, ws)


def test(Kx, Ky, Kz):
    x_est = State.State(
        State.Quaternion([0,0.1,1],radians=1),
        State.BodyRate(np.random.rand(3,1)))

    I = [[4, 0, 0], [0, 4, 0], [0, 0, 2]]
    plant_est = State.Plant(I, x_est, c)

    Kp = SO.StateToMoment(
        None,
        SO.BodyRateToMoment([[Kx,0,0],[0,Ky,0],[0,0,Kz]]))

    pid = Controller.PID(c)
    pid.set_Kp(Kp)
    pid.set_desired_state(x_d)

    M = State.Moment()
    ts = []
    Ms = []
    ws = []
    start_time = c.tick()
    end_time = c.tick() + run_time
    while c.tick() < end_time:
        time.sleep(dt / float(speed))
        plant_est.propagate(M)

        x_plant = plant_est.x
        M = pid.update(x_plant)

        ts.append(c.tick() - start_time)
        Ms.append((M.M[0,0],M.M[1,0],M.M[2,0]))
        ws.append((x_plant.w.w[0,0],x_plant.w.w[1,0],x_plant.w.w[2,0]))

    return ts, Ms, ws

def grid_me(ax):
    ax.grid(color='0.75', linestyle='--', linewidth=1)

def graph_it(ts, Ms, ws):
    fig = plt.figure(dpi=80, facecolor='w', edgecolor='k')
    ax = fig.add_subplot(2,1,1)
    ax.plot(ts, [M[0] for M in Ms], c='b', label=r'$M_x$', lw=2)
    ax.plot(ts, [M[1] for M in Ms], c='r', label=r'$M_y$', lw=2)
    ax.plot(ts, [M[2] for M in Ms], c='g', label=r'$M_z$', lw=2)
    ax.set_ylabel(r'Moment (Nm)')
    grid_me(ax)
    plt.legend(prop={'size':10})

    ax = fig.add_subplot(2,1,2)
    ax.plot(ts, [w[0] for w in ws], c='b', label=r'$\omega_x$', lw=2)
    ax.plot(ts, [w[1] for w in ws], c='r', label=r'$\omega_y$', lw=2)
    ax.plot(ts, [w[2] for w in ws], c='g', label=r'$\omega_z$', lw=2)
    ax.set_ylabel(r'Body Rate (rad/sec)')
    grid_me(ax)
    plt.legend(prop={'size':10})

    ax.set_xlabel('$t(k)$ seconds')

    plt.tight_layout()
    plt.show()


def calc_err(ts, Ms, ws):
    M = np.array(Ms)
    w = np.array(ws)

    cost = np.abs(M).mean(axis=0).sum()
    return cost


def main():
    domains = [
        ['Kx', 0.001,  0.9],
        ['Ky', 0.001,  0.9],
        ['Kz', 0.001,  0.9],
    ]

    kwargs = {
        # Number of iterations to run
        'N': 200,

        # Definition of parameter search domain
        'domains': domains,

        # Function that will run a test
        'run_test': test,

        # Function that will take the return of run_test and determine
        # how well the parameters worked.
        'calc_cost': calc_err,
    }
    print GradientDescent.descend(**kwargs)
    return 0


if __name__ == '__main__':

    kwargs = {'Kx': 0.1, 'Ky': 0.1, 'Kz': 0.1}
    kwargs = {'Kz': 0.10800052270236918, 'Ky': 0.13541228027404753, 'Kx': 0.11996112399792326}
    kwargs = {'Kz': 0.41850410569812957, 'Ky': 0.62305785644414247, 'Kx': 0.41202450589586731}
    kwargs = {'Kz': 0.040309182597415831, 'Ky': 0.82608778478750211, 'Kx': 0.23507761709718117}
    kwargs = {'Kz': 0.428, 'Ky': 0.463, 'Kx': 0.404}

    # kwargs = None

    if kwargs is not None:
        kwargs['plot'] = True
        run_test(**kwargs)
    else:
        exit(main())

    # ts, Ms, ws = test(0.1, 0.1, 0.1)
    # graph_it(ts, Ms, ws)


import time
import numpy as np
import matplotlib.pyplot as plt
from TSatPy import Controller, State
from TSatPy import StateOperators as SO
from TSatPy.Clock import Metronome
from GradientDescent import GradientDescent

print("Test PID Controller - Rate Control")

run_time = 60
speed = 20
c = Metronome()
c.set_speed(speed)
dt = 0.5

x_d = State.State(
    State.Identity(),
    State.BodyRate([0,0,0.314]))


def run_test(Kpx, Kpy, Kpz, Kix, Kiy, Kiz, Kdx, Kdy, Kdz, plot=False):
    ts, Ms, ws = test(Kpx, Kpy, Kpz, Kix, Kiy, Kiz, Kdx, Kdy, Kdz)

    if plot:
        graph_it(ts, Ms, ws)


def test(Kpx, Kpy, Kpz, Kix, Kiy, Kiz, Kdx, Kdy, Kdz):
    x_est = State.State(
        State.Quaternion([0,0.1,1],radians=1),
        State.BodyRate(np.random.rand(3,1)))

    I = [[4, 0, 0], [0, 4, 0], [0, 0, 2]]
    plant_est = State.Plant(I, x_est, c)

    Kp = SO.StateToMoment(
        None,
        SO.BodyRateToMoment([[Kpx,0,0],[0,Kpy,0],[0,0,Kpz]]))
    Ki = SO.StateToMoment(
        None,
        SO.BodyRateToMoment([[Kix,0,0],[0,Kiy,0],[0,0,Kiz]]))
    Kd = SO.StateToMoment(
        None,
        SO.BodyRateToMoment([[Kdx,0,0],[0,Kdy,0],[0,0,Kdz]]))

    pid = Controller.PID(c)
    pid.set_Kp(Kp)
    pid.set_Ki(Ki)
    pid.set_Kd(Kd)
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
        ['Kpx', 0.001,  0.9],
        ['Kpy', 0.001,  0.9],
        ['Kpz', 0.001,  0.9],
        ['Kix', 0.001,  0.9],
        ['Kiy', 0.001,  0.9],
        ['Kiz', 0.001,  0.9],
        ['Kdx', 0.001,  0.9],
        ['Kdy', 0.001,  0.9],
        ['Kdz', 0.001,  0.9],
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

    kwargs =   {'Kiz': 0.328, 'Kiy': 0.372, 'Kix': 0.364, 'Kpx': 0.597,
        'Kpy': 0.643, 'Kpz': 0.450, 'Kdx': 0.435, 'Kdy': 0.357, 'Kdz': 0.392}

    # kwargs = None

    if kwargs is not None:
        kwargs['plot'] = True
        run_test(**kwargs)
    else:
        exit(main())

    # ts, Ms, ws = test(0.1, 0.1, 0.1)
    # graph_it(ts, Ms, ws)

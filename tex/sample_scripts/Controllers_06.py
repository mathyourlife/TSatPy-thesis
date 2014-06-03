
import time
import numpy as np
import matplotlib.pyplot as plt
from TSatPy import Controller, State
from TSatPy import StateOperator as SO
from TSatPy.Clock import Metronome
from GradientDescent import GradientDescent

print("Test P - Nutation Control")

run_time = 120
speed = 20
c = Metronome()
c.set_speed(speed)
dt = 0.5

x_d = State.State()


def run_test(Kq, plot=False):
    ts, Ms, ws, theta = test(Kq)

    if plot:
        graph_it(ts, Ms, ws, theta)


def test(Kq):

    x_est = State.State(
        State.Quaternion([0,0.1,1],radians=1),
        State.BodyRate([0,-0.01,0.2]))

    I = [[4, 0, 0], [0, 4, 0], [0, 0, 2]]
    plant_est = State.Plant(I, x_est, c)

    Kp = SO.StateToMoment(
        SO.QuaternionToMoment(Kq),
        None)

    pid = Controller.PID(c)
    pid.set_Kp(Kp)
    pid.set_desired_state(x_d)

    M = State.Moment()
    ts = []
    Ms = []
    ws = []
    theta = []
    start_time = c.tick()
    end_time = c.tick() + run_time
    while c.tick() < end_time:
        time.sleep(dt / float(speed))
        plant_est.propagate(M)

        x_plant = plant_est.x
        # Replace the plant's quaternion with just the nutation component
        q_r, q_n = x_plant.q.decompose()
        x_plant.q = q_n

        M = pid.update(x_plant)

        ts.append(c.tick() - start_time)
        Ms.append((M[0],M[1],M[2]))
        e, r = q_n.to_rotation()
        theta.append(r)
        ws.append((x_plant.w[0],x_plant.w[1],x_plant.w[2]))

    return ts, Ms, ws, theta


def grid_me(ax):
    ax.grid(color='0.75', linestyle='--', linewidth=1)

def graph_it(ts, Ms, ws, theta):
    fig = plt.figure(dpi=80, facecolor='w', edgecolor='k')
    ax = fig.add_subplot(3,1,1)
    ax.plot(ts, [M[0] for M in Ms], c='b', label=r'$M_x$', lw=2)
    ax.plot(ts, [M[1] for M in Ms], c='r', label=r'$M_y$', lw=2)
    ax.plot(ts, [M[2] for M in Ms], c='g', label=r'$M_z$', lw=2)
    ax.set_ylabel(r'Moment (Nm)')
    grid_me(ax)
    plt.legend(prop={'size':10})

    ax = fig.add_subplot(3,1,2)
    ax.plot(ts, theta, c='b', label=r'$\theta$', lw=2)
    ax.set_ylabel(r'Quaternion Angle (rad)')
    grid_me(ax)
    plt.legend(prop={'size':10})

    ax = fig.add_subplot(3,1,3)
    ax.plot(ts, [w[0] for w in ws], c='b', label=r'$\omega_x$', lw=2)
    ax.plot(ts, [w[1] for w in ws], c='r', label=r'$\omega_y$', lw=2)
    ax.plot(ts, [w[2] for w in ws], c='g', label=r'$\omega_z$', lw=2)
    ax.set_ylabel(r'Body Rate (rad/sec)')
    grid_me(ax)
    plt.legend(prop={'size':10})

    ax.set_xlabel('$t(k)$ seconds')

    plt.tight_layout()
    plt.show()


def calc_err(ts, Ms, ws, theta):
    M = np.array(Ms)
    theta = np.array(theta)

    cost = np.abs(M).mean(axis=0).sum()
    return cost


def main():
    domains = [
        ['Kq', 0.001,  0.9],
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
    print(GradientDescent.descend(**kwargs))
    return 0


if __name__ == '__main__':

    kwargs = {'Kq': 0.14869025098803129}

    # kwargs = None

    if kwargs is not None:
        kwargs['plot'] = True
        run_test(**kwargs)
    else:
        exit(main())

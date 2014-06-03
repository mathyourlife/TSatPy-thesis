
import time
import numpy as np
import matplotlib.pyplot as plt
from TSatPy import Controller, State
from TSatPy import StateOperator as SO
from TSatPy.Clock import Metronome
from GradientDescent import GradientDescent

print("Test SMC Controller - Rate Control")

run_time = 60
speed = 20
c = Metronome()
c.set_speed(speed)
dt = 0.5

x_d = State.State(
    State.Identity(),
    State.BodyRate([0,0,0.314]))


def run_test(Lx, Ly, Lz, Kx, Ky, Kz, Sw, plot=False):
    ts, Ms, Mls, Mss, ws = test(Lx, Ly, Lz, Kx, Ky, Kz, Sw)

    if plot:
        graph_it(ts, Ms, Mls, Mss, ws)


def test(Lx, Ly, Lz, Kx, Ky, Kz, Sw):
    x_est = State.State(
        State.Quaternion(np.random.rand(3,1),radians=np.random.rand()),
        State.BodyRate(np.random.rand(3,1)))

    I = [[4, 0, 0], [0, 4, 0], [0, 0, 2]]
    plant_est = State.Plant(I, x_est, c)

    L = SO.StateToMoment(
        None,
        SO.BodyRateToMoment([[Lx,0,0],[0,Ly,0],[0,0,Lz]]))
    K = SO.StateToMoment(
        None,
        SO.BodyRateToMoment([[Kx,0,0],[0,Ky,0],[0,0,Kz]]))
    S = SO.StateSaturation(
        None,
        SO.BodyRateSaturation(Sw))

    smc = Controller.SMC(c)
    smc.set_L(L)
    smc.set_K(K)
    smc.set_S(S)
    smc.set_desired_state(x_d)

    M = State.Moment()
    ts = []
    Ms = []
    Mls = []
    Mss = []
    ws = []
    start_time = c.tick()
    end_time = c.tick() + run_time
    while c.tick() < end_time:
        time.sleep(dt / float(speed))
        plant_est.propagate(M)

        x_plant = plant_est.x
        M = smc.update(x_plant)

        ts.append(c.tick() - start_time)
        Ms.append((M[0],M[1],M[2]))
        Mls.append((smc.M_l[0],smc.M_l[1],smc.M_l[2]))
        Mss.append((smc.M_s[0],smc.M_s[1],smc.M_s[2]))
        ws.append((x_plant.w[0],x_plant.w[1],x_plant.w[2]))

    return ts, Ms, Mls, Mss, ws

def grid_me(ax):
    ax.grid(color='0.75', linestyle='--', linewidth=1)

def graph_it(ts, Ms, Mls, Mss, ws):
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
    plt.draw()

    fig = plt.figure(dpi=80, facecolor='w', edgecolor='k')
    ax = fig.add_subplot(2,1,1)
    ax.plot(ts, [M[0] for M in Mls], c='b', label=r'$M_x$', lw=2)
    ax.plot(ts, [M[1] for M in Mls], c='r', label=r'$M_y$', lw=2)
    ax.plot(ts, [M[2] for M in Mls], c='g', label=r'$M_z$', lw=2)
    ax.set_ylabel(r'L-Moment (Nm)')
    grid_me(ax)
    plt.legend(prop={'size':10})

    ax = fig.add_subplot(2,1,2)
    ax.plot(ts, [M[0] for M in Mss], c='b', label=r'$M_x$', lw=2)
    ax.plot(ts, [M[1] for M in Mss], c='r', label=r'$M_y$', lw=2)
    ax.plot(ts, [M[2] for M in Mss], c='g', label=r'$M_z$', lw=2)
    ax.set_ylabel(r'S-Moment (Nm)')
    grid_me(ax)
    plt.legend(prop={'size':10})

    ax.set_xlabel('$t(k)$ seconds')

    plt.tight_layout()
    plt.show()


def calc_err(ts, Ms, Mls, Mss, ws):
    M = np.array(Ms)
    w = np.array(ws)

    cost = np.abs(M).mean(axis=0).sum()
    return cost


def main():
    domains = [
        ['Lx', 0,  0.9],
        ['Ly', 0,  0.9],
        ['Lz', 0,  0.9],
        ['Kx', 0,  0.9],
        ['Ky', 0,  0.9],
        ['Kz', 0,  0.9],
        ['Sw', 0,  0.2],
    ]

    kwargs = {
        # Number of iterations to run
        'N': 100,

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

    kwargs = None
    kwargs = {
        'Lx': 0.3983, 'Ly': 0.3828, 'Lz': 0.4160,
        'Kx': 0.4399, 'Kz': 0.5097, 'Ky': 0.3162,
        'Sw': 0.1404,
    }


    if kwargs is not None:
        kwargs['plot'] = True
        run_test(**kwargs)
    else:
        exit(main())

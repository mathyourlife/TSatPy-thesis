
import time
import numpy as np
import matplotlib.pyplot as plt
from TSatPy import Controller, State
from TSatPy import StateOperator as SO
from TSatPy.Clock import Metronome
from GradientDescent import GradientDescent

print("SMC - Fixed attitude control")

run_time = 60
speed = 30
c = Metronome()
c.set_speed(speed)
dt = 0.25

x_d = State.State()

x_ic = State.State(
    State.Quaternion([-0.531597, -0.417257, -0.274828], 0.683937),
    State.BodyRate([0.315424, 0.207168, 0.113405]))

def run_test(Lq, Lx, Ly, Lz, Kq, Kx, Ky, Kz, Sq, Sw, plot=False):
    ts, Ms, Mls, Mss, ws, theta = test(Lq, Lx, Ly, Lz, Kq, Kx, Ky, Kz, Sq, Sw)

    if plot:
        graph_it(ts, Ms, Mls, Mss, ws, theta)


def test(Lq, Lx, Ly, Lz, Kq, Kx, Ky, Kz, Sq, Sw):

    I = [[4, 0, 0], [0, 4, 0], [0, 0, 2]]
    plant_est = State.Plant(I, x_ic, c)

    L = SO.StateToMoment(
        SO.QuaternionToMoment(Lq),
        SO.BodyRateToMoment([[Lx,0,0],[0,Ly,0],[0,0,Lz]]))
    K = SO.StateToMoment(
        SO.QuaternionToMoment(Kq),
        SO.BodyRateToMoment([[Kx,0,0],[0,Ky,0],[0,0,Kz]]))
    S = SO.StateSaturation(
        SO.QuaternionSaturation(Sq),
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
    theta = []
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
        e, r = x_plant.q.to_rotation()
        theta.append(r)
        ws.append((x_plant.w[0],x_plant.w[1],x_plant.w[2]))

    return ts, Ms, Mls, Mss, ws, theta

def grid_me(ax):
    ax.grid(color='0.75', linestyle='--', linewidth=1)

def graph_it(ts, Ms, Mls, Mss, ws, theta):
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


def calc_err(ts, Ms, Mls, Mss, ws, theta):
    M = np.array(Ms)
    theta = np.array(theta)

    moment_cost = np.abs(M).mean(axis=0).sum()
    theta_cost = np.abs(theta).mean(axis=0).sum()
    return moment_cost + theta_cost


def main():
    domains = [
        ['Lq', 0, 1],
        ['Lx', 0, 1],
        ['Ly', 0, 1],
        ['Lz', 0, 1],
        ['Kq', 0, 1],
        ['Kx', 0, 1],
        ['Ky', 0, 1],
        ['Kz', 0, 1],
        ['Sq', 0, 1],
        ['Sw', 0, 1],
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

    kwargs = None
    kwargs = {
        'Kq': 0.500, 'Kx': 0.745, 'Ky': 0.816, 'Kz': 0.666,
        'Lq': 0.408, 'Lx': 0.708, 'Ly': 0.678, 'Lz': 0.525,
        'Sq': 0.607, 'Sw': 0.315,
    }

    if kwargs is not None:
        kwargs['plot'] = True
        run_test(**kwargs)
    else:
        exit(main())

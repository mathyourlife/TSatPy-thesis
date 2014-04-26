
import time
import numpy as np
import matplotlib.pyplot as plt
from TSatPy import Controller, State
from TSatPy import StateOperator as SO
from TSatPy.Clock import Metronome
from GradientDescent import GradientDescent

print("PID - Fixed attitude control")

run_time = 60
speed = 20
c = Metronome()
c.set_speed(speed)
dt = 0.25

x_d = State.State()

x_ic = State.State(
    State.Quaternion([-0.531597, -0.417257, -0.274828], 0.683937),
    State.BodyRate([0.315424, 0.207168, 0.113405]))

def run_test(Kpq, Kpwx, Kpwy, Kpwz, Kiq, Kiwx, Kiwy, Kiwz,
    Kdq, Kdwx, Kdwy, Kdwz, plot=False):
    ts, Ms, Mps, Mis, Mds, ws, theta = test(Kpq, Kpwx, Kpwy, Kpwz, Kiq, Kiwx, Kiwy, Kiwz,
        Kdq, Kdwx, Kdwy, Kdwz)

    if plot:
        graph_it(ts, Ms, Mps, Mis, Mds, ws, theta)


def test(Kpq, Kpwx, Kpwy, Kpwz, Kiq, Kiwx, Kiwy, Kiwz, Kdq, Kdwx, Kdwy, Kdwz):

    I = [[4, 0, 0], [0, 4, 0], [0, 0, 2]]
    plant_est = State.Plant(I, x_ic, c)

    Kp = SO.StateToMoment(
        SO.QuaternionToMoment(Kpq),
        SO.BodyRateToMoment([[Kpwx,0,0],[0,Kpwy,0],[0,0,Kpwz]]))
    Ki = SO.StateToMoment(
        SO.QuaternionToMoment(Kiq),
        SO.BodyRateToMoment([[Kiwx,0,0],[0,Kiwy,0],[0,0,Kiwz]]))
    Kd = SO.StateToMoment(
        SO.QuaternionToMoment(Kdq),
        SO.BodyRateToMoment([[Kdwx,0,0],[0,Kdwy,0],[0,0,Kdwz]]))

    pid = Controller.PID(c)
    pid.set_Kp(Kp)
    pid.set_Ki(Ki)
    pid.set_Kd(Kd)
    pid.set_desired_state(x_d)

    M = State.Moment()
    ts = []
    Ms = []
    Mps = []
    Mis = []
    Mds = []
    ws = []
    theta = []
    start_time = c.tick()
    end_time = c.tick() + run_time
    while c.tick() < end_time:
        time.sleep(dt / float(speed))
        plant_est.propagate(M)

        x_plant = plant_est.x

        M = pid.update(x_plant)

        ts.append(c.tick() - start_time)
        Ms.append((M.M[0,0],M.M[1,0],M.M[2,0]))
        Mps.append((pid.M_p[0],pid.M_p[1],pid.M_p[2]))
        Mis.append((pid.M_i[0],pid.M_i[1],pid.M_i[2]))
        Mds.append((pid.M_d[0],pid.M_d[1],pid.M_d[2]))
        e, r = x_plant.q.to_rotation()
        theta.append(r)
        ws.append((x_plant.w[0],x_plant.w[1],x_plant.w[2]))

    return ts, Ms, Mps, Mis, Mds, ws, theta


def grid_me(ax):
    ax.grid(color='0.75', linestyle='--', linewidth=1)

def graph_it(ts, Ms, Mps, Mis, Mds, ws, theta):
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
    ax = fig.add_subplot(3,1,1)
    ax.plot(ts, [M[0] for M in Mps], c='b', label=r'$M_x$', lw=2)
    ax.plot(ts, [M[1] for M in Mps], c='r', label=r'$M_y$', lw=2)
    ax.plot(ts, [M[2] for M in Mps], c='g', label=r'$M_z$', lw=2)
    ax.set_ylabel(r'P-Moment (Nm)')
    grid_me(ax)
    plt.legend(prop={'size':10})

    ax = fig.add_subplot(3,1,2)
    ax.plot(ts, [M[0] for M in Mis], c='b', label=r'$M_x$', lw=2)
    ax.plot(ts, [M[1] for M in Mis], c='r', label=r'$M_y$', lw=2)
    ax.plot(ts, [M[2] for M in Mis], c='g', label=r'$M_z$', lw=2)
    ax.set_ylabel(r'I-Moment (Nm)')
    grid_me(ax)
    plt.legend(prop={'size':10})

    ax = fig.add_subplot(3,1,3)
    ax.plot(ts, [M[0] for M in Mds], c='b', label=r'$M_x$', lw=2)
    ax.plot(ts, [M[1] for M in Mds], c='r', label=r'$M_y$', lw=2)
    ax.plot(ts, [M[2] for M in Mds], c='g', label=r'$M_z$', lw=2)
    ax.set_ylabel(r'D-Moment (Nm)')
    grid_me(ax)
    plt.legend(prop={'size':10})

    ax.set_xlabel('$t(k)$ seconds')

    plt.tight_layout()
    plt.show()


def calc_err(ts, Ms, Mps, Mis, Mds, ws, theta):
    M = np.array(Ms)
    theta = np.array(theta)

    moment_cost = np.abs(M).mean(axis=0).sum()
    theta_cost = np.abs(theta).mean(axis=0).sum()
    return moment_cost + theta_cost


def main():
    domains = [
        ['Kpq',  0.35, 0.75],
        ['Kpwx', 0.60, 0.80],
        ['Kpwy', 0.42, 0.82],
        ['Kpwz', 0.50, 0.70],
        ['Kiq',  0, 0.1],
        ['Kiwx', 0, 0.1],
        ['Kiwy', 0, 0.1],
        ['Kiwz', 0, 0.1],
        ['Kdq',  0.83, 0.91],
        ['Kdwx', 0.32, 0.72],
        ['Kdwy', 0.51, 0.71],
        ['Kdwz', 0.38, 0.78],
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
    print GradientDescent.descend(**kwargs)
    return 0



if __name__ == '__main__':

    kwargs = None
    kwargs = {
        'Kpq': 0.6022,  'Kpwx': 0.70326, 'Kpwy': 0.7203,  'Kpwz': 0.61757,
        'Kiq': 0.04656, 'Kiwx': 0.04207, 'Kiwy': 0.06999, 'Kiwz': 0.018591,
        'Kdq': 0.8554,  'Kdwx': 0.4096,  'Kdwy': 0.6032,  'Kdwz': 0.6123,
    }

    if kwargs is not None:
        kwargs['plot'] = True
        run_test(**kwargs)
    else:
        exit(main())


import time
import numpy as np
import matplotlib.pyplot as plt
from TSatPy import Controller, State
from TSatPy import StateOperator as SO
from TSatPy.Clock import Metronome
from GradientDescent import GradientDescent

print("PID - Spin-stabilized control with nutation rejection")

run_time = 200
speed = 30
c = Metronome()
c.set_speed(speed)
dt = 0.25

x_d = State.State(
    State.Identity(),
    State.BodyRate([0,0,0.314]))

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
        # Replace the plant's quaternion with just the nutation component
        q_r, q_n = x_plant.q.decompose()
        x_plant.q = q_n

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
        ['Kpq',  0, 0.3],
        ['Kpwx', 0, 0.8],
        ['Kpwy', 0, 0.8],
        ['Kpwz', 0, 0.8],
        ['Kiq',  0, 0.3],
        ['Kiwx', 0, 0.3],
        ['Kiwy', 0, 0.3],
        ['Kiwz', 0, 0.3],
        ['Kdq',  0, 0.3],
        ['Kdwx', 0, 0.8],
        ['Kdwy', 0, 0.8],
        ['Kdwz', 0, 0.8],
    ]

    kwargs = {
        # Number of iterations to run
        'N': 2000,

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
        'Kpq': 0.051084176007712499,
        'Kpwx': 0.42608916285756737,
        'Kpwy': 0.50471802775515828,
        'Kpwz': 0.42944540745897269,
        'Kiq': 0.076357776274116607,
        'Kiwx': 0.12245837616863983,
        'Kiwy': 0.15315629073491144,
        'Kiwz': 0.15463302869257717,
        'Kdq': 0.11843781587383009,
        'Kdwx': 0.40100533884246004,
        'Kdwy': 0.41000920539168767,
        'Kdwz': 0.39661926013817683,
    }


    if kwargs is not None:
        kwargs['plot'] = True
        run_test(**kwargs)
    else:
        exit(main())

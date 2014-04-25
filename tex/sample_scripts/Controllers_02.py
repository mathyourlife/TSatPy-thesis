
import time
import numpy as np
import matplotlib.pyplot as plt
from TSatPy import Controller, State
from TSatPy import StateOperator as SO
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
    ts, Ms, Mps, Mis, Mds, ws = test(Kpx, Kpy, Kpz, Kix, Kiy, Kiz, Kdx, Kdy, Kdz)

    if plot:
        graph_it(ts, Ms, Mps, Mis, Mds, ws)


def test(Kpx, Kpy, Kpz, Kix, Kiy, Kiz, Kdx, Kdy, Kdz):
    x_est = State.State(
        State.Quaternion(np.random.rand(3,1),radians=np.random.rand()),
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
    Mps = []
    Mis = []
    Mds = []
    ws = []
    start_time = c.tick()
    end_time = c.tick() + run_time
    while c.tick() < end_time:
        time.sleep(dt / float(speed))
        plant_est.propagate(M)

        x_plant = plant_est.x
        M = pid.update(x_plant)

        ts.append(c.tick() - start_time)
        Ms.append((M[0],M[1],M[2]))
        Mps.append((pid.M_p[0],pid.M_p[1],pid.M_p[2]))
        Mis.append((pid.M_i[0],pid.M_i[1],pid.M_i[2]))
        Mds.append((pid.M_d[0],pid.M_d[1],pid.M_d[2]))
        ws.append((x_plant.w[0],x_plant.w[1],x_plant.w[2]))

    return ts, Ms, Mps, Mis, Mds, ws

def grid_me(ax):
    ax.grid(color='0.75', linestyle='--', linewidth=1)

def graph_it(ts, Ms, Mps, Mis, Mds, ws):
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


def calc_err(ts, Ms, Mps, Mis, Mds, ws):
    M = np.array(Ms)
    cost = np.abs(M).mean(axis=0).sum()
    return cost


def main():
    domains = [
        ['Kpx', 0.001,  0.9],
        ['Kpy', 0.001,  0.9],
        ['Kpz', 0.001,  0.9],
        ['Kix', 0,  0.01],
        ['Kiy', 0,  0.01],
        ['Kiz', 0,  0.01],
        ['Kdx', 0,  0.1],
        ['Kdy', 0,  0.1],
        ['Kdz', 0,  0.1],
    ]

    kwargs = {
        # Number of iterations to run
        'N': 50,

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
        'Kpx': 0.4239, 'Kpy': 0.4164, 'Kpz': 0.3460,
        'Kix': 0.005723, 'Kiy': 0.003002, 'Kiz': 0.005465,
        'Kdx': 0.04437, 'Kdy': 0.07173, 'Kdz': 0.04188
    }

    if kwargs is not None:
        kwargs['plot'] = True
        run_test(**kwargs)
    else:
        exit(main())

# Best performance at
# Kpx:
#   val: 0.423915 range: 0.001,0.9    std: 0.0528036
# Kpy:
#   val: 0.416379 range: 0.001,0.9    std: 0.0508544
# Kpz:
#   val: 0.346048 range: 0.001,0.9    std: 0.0263608
# Kix:
#   val: 0.00572302   range: 0,0.01   std: 0.000574547
# Kiy:
#   val: 0.00300189   range: 0,0.01   std: 0.00112776
# Kiz:
#   val: 0.00546487   range: 0,0.01   std: 0.000738131
# Kdx:
#   val: 0.0443719    range: 0,0.1    std: 0.00127098
# Kdy:
#   val: 0.0717262    range: 0,0.1    std: 0.0113157
# Kdz:
#   val: 0.0418845    range: 0,0.1    std: 0.00599079


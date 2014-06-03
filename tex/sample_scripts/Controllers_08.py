
import time
import numpy as np
import matplotlib.pyplot as plt
from TSatPy import Controller, State
from TSatPy import StateOperator as SO
from TSatPy.Clock import Metronome
from GradientDescent import GradientDescent

print("Test PID - Nutation and Rate Control")

run_time = 200
speed = 20
c = Metronome()
c.set_speed(speed)
dt = 0.25

x_d = State.State(
    State.Identity(),
    State.BodyRate([0,0,0.314]))


def run_test(Kpq, Kpwx, Kpwy, Kpwz, Kiq, Kiwx, Kiwy, Kiwz,
    Kdq, Kdwx, Kdwy, Kdwz, plot=False):
    ts, Ms, ws, theta = test(Kpq, Kpwx, Kpwy, Kpwz, Kiq, Kiwx, Kiwy, Kiwz,
        Kdq, Kdwx, Kdwy, Kdwz)

    if plot:
        graph_it(ts, Ms, ws, theta)


def test(Kpq, Kpwx, Kpwy, Kpwz, Kiq, Kiwx, Kiwy, Kiwz, Kdq, Kdwx, Kdwy, Kdwz):

    # Randomize the initial condition of the plant
    x_est_ic = State.State(
        State.Quaternion(np.random.rand(3,1),radians=np.random.rand()*3),
        State.BodyRate(np.random.rand(3,1)))
    print("x_est_ic:    %s" % (x_est_ic))
    print(x_est_ic.q.to_rotation())

    I = [[4, 0, 0], [0, 4, 0], [0, 0, 2]]
    plant_est = State.Plant(I, x_est_ic, c)

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
        e, r = x_plant.q.to_rotation()
        theta.append(r)
        ws.append((x_plant.w.w[0,0],x_plant.w.w[1,0],x_plant.w.w[2,0]))

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
        ['Kpq',  0.12 - 2 * 0.05,  0.12 + 2 * 0.05],
        ['Kpwx', 0.55 - 2 * 0.08,  0.55 + 2 * 0.08],
        ['Kpwy', 0.41 - 2 * 0.12,  0.41 + 2 * 0.12],
        ['Kpwz', 0.58 - 2 * 0.13,  0.58 + 2 * 0.13],
        ['Kiq',  0.021 - 2 * 0.009,  0.021 + 2 * 0.009],
        ['Kiwx', 0.37 - 2 * 0.07,  0.37 + 2 * 0.07],
        ['Kiwy', 0.58 - 2 * 0.15,  0.58 + 2 * 0.15],
        ['Kiwz', 0.55 - 2 * 0.13,  0.55 + 2 * 0.13],
        ['Kdq',  0.33 - 2 * 0.14,  0.33 + 2 * 0.14],
        ['Kdwx', 0.56 - 2 * 0.12,  0.56 + 2 * 0.12],
        ['Kdwy', 0.42 - 2 * 0.15,  0.42 + 2 * 0.15],
        ['Kdwz', 0.45 - 2 * 0.09,  0.45 + 2 * 0.09],
    ]

    kwargs = {
        # Number of iterations to run
        'N': 400,

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

    kwargs = {
        'Kpq': 0.11111822352039165,
        'Kpwx': 0.56072598825499542,
        'Kpwy': 0.46617055725812362,
        'Kpwz': 0.62449446448477242,
        'Kiq': 0.0092460954947930132,
        'Kiwx': 0.34527737331963193,
        'Kiwy': 0.56418807555550599,
        'Kiwz': 0.54983623166470164,
        'Kdq': 0.23121875724788765,
        'Kdwx': 0.59004903787603236,
        'Kdwy': 0.4646265536024109,
        'Kdwz': 0.42009087143770402,
    }


    # kwargs = None

    if kwargs is not None:
        kwargs['plot'] = True
        run_test(**kwargs)
    else:
        exit(main())


import time
import numpy as np
import matplotlib.pyplot as plt
from TSatPy import Controller, State
from TSatPy import StateOperators as SO
from TSatPy.Clock import Metronome
from GradientDescent import GradientDescent

print("Test P - Attitude Control")

run_time = 120
speed = 15
c = Metronome()
c.set_speed(speed)
dt = 0.5

x_d = State.State()


def test():
    x_est = State.State(
        State.Quaternion([0,0.1,1],radians=1),
        State.BodyRate([0,-0.01,0.2]))

    I = [[4, 0, 0], [0, 4, 0], [0, 0, 2]]
    plant_est = State.Plant(I, x_est, c)

    Kp = SO.StateToMoment(
        SO.QuaternionToMoment(0.01),
        None)

    pid = Controller.PID(c)
    pid.set_Kp(Kp)
    pid.set_desired_state(x_d)

    M = State.Moment()
    ts = []
    Ms = []
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
        e, r = x_plant.q.to_rotation()
        theta.append(r)

    return ts, Ms, theta


def grid_me(ax):
    ax.grid(color='0.75', linestyle='--', linewidth=1)

def graph_it(ts, Ms, theta):
    fig = plt.figure(dpi=80, facecolor='w', edgecolor='k')
    ax = fig.add_subplot(2,1,1)
    ax.plot(ts, [M[0] for M in Ms], c='b', label=r'$M_x$', lw=2)
    ax.plot(ts, [M[1] for M in Ms], c='r', label=r'$M_y$', lw=2)
    ax.plot(ts, [M[2] for M in Ms], c='g', label=r'$M_z$', lw=2)
    ax.set_ylabel(r'Moment (Nm)')
    grid_me(ax)
    plt.legend(prop={'size':10})

    ax = fig.add_subplot(2,1,2)
    ax.plot(ts, theta, c='b', label=r'$\theta$', lw=2)
    ax.set_ylabel(r'Quaternion Angle (rad)')
    grid_me(ax)
    plt.legend(prop={'size':10})

    ax.set_xlabel('$t(k)$ seconds')

    plt.tight_layout()
    plt.show()

if __name__ == '__main__':

    ts, Ms, theta = test()
    graph_it(ts, Ms, theta)
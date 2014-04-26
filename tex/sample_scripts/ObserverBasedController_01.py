
import time
import numpy as np
import matplotlib.pyplot as plt
from TSatPy import Controller, State, Estimator
from TSatPy import StateOperator as SO
from TSatPy.Clock import Metronome
from GradientDescent import GradientDescent

print("SMC - Spin-stabilized control with nutation rejection")

run_time = 400
speed = 20
c = Metronome()
c.set_speed(speed)
dt = 0.25

x_d = State.State(
    State.Identity(),
    State.BodyRate([0,0,0.314]))

x_ic = State.State(
    State.Quaternion([0, 0.1, 1], radians=2),
    State.BodyRate([0.01, -0.005, 0.2]))
    # State.BodyRate())

def run_test(eLq, eLx, eLy, eLz, eKq, eKx, eKy, eKz, eSq, eSw, cLq, cLx, cLy, cLz, cKq, cKx, cKy, cKz, cSq, cSw, plot=False):
    data = test(eLq, eLx, eLy, eLz, eKq, eKx, eKy, eKz, eSq, eSw, cLq, cLx, cLy, cLz, cKq, cKx, cKy, cKz, cSq, cSw)

    if plot:
        graph_it(data)


def test(eLq, eLx, eLy, eLz, eKq, eKx, eKy, eKz, eSq, eSw, cLq, cLx, cLy, cLz, cKq, cKx, cKy, cKz, cSq, cSw):

    I = [[4, 0, 0], [0, 4, 0], [0, 0, 2]]
    plant_true = State.Plant(I, x_ic, c)
    plant_est = State.Plant(I, State.State(), c)

    eL = SO.StateGain(
            SO.QuaternionGain(eLq),
            SO.BodyRateGain([[eLx,0,0],[0,eLy,0],[0,0,eLz]]))
    eK = SO.StateGain(
            SO.QuaternionGain(eKq),
            SO.BodyRateGain([[eKx,0,0],[0,eKy,0],[0,0,eKz]]))
    eSx = SO.StateSaturation(
            SO.QuaternionSaturation(eSq),
            SO.BodyRateSaturation(eSw))

    smo = Estimator.SMO(c, plant=plant_est)
    smo.set_S(eSx)
    smo.set_L(eL)
    smo.set_K(eK)


    cL = SO.StateToMoment(
        SO.QuaternionToMoment(cLq),
        SO.BodyRateToMoment([[cLx,0,0],[0,cLy,0],[0,0,cLz]]))
    cK = SO.StateToMoment(
        SO.QuaternionToMoment(cKq),
        SO.BodyRateToMoment([[cKx,0,0],[0,cKy,0],[0,0,cKz]]))
    cS = SO.StateSaturation(
        SO.QuaternionSaturation(cSq),
        SO.BodyRateSaturation(cSw))

    smc = Controller.SMC(c)
    smc.set_L(cL)
    smc.set_K(cK)
    smc.set_S(cS)
    smc.set_desired_state(x_d)


    M = State.Moment()
    data = {
        'ts': [],
        'true': {
            'theta': [],
            'w': [],
        },
        'est': {
            'theta': [],
            'w': [],
        },
        'ctrl': {
            'M': [],
            'nutation': [],
            'w': [],
        },
    }
    ts = []
    start_time = c.tick()
    end_time = c.tick() + run_time
    while c.tick() < end_time:
        time.sleep(dt / float(speed))
        # Propagate the truth model
        plant_true.propagate(M)
        x_true = plant_true.x

        # Add measurement noise
        x_m = x_true

        # Update the estimator
        x_est = smo.update(x_m)

        # Replace the estimated state's quaternion with the nutation component
        q_r, q_n = x_est.q.decompose()
        x_n = State.State(q_n, x_est.w)

        # Calculate the needed moment to correct for spin rate
        # and nutation
        M = smc.update(x_n)



        # Record data for post processing
        est_err = x_est - x_true
        ctrl_err = smc.x_e

        data['ts'].append(c.tick() - start_time)

        e, r = x_true.q.to_rotation()
        data['true']['theta'].append(r)
        data['true']['w'].append((x_true.w[0],x_true.w[1],x_true.w[2]))


        e, r = est_err.q.to_rotation()
        data['est']['theta'].append(r)
        data['est']['w'].append((est_err.w[0],est_err.w[1],est_err.w[2]))


        e, r = ctrl_err.q.to_rotation()
        data['ctrl']['nutation'].append(r)
        data['ctrl']['M'].append((M.M[0,0],M.M[1,0],M.M[2,0]))
        data['ctrl']['w'].append((ctrl_err.w[0],ctrl_err.w[1],ctrl_err.w[2]))


        # M = pid.update(x_plant)

        # Mps.append((pid.M_p[0],pid.M_p[1],pid.M_p[2]))
        # Mis.append((pid.M_i[0],pid.M_i[1],pid.M_i[2]))
        # Mds.append((pid.M_d[0],pid.M_d[1],pid.M_d[2]))
        # e, r = x_plant.q.to_rotation()
        # theta.append(r)
        # ws.append((x_plant.w[0],x_plant.w[1],x_plant.w[2]))

    return data


def grid_me(ax):
    ax.grid(color='0.75', linestyle='--', linewidth=1)

def graph_it(data):
    fig = plt.figure(dpi=80, facecolor='w', edgecolor='k')
    ax = fig.add_subplot(2,1,1)
    plt.title('Truth Model\nSatellite Body Rates')
    ax.plot(data['ts'], [w[0] for w in data['true']['w']], c='b', label=r'$\omega_x$', lw=2)
    ax.plot(data['ts'], [w[1] for w in data['true']['w']], c='r', label=r'$\omega_y$', lw=2)
    ax.plot(data['ts'], [w[2] for w in data['true']['w']], c='g', label=r'$\omega_z$', lw=2)
    grid_me(ax)
    ax.set_ylabel(r'$\omega_e$ (rad/sec)')
    plt.legend(prop={'size':10})

    ax = fig.add_subplot(2,1,2)
    plt.title('Satellite Quaternion Angle')
    ax.plot(data['ts'], data['true']['theta'], c='b', label=r'$\theta$', lw=2)
    grid_me(ax)
    ax.set_ylabel(r'$\theta$ (rad)')
    plt.legend(prop={'size':10})

    ax.set_xlabel('$t(k)$ seconds')

    plt.tight_layout()
    plt.draw()


    fig = plt.figure(dpi=80, facecolor='w', edgecolor='k')
    ax = fig.add_subplot(2,1,1)
    plt.title('Sliding Mode Observer - Estimator\nBody Rate Error')
    ax.plot(data['ts'], [w[0] for w in data['est']['w']], c='b', label=r'$\omega_x$', lw=2)
    ax.plot(data['ts'], [w[1] for w in data['est']['w']], c='r', label=r'$\omega_y$', lw=2)
    ax.plot(data['ts'], [w[2] for w in data['est']['w']], c='g', label=r'$\omega_z$', lw=2)
    grid_me(ax)
    ax.set_ylabel(r'$\omega_e$ (rad/sec)')
    plt.legend(prop={'size':10})

    ax = fig.add_subplot(2,1,2)
    plt.title('Attitude Error')
    ax.plot(data['ts'], data['est']['theta'], c='b', label=r'$\omega_x$', lw=2)
    grid_me(ax)
    ax.set_ylabel(r'$\theta_e$ (rad)')
    plt.legend(prop={'size':10})

    ax.set_xlabel('$t(k)$ seconds')

    plt.tight_layout()
    plt.draw()

    fig = plt.figure(dpi=80, facecolor='w', edgecolor='k')
    ax = fig.add_subplot(3,1,1)
    plt.title('Sliding Mode Controller\nBody Rate Error')
    ax.plot(data['ts'], [w[0] for w in data['ctrl']['w']], c='b', label=r'$\omega_x$', lw=2)
    ax.plot(data['ts'], [w[1] for w in data['ctrl']['w']], c='r', label=r'$\omega_y$', lw=2)
    ax.plot(data['ts'], [w[2] for w in data['ctrl']['w']], c='g', label=r'$\omega_z$', lw=2)
    grid_me(ax)
    ax.set_ylabel(r'$\omega_e$ (rad/sec)')
    plt.legend(prop={'size':10})

    ax = fig.add_subplot(3,1,2)
    plt.title('Attitude Error')
    ax.plot(data['ts'], data['ctrl']['nutation'], c='b', label=r'$\omega_x$', lw=2)
    grid_me(ax)
    ax.set_ylabel(r'$\theta_e$ (rad)')
    plt.legend(prop={'size':10})

    ax = fig.add_subplot(3,1,3)
    plt.title('Control Moment Couple')
    ax.plot(data['ts'], [M[0] for M in data['ctrl']['M']], c='b', label=r'$M_x$', lw=2)
    ax.plot(data['ts'], [M[1] for M in data['ctrl']['M']], c='r', label=r'$M_y$', lw=2)
    ax.plot(data['ts'], [M[2] for M in data['ctrl']['M']], c='g', label=r'$M_z$', lw=2)
    grid_me(ax)
    ax.set_ylabel(r'Moment (Nm)')
    plt.legend(prop={'size':10})

    ax.set_xlabel('$t(k)$ seconds')

    plt.tight_layout()
    plt.draw()



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
    print GradientDescent.descend(**kwargs)
    return 0



if __name__ == '__main__':

    kwargs = {
        'cLq': 0.04, 'cLx': 0.398, 'cLy': 0.383, 'cLz': 0.416,
        'cKq': 0.04, 'cKx': 0.440, 'cKy': 0.510, 'cKz': 0.316,
        'cSq': 0.3, 'cSw': 0.140,
        'eLq': 0.02, 'eLx': 0.02, 'eLy': 0.02, 'eLz': 0.02,
        'eKq': 0.001, 'eKx': 0.001, 'eKy': 0.001, 'eKz': 0.001,
        'eSq': 0.001, 'eSw': 0.001,
    }
    # kwargs = None


    if kwargs is not None:
        kwargs['plot'] = True
        run_test(**kwargs)
    else:
        exit(main())

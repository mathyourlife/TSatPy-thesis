
import time
import numpy as np
import matplotlib.pyplot as plt
from TSatPy import Controller, State
from TSatPy import StateOperator as SO
from TSatPy.Clock import Metronome
from GradientDescent import GradientDescent

print("Test P - Nutation and Rate Control")

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
    print x_est_ic.q.to_rotation()

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
    print GradientDescent.descend(**kwargs)
    return 0


if __name__ == '__main__':

    kwargs = {'Kpq': 0.47901969268646244, 'Kpwy': 0.43573255204969213, 'Kiq': 0.23422782727035843, 'Kiwy': 0.41818445360887868, 'Kpwx': 0.45697109766094501, 'Kiwx': 0.55745404271689825, 'Kpwz': 0.49569866087636422, 'Kiwz': 0.4945953718856187, 'Kdwx': 0.50103072883242128, 'Kdwy': 0.52160529258587596, 'Kdwz': 0.40695706046811397, 'Kdq': 0.43442128506386568}
    kwargs = {'Kpq': 0.12807216590620027, 'Kpwy': 0.59836934117647489, 'Kiq': 0.079776123206294125, 'Kiwy': 0.4110618936354361, 'Kpwx': 0.65471558317650869, 'Kiwx': 0.24624665781916058, 'Kpwz': 0.4812108710466928, 'Kiwz': 0.51739021270206353, 'Kdwx': 0.51034730297242903, 'Kdwy': 0.36060808856571025, 'Kdwz': 0.47818309294361827, 'Kdq': 0.30441925316806023}
    kwargs = {
        'Kpq': 0.1235,
        'Kpwx': 0.5484,
        'Kpwy': 0.4051,
        'Kpwz': 0.5821,
        'Kiq': 0.0214,
        'Kiwx': 0.3749,
        'Kiwy': 0.5795,
        'Kiwz': 0.5461,
        'Kdq': 0.3314,
        'Kdwx': 0.5647,
        'Kdwy': 0.4229,
        'Kdwz': 0.4485,
    }
    kwargs = {'Kpq': 0.083383319934661748, 'Kpwy': 0.41256894664240307, 'Kiq': 0.0070191013121491726, 'Kiwy': 0.63795114524611984, 'Kpwx': 0.58214422115530939, 'Kiwx': 0.36276812477957576, 'Kpwz': 0.56201044829917479, 'Kiwz': 0.58760890976584712, 'Kdwx': 0.58828106060061391, 'Kdwy': 0.4296736890934299, 'Kdwz': 0.479763941992426, 'Kdq': 0.32365875892938478}
    kwargs = {'Kpq': 0.11111822352039165, 'Kpwy': 0.46617055725812362, 'Kiq': 0.0092460954947930132, 'Kiwy': 0.56418807555550599, 'Kpwx': 0.56072598825499542, 'Kiwx': 0.34527737331963193, 'Kpwz': 0.62449446448477242, 'Kiwz': 0.54983623166470164, 'Kdwx': 0.59004903787603236, 'Kdwy': 0.4646265536024109, 'Kdwz': 0.42009087143770402, 'Kdq': 0.23121875724788765}


    # kwargs = None

    if kwargs is not None:
        kwargs['plot'] = True
        run_test(**kwargs)
    else:
        exit(main())


# Kpq:
#   val: 0.123478 range: 0.001,0.9    std: 0.0530347
# Kpwx:
#   val: 0.548404 range: 0.001,0.9    std: 0.0801909
# Kpwy:
#   val: 0.405114 range: 0.001,0.9    std: 0.122684
# Kpwz:
#   val: 0.582057 range: 0.001,0.9    std: 0.128632
# Kiq:
#   val: 0.0214227    range: 0.001,0.9    std: 0.00938169
# Kiwx:
#   val: 0.374881 range: 0.001,0.9    std: 0.0705854
# Kiwy:
#   val: 0.579459 range: 0.001,0.9    std: 0.153916
# Kiwz:
#   val: 0.546089 range: 0.001,0.9    std: 0.133292
# Kdq:
#   val: 0.331423 range: 0.001,0.9    std: 0.143169
# Kdwx:
#   val: 0.564732 range: 0.001,0.9    std: 0.117115
# Kdwy:
#   val: 0.422857 range: 0.001,0.9    std: 0.146171
# Kdwz:
#   val: 0.44853  range: 0.001,0.9    std: 0.088652


# Kpq:
#   val: 0.0833833    range: 0.02,0.22    std: 0.0321186
# Kpwx:
#   val: 0.582144 range: 0.39,0.71    std: 0.0461281
# Kpwy:
#   val: 0.412569 range: 0.17,0.65    std: 0.0947205
# Kpwz:
#   val: 0.56201  range: 0.32,0.84    std: 0.130095
# Kiq:
#   val: 0.0070191    range: 0.003,0.039  std: 0.00469471
# Kiwx:
#   val: 0.362768 range: 0.23,0.51    std: 0.0557253
# Kiwy:
#   val: 0.637951 range: 0.28,0.88    std: 0.0916396
# Kiwz:
#   val: 0.587609 range: 0.29,0.81    std: 0.0906193
# Kdq:
#   val: 0.323659 range: 0.05,0.61    std: 0.105882
# Kdwx:
#   val: 0.588281 range: 0.32,0.8 std: 0.0851083
# Kdwy:
#   val: 0.429674 range: 0.12,0.72    std: 0.136141
# Kdwz:
#   val: 0.479764 range: 0.27,0.63    std: 0.0693526

# Random body rates
# Kpq:
#   val: 0.111118 range: 0.02,0.22    std: 0.0340246
# Kpwx:
#   val: 0.560726 range: 0.39,0.71    std: 0.0474869
# Kpwy:
#   val: 0.466171 range: 0.17,0.65    std: 0.0840252
# Kpwz:
#   val: 0.624494 range: 0.32,0.84    std: 0.0970963
# Kiq:
#   val: 0.0092461    range: 0.003,0.039  std: 0.00281212
# Kiwx:
#   val: 0.345277 range: 0.23,0.51    std: 0.0553643
# Kiwy:
#   val: 0.564188 range: 0.28,0.88    std: 0.115591
# Kiwz:
#   val: 0.549836 range: 0.29,0.81    std: 0.0990584
# Kdq:
#   val: 0.231219 range: 0.05,0.61    std: 0.0793672
# Kdwx:
#   val: 0.590049 range: 0.32,0.8 std: 0.107061
# Kdwy:
#   val: 0.464627 range: 0.12,0.72    std: 0.0881444
# Kdwz:
#   val: 0.420091 range: 0.27,0.63    std: 0.06911

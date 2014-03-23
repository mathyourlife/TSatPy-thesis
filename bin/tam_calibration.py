
from collections import defaultdict
import TSatPy
import scipy.io as io
import numpy as np

from mpl_toolkits.mplot3d import Axes3D
import matplotlib.pyplot as plt

def convert_mat_to_csv():
    mat = '/home/dcouture/git/mathyourlife/TSatPy/beta_versions/matlab_object_oriented/TAMNutation/TAM-Calibration.mat'
    mat = '/home/dcouture/git/mathyourlife/TSatPy/beta_versions/matlab_object_oriented/TAM-Calibration2.mat'
    tam_data = io.loadmat(mat)

    # steady_data, xpos_data, ypos_data, xneg_data, yneg_data

    # with open('tam_calibration_steady.csv', 'w') as f:
    #     f.write()

    np.savetxt(
        'tam_calibration_yneg2.csv',
        tam_data['calibration']['yneg_data'][0][0],
        delimiter=","
    )

    data = np.genfromtxt('tam_calibration_yneg2.csv', dtype=float, delimiter=',')

    for line in data:
        pass
        # print line
        # break
    print data


def plot_refs():
    pda = TSatPy.Sensor.PhotoDiodeArray()

    # steady_data, xpos_data, ypos_data, xneg_data, yneg_data

    tam_log = {
        'steady': np.genfromtxt('tam_calibration_steady2.csv', dtype=float, delimiter=','),
        'xpos': np.genfromtxt('tam_calibration_xpos2.csv', dtype=float, delimiter=','),
        'ypos': np.genfromtxt('tam_calibration_ypos2.csv', dtype=float, delimiter=','),
        'xneg': np.genfromtxt('tam_calibration_xneg2.csv', dtype=float, delimiter=','),
        'yneg': np.genfromtxt('tam_calibration_yneg2.csv', dtype=float, delimiter=','),
    }

    css = np.array([0, 0, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0], dtype=np.bool)
    tam = np.array([0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1], dtype=np.bool)

    means = {}
    tam_angles = {}
    tam_ref = {}
    for key in tam_log.keys():
        means[key] = tam_log[key].mean(axis=0)

        tam_angles[key] = {
            'volts': defaultdict(int),
            'tally': defaultdict(int),
        }

        for line in tam_log[key]:
            pda.update_state(line[css])
            vector, theta = pda.x.q.to_rotation()
            deg = int(theta / np.pi * 180)
            tam_angles[key]['volts'][deg] += line[tam]
            tam_angles[key]['tally'][deg] += 1

        tam_ref[key] = {}
        for deg in xrange(360):
            tally = 0
            volt = 0
            for dx in xrange(-5, 6):
                idx = (deg + dx) % 360
                tally += tam_angles[key]['tally'][idx]
                volt += tam_angles[key]['volts'][idx]
            tam_ref[key][deg] = volt / tally

        # for deg, volt in sorted(tam_ref[key].iteritems()):
        #     print deg, volt - means[key][tam]


    fig = plt.figure()
    ax = fig.add_subplot(111, projection='3d')
    n = 100

    colors = 'rbmgk'
    for idx, key in enumerate(tam_log.keys()):
        xs = [v[0] for v in tam_ref[key].itervalues()]
        ys = [v[1] for v in tam_ref[key].itervalues()]
        zs = [v[2] for v in tam_ref[key].itervalues()]
        ax.plot(xs, ys, zs, c=colors[idx], marker='o', label=key)

    ax.set_xlabel('X Label')
    ax.set_ylabel('Y Label')
    ax.set_zlabel('Z Label')

    plt.legend(loc='upper left', numpoints=1, ncol=3, fontsize=14, bbox_to_anchor=(0, 0))
    plt.show()

plot_refs()
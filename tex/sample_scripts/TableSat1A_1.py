
import os
from collections import defaultdict
import TSatPy
import scipy.io as io
import numpy as np

from mpl_toolkits.mplot3d import Axes3D
import matplotlib.pyplot as plt

ROOT_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), '../../'))


def convert_mat_to_csv():
    mat = os.path.join(ROOT_DIR, 'data/tam/TAM-Calibration.mat')
    mat = os.path.join(ROOT_DIR, 'data/tam/TAM-Calibration2.mat')
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


def calculate_tam_nutation_refences():

    smoothing_window = 15
    pda = TSatPy.Sensor.PhotoDiodeArray()

    # steady_data, xpos_data, ypos_data, xneg_data, yneg_data

    data_dir = os.path.join(ROOT_DIR, 'data/tam')
    tam_log = {
        'steady': np.genfromtxt(
            os.path.join(data_dir, 'tam_calibration_steady2.csv'),
            dtype=float, delimiter=','),
        'xpos': np.genfromtxt(
            os.path.join(data_dir, 'tam_calibration_xpos2.csv'),
            dtype=float, delimiter=','),
        'ypos': np.genfromtxt(
            os.path.join(data_dir, 'tam_calibration_ypos2.csv'),
            dtype=float, delimiter=','),
        'xneg': np.genfromtxt(
            os.path.join(data_dir, 'tam_calibration_xneg2.csv'),
            dtype=float, delimiter=','),
        'yneg': np.genfromtxt(
            os.path.join(data_dir, 'tam_calibration_yneg2.csv'),
            dtype=float, delimiter=','),
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
            for dx in xrange(-smoothing_window, smoothing_window + 1):
                idx = (deg + dx) % 360
                tally += tam_angles[key]['tally'][idx]
                volt += tam_angles[key]['volts'][idx]
            tam_ref[key][deg] = volt / tally

    return tam_ref, smoothing_window


def plot_tam_ref(tam_ref, smoothing_window):
    fig = plt.figure()
    ax = fig.add_subplot(111, projection='3d')
    n = 100


    colors = {
        'steady': 'b',
        'xpos': 'r',
        'ypos': 'm',
        'xneg': 'g',
        'yneg': 'k'
    }
    for key, color in colors.iteritems():
        xs = [v[0] for v in tam_ref[key].itervalues()]
        ys = [v[1] for v in tam_ref[key].itervalues()]
        zs = [v[2] for v in tam_ref[key].itervalues()]
        ax.plot(xs, ys, zs, c=color, label=key, lw=2)

    ax.set_xlabel('TAM X')
    ax.set_ylabel('TAM Y')
    ax.set_zlabel('TAM Z')

    plt.title('TAM Calibration Reference Data\nSmoothing Window=+-%s deg' % smoothing_window)
    plt.legend(loc='upper left', numpoints=1, ncol=3, fontsize=14, bbox_to_anchor=(0, 0))
    plt.show()

def plot_tam_ref_for_yaw(tam_ref, smoothing_window, yaw):
    fig = plt.figure()
    ax = fig.add_subplot(111, projection='3d')
    n = 100

    colors = {
        'steady': 'b',
        'xpos': 'r',
        'ypos': 'm',
        'xneg': 'g',
        'yneg': 'k'
    }
    for key, color in colors.iteritems():
        xs = [v[0] for v in tam_ref[key].itervalues()]
        ys = [v[1] for v in tam_ref[key].itervalues()]
        zs = [v[2] for v in tam_ref[key].itervalues()]
        ax.plot(xs, ys, zs, c=color, label=key, lw=2, ls='--')

    for key in ['xpos', 'ypos', 'xneg', 'yneg']:
        xs = [tam_ref['steady'][yaw][0], tam_ref[key][yaw][0]]
        ys = [tam_ref['steady'][yaw][1], tam_ref[key][yaw][1]]
        zs = [tam_ref['steady'][yaw][2], tam_ref[key][yaw][2]]
        ax.plot(xs, ys, zs, c=colors[key], lw=4)

    ax.set_xlabel('TAM X')
    ax.set_ylabel('TAM Y')
    ax.set_zlabel('TAM Z')

    plt.title('TAM Calibration Reference Data\nfor Yaw = 191 deg')
    plt.legend(loc='upper left', numpoints=1, ncol=3, fontsize=14, bbox_to_anchor=(0, 0))
    plt.show()

def plot_tam_ref_for_yaw_close(tam_ref, smoothing_window, yaw, tam_pt):
    fig = plt.figure()
    ax = fig.add_subplot(111, projection='3d')
    n = 100

    colors = {
        'steady': 'b',
        'xpos': 'r',
        'ypos': 'm',
        'xneg': 'g',
        'yneg': 'k'
    }

    for key in ['xpos', 'ypos', 'xneg', 'yneg']:
        xs = [tam_ref['steady'][yaw][0], tam_ref[key][yaw][0]]
        ys = [tam_ref['steady'][yaw][1], tam_ref[key][yaw][1]]
        zs = [tam_ref['steady'][yaw][2], tam_ref[key][yaw][2]]
        ax.plot(xs, ys, zs, c=colors[key], lw=4)
        ax.plot(*tam_pt[key], marker='o', color=colors[key], ls='None',
            markersize=10, label=key)

    ax.plot(*tam_pt['steady'], marker='o', color=colors['steady'], ls='None',
        markersize=10, label='steady')

    ax.set_xlabel('TAM X')
    ax.set_ylabel('TAM Y')
    ax.set_zlabel('TAM Z')

    plt.title('TAM Calibration Reference Data\nfor Yaw = 191 deg')
    plt.legend(loc='upper left', numpoints=1, ncol=3, fontsize=14, bbox_to_anchor=(0, 0))
    plt.show()


def main():
    tam_ref, smoothing_window = calculate_tam_nutation_refences()

    plot_tam_ref(tam_ref, smoothing_window)

    plot_tam_ref_for_yaw(tam_ref, smoothing_window, 191)

    tam_191_data = {
        'steady': ([ 2.6466, 2.6351, 2.6328, 2.6314 ],
                [ 2.403, 2.3967, 2.3929, 2.397 ],
                [ 2.3114, 2.3169, 2.313, 2.3038 ]),
        'xpos': ([ 2.6451, 2.6378, 2.6337 ],
                [ 2.4236, 2.4093, 2.4252 ],
                [ 2.3044, 2.3095, 2.3117 ]),
        'ypos': ([ 2.6318, 2.6431, 2.6395, 2.6257, 2.641 ],
                [ 2.4207, 2.4293, 2.4242, 2.4136, 2.436 ],
                [ 2.3256, 2.3124, 2.3218, 2.3227, 2.3193 ]),
        'xneg': ([ 2.6369, 2.6518, 2.645 , 2.6479, 2.6389, 2.6451 ],
                [ 2.3953, 2.4002, 2.4037, 2.403, 2.3884, 2.4058 ],
                [ 2.3243, 2.3215, 2.3228, 2.3293, 2.3149, 2.3241 ]),
        'yneg': ([ 2.6389, 2.6279, 2.6353, 2.6282, 2.6382, 2.6305, 2.6266,
                    2.6342, 2.6305, 2.6333 ],
                [ 2.3983, 2.3695, 2.3868, 2.3826, 2.3891, 2.3786, 2.3894,
                    2.3928, 2.3945, 2.3843 ],
                [ 2.3237, 2.3187, 2.3177, 2.3202, 2.3264, 2.3094, 2.315,
                    2.312, 2.3161, 2.3093 ]),
    }

    plot_tam_ref_for_yaw_close(
        tam_ref, smoothing_window, 191, tam_191_data)

    tam_191_data = {
        'steady': ([ ], [ ], [ ]),
        'xpos': ([ ], [ ], [ ]),
        'ypos': ([ ], [ ], [ ]),
        'xneg': ([ ], [ ], [ ]),
        'yneg': ([ 2.6279 ], [ 2.3695 ], [ 2.3187 ]),
    }

    plot_tam_ref_for_yaw_close(
        tam_ref, smoothing_window, 191, tam_191_data)
    return 0


if __name__ == "__main__":
    exit(main())

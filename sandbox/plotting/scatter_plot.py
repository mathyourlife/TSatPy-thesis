import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D
import numpy as np

plt.ion()


class Body(object):
    def __init__(self):
        self.pts = {}

    def add_path(self, name, pts):
        self.pts[name] = pts


class TSat(Body):

    def __init__(self, radius):
        super(TSat, self).__init__()
        self.radius = radius
        self.setup_body()
        self.add_booms()

    def add_booms(self):
        boom_len = 1
        count = 10
        dx = boom_len / float(count)

        zeros = np.empty(count + 1)
        zeros.fill(0)

        dots = []
        for pos in range(count + 1):
            dots.append(self.radius + dx * pos)

        self.add_path('+x boom', [np.array(dots), zeros.copy(), zeros.copy()])
        self.add_path('+y boom', [zeros.copy(), np.array(dots), zeros.copy()])
        self.add_path('+z boom', [zeros.copy(), zeros.copy(), np.array(dots)])
        self.add_path('-x boom', [-np.array(dots), zeros.copy(), zeros.copy()])
        self.add_path('-y boom', [zeros.copy(), -np.array(dots), zeros.copy()])
        self.add_path('-z boom', [zeros.copy(), zeros.copy(), -np.array(dots)])

    def setup_body(self):


        phi = np.linspace(0, 2 * np.pi, 100)
        r = np.linspace(0, 1, 100)

        x = 0.5 * np.outer(np.cos(phi), r)
        y = 0.5 * np.outer(np.sin(phi), r)
        z = np.zeros([100,100])

        self.add_path('body', [x, y, z])


class Model(object):
    def __init__(self, data_model):
        self.fig = plt.figure()
        self.ax = self.fig.add_subplot(111, projection='3d')

        self.data_model = data_model
        self.series = {}

        for name, data in self.data_model.pts.items():
            if name == 'body':
                self.series[name] = self.ax.plot_surface(*data, rstride=10, cstride=50, linewidth=1, alpha=1)
            else:
                self.series[name] = self.ax.plot(*data, color='blue', linewidth=3)

        plt.show()


def main():
    tsat = TSat(0.5)

    model = Model(tsat)
    raw_input('aeou')


if __name__ == '__main__':
    main()

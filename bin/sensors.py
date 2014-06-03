
import time
import numpy as np
from TSatPy.Clock import Metronome
from TSatPy import State, Sensor

# Create truth model with a plant
# Generate sensor values based on propagating plant
# Feed sensor voltages through sensor class
# Feed sensor state to PID estimator
# Compare PID estimator to truth model

c = Metronome()
I = [[4, 0, 0], [0, 4, 0], [0, 0, 4]]

def setup_plant():
    q = State.Quaternion([0, 0, 1], radians=0 / 180.0 * np.pi)
    w = State.BodyRate([0, 0, np.pi/3])
    x = State.State(q, w)

    p = State.Plant(I, x, c)
    return p

def sensor_voltages():
    p = setup_plant()
    count = 0
    while True:
        p.propagate([0,0,0])
        print('*%s' % p.x)
        yield q2v(p.x.q)
        # qr, qn = p.x.q.decompose()
        # print('*%s' % p.x.q)
        # print(np.arctan(qr.vector[2,0] / qr.scalar) / np.pi * 180)
        # z = 2*np.arctan(qr.vector[2,0] / qr.scalar)

        # if z < 0:
        #     z += 2 * np.pi
        # if z >= 2 * np.pi:
        #     z -= 2 * np.pi

        # v = np.cos(np.mat(range(6)) * np.pi / 3.0 - z)
        # v[v < 0] = 0
        # yield v.tolist()[0]

        count += 1
        if count >= 10:
            raise StopIteration


def pd_array():
    return Sensor.PhotoDiodeArray()


def q2v(q):
    qr, qn = q.decompose()
    # print('*%s' % qr)
    z = 2*np.arctan(qr.vector[2,0] / qr.scalar)
    # print(-z / np.pi * 180)
    v = np.cos(np.mat(range(6)) * np.pi / 3.0 + z)
    v[v < 0] = 0
    return v.tolist()[0]

def main():

    # q = State.Quaternion([0,0,1],radians=90 / 180.0 * np.pi)
    # q2v(q)
    pd = pd_array()
    for v in sensor_voltages():
        time.sleep(0.3)
        pd.update_state(v)
        print(pd.x)
        print('*'*100)


if __name__ == "__main__":
    main()



import time
import numpy as np
from TSatPy.Clock import Metronome
from TSatPy import State, StateOperators, Estimator

c = Metronome()

def setup_plant():

    q = State.Quaternion([0, 0, 1], radians=np.pi/2)
    w = State.BodyRate([0, 0, np.pi/10])
    x = State.State(q, w)
    I = [[4, 0, 0], [0, 4, 0], [0, 0, 4]]

    p = State.Plant(I, x, c)

    return p


def setup_pid():
    pid = Estimator.PID(c)

    k = 0.05
    Kq = StateOperators.QuaternionGain(0.05)
    Kw = StateOperators.BodyRateGain([[k,0,0],[0,k,0],[0,0,k]])
    Kp = StateOperators.StateGain(Kq, Kw)

    pid.set_Kp(Kp)

    k = 2
    Kq = StateOperators.QuaternionGain(0)
    Kw = StateOperators.BodyRateGain([[k,0,0],[0,k,0],[0,0,k]])
    Ki = StateOperators.StateGain(Kq, Kw)

    pid.set_Ki(Ki)

    return pid


def main():

    p = setup_plant()

    pid = setup_pid()

    end_time = time.time() + 4
    while time.time() < end_time:
        time.sleep(0.05)
        p.propagate([0,0,0])
        x_hat = pid.update(p.x)
        print('%s\t%s' % (p.x.w, x_hat.w))


if __name__ == "__main__":
    main()
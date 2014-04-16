from TSatPy.State import State, Quaternion, BodyRate
from TSatPy.StateOperators import QuaternionGain, BodyRateGain, StateGain
import numpy as np

k_q = 0.25
k_w = [[0.2,0,0],[0,0.3,0],[0,0,0.8]]

x = State(
    Quaternion([0,0,1],radians=44/180.0*np.pi),
    BodyRate([0.02,-0.04,0.3])
)
print("x:      %s" % (x))

Kx = StateGain(
    QuaternionGain(k_q),
    BodyRateGain(k_w))
print("Kx:     %s" % (Kx))

x_adj = Kx * x
print("x_adj:  %s" % (x_adj))

e, r = x_adj.q.to_rotation()
print("e:      <%g, %g, %g>\ndegree: %g" % (
    e[0,0],e[1,0],e[2,0], r * 180.0 / np.pi))

# Prints Out
# x:      <Quaternion [-0 -0 -0.374607], 0.927184>, <BodyRate [0.02 -0.04 0.3]>
# Kx:     <StateGain <Kq 0.25>, <Kw = [[ 0.2 0. 0. ] [ 0. 0.3 0. ] [ 0. 0. 0.8]]>>
# x_adj:  <Quaternion [-0 -0 -0.0958458], 0.995396>, <BodyRate [0.004 -0.012 0.24]>
# e:      <-0, -0, -1>
# degree: 11

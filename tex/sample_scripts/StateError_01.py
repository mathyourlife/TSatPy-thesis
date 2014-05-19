from TSatPy.State import Quaternion, QuaternionError, State, BodyRate
import numpy as np

x_hat = State(
    Quaternion([0,0,1],radians=190/180.0*np.pi),
    BodyRate([0,0,3])
)
x_m = State(
    Quaternion([0,0.1,1],radians=44/180.0*np.pi),
    BodyRate([0,0,3.1])
)
print("x_hat:  %s" % (x_hat))
print("x_m:    %s" % (x_m))

# Prints Out
# x_hat:  <Quaternion [-0 -0 -0.996195], -0.0871557>,
#         <BodyRate [0 0 3]>
# x_m:    <Quaternion [-0 -0.0372747 -0.372747], 0.927184>,
#         <BodyRate [0 0 3.1]>

print('*' * 80)

x_e = State(
    Quaternion(x_hat.q.vector - x_m.q.vector,
        x_hat.q.scalar - x_m.q.scalar),
    x_hat.w - x_m.w
)
print("x_e:  %s" % (x_e))

# Prints Out
# x_e:  <Quaternion [0 0.0372747 -0.623447], -1.01434>,
#       <BodyRate [0 0 -0.1]>

print('*' * 80)

q_hat = x_hat.q
q_e = x_e.q
q_adj = Quaternion(-0.8 * q_e.vector, -0.8 * q_e.scalar)
q_hat_new = Quaternion(q_hat.vector + q_adj.vector,
        q_hat.scalar + q_adj.scalar)

print("q_e:         %s" % (q_e))
print("q_adj:       %s" % (q_adj))
print("q_hat_new:   %s" % (q_hat_new))
print("|q_hat_new|: %g" % (q_hat_new.mag))

# Prints Out
# q_e:         <Quaternion [0 0.0372747 -0.623447], -1.01434>
# q_adj:       <Quaternion [-0 -0.0298198 0.498758], 0.811472>
# q_hat_new:   <Quaternion [-0 -0.0298198 -0.497437], 0.724316>
# |q_hat_new|: 0.879185

print('*' * 80)

pt = np.mat([[1,0,0]])
pt = q_hat_new.rotate_points(pt)
print("pt * pt.T:   %s" % (pt * pt.T))

# Prints Out
# pt * pt.T:   [[ 0.5974769]]

print('*' * 80)

print("q_hat_new:   %s" % (q_hat_new))
q_hat_new.normalize()
print("q_hat_new:   %s" % (q_hat_new))
print("|q_hat_new|: %g" % (q_hat_new.mag))

# Prints Out
# q_hat_new:   <Quaternion [-0 -0.0298198 -0.497437], 0.724316>
# q_hat_new:   <Quaternion [-0 -0.0339175 -0.565793], 0.823849>
# |q_hat_new|: 1.0

print('*' * 80)

e, r = q_hat_new.to_rotation()
print("e: <%g, %g, %g>\ndegree: %g" % (
    e[0,0],e[1,0],e[2,0], r * 180.0 / np.pi))

# Prints Out
# e: <-0, -0.0598395, -0.998208>
# degree: 69.056

print('*' * 80)

a = Quaternion([0,0,1],radians=190/180.0*np.pi)
b = Quaternion([0,0,1],radians=(190 + 360)/180.0*np.pi)

print("a:          %s" % (a))
print("b:          %s" % (b))
print("a.conj * b: %s" % (a.conj * b))

# Prints Out
# a:          <Quaternion [-0 -0 -0.996195], -0.0871557>
# b:          <Quaternion [0 0 0.996195], 0.0871557>
# a.conj * b: <Quaternion [0 0 -3.46945e-16], -1>

print('*' * 80)

q_e = QuaternionError(x_hat.q, x_m.q)

print("q_e:   %s" % (q_e))
print("|q_e|: %s" % (q_e.mag))
e, r = q_e.to_rotation()
print("e:     <%g, %g, %g>\ndegree: %g" % (
    e[0,0],e[1,0],e[2,0], r * 180.0 / np.pi))

# Prints Out
# q_e:   <Quaternion [-0.0371329 -0.00324871 -0.956143], 0.29052>
# |q_e|: 1.0
# e:     <-0.0388067, -0.00339514, -0.999241>
# degree: 146.222

print('*' * 80)

q_adj = Quaternion(
    q_e.vector * 0.7,
    q_e.scalar * 0.4)

print("q_adj:   %s" % (q_adj))
print("|q_adj|: %s" % (q_adj.mag))

# Prints Out
# q_adj:   <Quaternion [-0.025993 -0.0022741 -0.6693], 0.116208>
# |q_adj|: 0.679814272084

print('*' * 80)

k = 2

q_e = Quaternion([0,0,1],radians=0.01)
a = np.sqrt((q_e.vector.T * q_e.vector)[0,0] + k**2 * q_e.scalar**2)
q_adj = Quaternion(
    q_e.vector / a,
    k * q_e.scalar / a
)
print(q_adj.to_rotation())
exit()

print('*' * 80)

q_adj.normalize()
print("q_adj:   %s" % (q_adj))
print("|q_adj|: %s" % (q_adj.mag))

q_adj = Quaternion(
    q_e.vector,
    q_e.scalar * 0.4)

q_adj.normalize()
print("q_adj:   %s" % (q_adj))
print("|q_adj|: %s" % (q_adj.mag))

print('*' * 80)

k = 0.2
degree = 45

q_e = Quaternion([0,0,1], radians=degree/180.0*np.pi)
print("q_e:     %s" % (q_e))

kpc = k * np.arccos(q_e.scalar)
gamma = np.sqrt((q_e.vector.T * q_e.vector)[0,0] / (np.sin(kpc))**2)

q_adj = Quaternion(
    q_e.vector / gamma,
    np.cos(kpc)
)
print("q_adj:   %s" % (q_adj))
print("|q_adj|: %s" % (q_adj.mag))

e, r = q_adj.to_rotation()
print("e:       <%g, %g, %g>\ndegree: %g" % (
    e[0,0],e[1,0],e[2,0], r * 180.0 / np.pi))

# Prints Out
# q_e:     <Quaternion [-0 -0 -0.382683], 0.92388>
# q_adj:   <Quaternion [-0 -0 -0.0784591], 0.996917>
# |q_adj|: 1.0
# e:       <-0, -0, -1>
# degree: 9

print('*' * 80)

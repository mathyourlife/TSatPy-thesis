from TSatPy.State import Quaternion

print("Quaternion Decomposition")

q_r1 = Quaternion([0,0,1], radians=1.2)
q_n1 = Quaternion([1,-1,0], radians=-0.2)
print("q_r1: %s" % (q_r1))
print("q_n1: %s" % (q_n1))

q = q_n1 * q_r1
print("q:    %s" % (q))

q_r2, q_n2 = q.decompose()
print("q_r2: %s" % q_r2)
print("q_r2: %s" % q_n2)

# Prints Out
# q_r1: <Quaternion [-0 -0 -0.564642], 0.825336>
# q_n1: <Quaternion [0.0705929 -0.0705929 0], 0.995004>
# q:    <Quaternion [0.0981226 -0.0184031 -0.561822], 0.821212>
# q_r2: <Quaternion [0 0 -0.564642], 0.825336>
# q_r2: <Quaternion [0.0705929 -0.0705929 -0], 0.995004>

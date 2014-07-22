function q = mtimes(K,q)
% Calculate the product of the gain matrix and a quaternion.

vector = K.Kv * q.vector;
scalar = K.Ks * q.scalar;

args = struct;
args.vector = vector;
args.scalar = scalar;
q = quaternion(args);

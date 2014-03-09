disp('Testing quaternionGain class')

tb = testBase;
qg = quaternionGain();

tb.assertEquals(1,qg.Ks,'Quaternion gain has the initial scalar value.');
tb.assertEquals(eye(3),qg.Kv,'Quaternion gain has the initial vector value.');

q = mock().gen_random_quaternion;
r = qg * q;

tb.assertEquals(q,r,'Multiplied a random quaternion by a identity quaternion gain.');

args = struct;
args.Kv = rand(3,3);
args.Ks = rand();
qg = quaternionGain(args);

q = mock().gen_random_quaternion;
r = qg * q;

args_check = struct;
args_check.scalar = args.Ks * q.scalar;
args_check.vector = args.Kv * q.vector;
q_check = quaternion(args_check);

tb.assertEquals(q_check, r, 'Multiplied a random quaternion by a non-identity quaternion gain.');

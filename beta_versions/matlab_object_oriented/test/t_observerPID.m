disp('Testing PID Observer class')

o = observerPID();
tb=testBase;

tb.assertEquals(state(),o.state,'Default state value.');
tb.assertEquals(eye(3),o.Kp.Kq.Kv,'Default PID proportional gain for quaternion vector.');
tb.assertEquals(1,     o.Kp.Kq.Ks,'Default PID proportional gain for quaternion scalar.');
tb.assertEquals(eye(3),o.Ki.Kq.Kv,'Default PID integral gain for quaternion vector.');
tb.assertEquals(1,     o.Ki.Kq.Ks,'Default PID integral gain for quaternion scalar.');
tb.assertEquals(eye(3),o.Kd.Kq.Kv,'Default PID derviative gain for quaternion vector.');
tb.assertEquals(1,     o.Kd.Kq.Ks,'Default PID derviative gain for quaternion scalar.');

global t
start_time = t.now();
o = observerPID();
o.Kp.Kq.Kv = rand(3,3) .* eye(3);
o.Kp.Kq.Ks = rand();
o.Ki.Kq.Kv = rand(3,3) .* eye(3);
o.Ki.Kq.Ks = rand();
o.Kd.Kq.Kv = rand(3,3) .* eye(3);
o.Kd.Kq.Ks = rand();

q_update = mock().gen_random_quaternion;
args = struct;
args.q = q_update;
s = state(args);

% wait a random time from 0 to 2 sec
wait = rand()*2+2;
pause(wait)
args = struct;
args.state = s;
o=o.update(args);
end_time = t.now();

args = struct;
args.vector = o.Kp.Kq.Kv * q_update.vector;
args.scalar = o.Kp.Kq.Ks * q_update.scalar;
qp_check = quaternion(args);
args = struct;
args.vector = o.Ki.Kq.Kv * q_update.vector * (end_time - start_time);
args.scalar = o.Ki.Kq.Ks * q_update.scalar * (end_time - start_time);
qi_check = quaternion(args);
args = struct;
args.vector = o.Kd.Kq.Kv * q_update.vector / (end_time - start_time);
args.scalar = o.Kd.Kq.Ks * q_update.scalar / (end_time - start_time);
qd_check = quaternion(args);

q_check = qp_check + qi_check + qd_check;
q_check.normalize();

tb.assertMaxError(q_check, o.state.q, 0.5, 'Check the state after the update');

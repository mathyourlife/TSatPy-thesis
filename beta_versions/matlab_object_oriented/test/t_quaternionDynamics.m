disp('Testing quaternionDynamics class')

tb=testBase;

args = struct; args.vector = [0 0 1]; args.theta = 0;
q_o = quaternion(args);
args = struct; args.q = q_o;
qd = quaternionDynamics(args);

tb.assertEquals(q_o,qd.q,'Initialize a quaternionDynamics class with a quaternion state');

% Propagation is being done in discrete time.  To better approximate continuous time
% sub steps can be propagated between each measurement update.
args = struct;
args.w = [0 0 pi/2];
w = bodyRate(args);
dt = 1;
steps = 5;
args = struct; args.w = w; args.dt = dt; args.steps = steps;
qd.propagate(args);

qf = '<+0.00000 +0.00000 -0.70259> +0.71159';
tb.assertEquals(qf,qd.q.str,'Quaternion state after propagation of 1 sec with 5 sub-steps.');


args = struct; args.q = q_o;
qd = quaternionDynamics(args);
args = struct;
args.w = [0 0 pi/2];
w = bodyRate(args);
dt = 1;
steps = 20;
args = struct; args.w = w; args.dt = dt; args.steps = steps;
qd.propagate(args);

qf = '<+0.00000 +0.00000 -0.70682> +0.70739';
tb.assertEquals(qf,qd.q.str,'Quaternion state after propagation of 1 sec with 20 sub-steps.');


args = struct; args.q = q_o;
qd = quaternionDynamics(args);
args = struct;
args.w = [0 0 pi/2];
w = bodyRate(args);
dt = 2;
steps = 500;
args = struct; args.w = w; args.dt = dt; args.steps = steps;
qd.propagate(args);

qf = '<+0.00000 +0.00000 -1.00000> +0.00001';
tb.assertEquals(qf,qd.q.str,'Quaternion state after propagation of 2 sec with 500 sub-steps.');

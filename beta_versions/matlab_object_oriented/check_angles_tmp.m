disp('Testing use of the truth model')

disp('Creating initial state')
args = struct;
args.vector = [0 0 1];
args.theta = -pi/2;
q1 = quaternion(args);

args = struct;
args.vector = [0 1 0];
args.theta = pi/20;
q2 = quaternion(args);

q = q2 * q1;

disp('Visualize the initial quaternion value')
q_arr = {};
q_arr{1} = q1;
q_arr{2} = q2;
visualizeQuaternion(q_arr,state(),[0.4 0 0]');

disp('Initialize the truth model')
tr = truthModel();
tr.plant.state.q = q;
[vector, theta] = tr.plant.state.q.toRotation();
disp(sprintf('Truth Model created the state\n Vector: %g %g %g\n Theta: %0.0f\n %s',vector,theta*180/pi,tr.plant.state.str))

disp('Generate voltages based on the desired initial state');
v = tr.generate_voltages();

disp('Pass voltages to the "live" code to update');
args = struct; args.volts = [v.css; v.accel; v.gyro; v.mag];
tsat.sensors = tsat.sensors.update(args);

[vector, theta] = tsat.sensors.state.q.toRotation();
disp(sprintf('Sensors have been updated to a state\n Vector: %g %g %g\n Theta: %0.0f\n %s',vector,theta*180/pi,tsat.sensors.state.str))
[vector, theta] = tsat.sensors.css.state.q.toRotation();
disp(sprintf('CSS picked up a state of\n %s',tsat.sensors.css.state.str))























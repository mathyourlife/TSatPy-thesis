function check_angles()
	disp('Testing use of the truth model')
	
	global tsat
	
	disp('Creating initial state')
	args = struct;
	args.vector = [0 0 1];
	args.theta = -pi/2;
	q1 = quaternion(args);
	
	args = struct;
	args.vector = [0 1 0];
	args.theta = pi / 18;
	q2 = quaternion(args);
	
	q = q2 * q1;
	
	disp('Visualize the initial quaternion value')
	q_arr = {};
	q_arr{1} = q1;
	%q_arr{2} = q2;
	%visualizeQuaternion(q_arr);
	
	disp('Initialize the truth model')
	tr = truthModel();
	tr_state = state();
	tr_state.q = q;
	s_array = sensors();
	
	[vector, theta] = tr_state.q.toRotation();
	disp(sprintf('Truth Model created the state\n Vector: %g %g %g\n Theta: %0.0f\n %s',vector,theta*180/pi,tr_state.q.str))
	
	disp('Generate voltages based on the desired initial state');
	args = struct; args.state = tr_state;
	v = tr.generate_voltages(args);
	disp(sprintf('css: %0.3f %0.3f %0.3f %0.3f %0.3f %0.3f', v.css))
	disp(sprintf('mag: %0.3f %0.3f %0.3f', v.mag))
	disp(sprintf('gyro: %0.3f', v.gyro))
	disp(sprintf('accel: %0.3f %0.3f %0.3f %0.3f', v.accel))
	
	disp('Pass voltages to the "live" code to update');
	args = struct; args.volts = v;
	s_array.update(args);
	
	[vector, theta] = s_array.state.q.toRotation();
	disp(sprintf('Sensors have been updated to a state\n Vector: %g %g %g\n Theta: %0.0f\n %s',vector,theta*180/pi,s_array.state.q.str))
	[vector, theta] = s_array.css.state.q.toRotation();
	disp(sprintf('CSS picked up an attitude of\n %s',s_array.css.state.q.str))
	disp(sprintf('MAG picked up an attitude of\n %s',s_array.mag.state.q.str))
	disp(sprintf('GYRO picked up an attitude of\n %s',s_array.gyro.state.q.str))
	disp(sprintf('ACCEL picked up an attitude of\n %s',s_array.accel.state.q.str))
	
end
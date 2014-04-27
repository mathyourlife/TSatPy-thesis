function t_propagate_quaternion()
  disp('Testing propagat_quaternion util')
  
  tb=testBase;
  
  start_angle = pi/4;
  spin_rate = pi/2;
  dt = 0.5;
  
  args = struct; args.vector = [0 0 1]'; args.theta = start_angle;
  q1 = quaternion(args);
  
  args = struct; args.w = [0 0 spin_rate]';
  w = bodyRate(args);
  
  q2 = propagate_quaternion(q1, w, w, dt);
  
  args = struct; args.vector = [0 0 1]'; args.theta = start_angle + (spin_rate * dt);
  q_exp = quaternion(args);
  
  tb.assertMaxError(q_exp, q2, 0.1, 'Quaternion propagated with body rate');
  
end
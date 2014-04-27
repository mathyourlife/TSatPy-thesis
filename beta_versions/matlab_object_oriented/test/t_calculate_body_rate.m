function t_calculate_body_rate()
  
  tb = testBase();
  
  turn = -10;
  dt = 2;
  
  w_expected = [0 0 -5]';
  
  for start_angle = -360:30:360
    
    args = struct; args.vector = [0 0 1]'; args.theta = start_angle / 180 * pi;
    q1 = quaternion(args);
    
    w = [0 0 turn/180*pi]';
    
    q2 = find_end_q(q1, w, 1);
    
    w_total = calculate_body_rate(q1, q2, dt);
    
    w_check = w_total/pi*180;
    
    msg = sprintf('Checking body rate for start angle of %d degrees', start_angle);
    tb.assertMaxError(w_expected, w_check, 2, msg);
  end
end

function q = find_end_q(q, w, dt)
  
  sub_steps = 100;
  
  w = -w * dt / sub_steps;
  
  % Create a quaternion based on the body rates to 
  % make use of the quaternion multiplication
  args = struct;
  args.vector = w / 2;
  args.scalar = 0;
  q_w = quaternion(args);
  
  q_org = q.copy();
  
  for i=1:sub_steps
    q_dot = q_w * q;
    q = q + q_dot;
  end
  
  % Make sure its normalized
  q.normalize();
end
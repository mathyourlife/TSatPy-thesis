function q2 = propagate_quaternion(q1, w1, w2, dt)
  
  % source: www-users.cs.umn.edu/~trawny/Publications/Quaternions_3D.pdf
  omega_1 = omega(-w1.w);
  omega_2 = omega(-w2.w);
  omega_bar = omega_1 + 1/2 * omega(-(w2.w - w1.w));
  
  phi = expm(1/2 * omega_bar * dt) + 1/48 * (omega_2 * omega_1 - omega_1 * omega_2) * dt^2;
  
  q_1 = [q1.vector; q1.scalar];
  q_2 = phi * q_1;
  
  args = struct;
  args.vector = q_2(1:3);
  args.scalar = q_2(4);
  q2 = quaternion(args);
  q2.normalize();
  
end

function ret = omega(w)
  wx = w(1);
  wy = w(2);
  wz = w(3);
  
  ret = [  0  wz -wy wx;
         -wz   0  wx wy;
          wy -wx   0 wz;
         -wx -wy -wz  0];
end

function q2 = propagate_quaternion_zero_order(q1, w, dt)
  
  %disp(sprintf('Starting q: %s', q1.str))
  %disp(sprintf('Body Rate w: %s', w.str))
  
  % Scale the body rate to the time step.
  % A 2 second time step is the same as a 1 sec
  % step at twice the speed.
  w = -w.w * dt;
  
  args = struct;
  args.vector = w / norm(w) * sin(norm(w) / 2 * dt);
  args.scalar = cos(norm(w) / 2 * dt);
  
  phi = quaternion(args);
  
  %disp(sprintf('phi: %s', phi.str))
  
  q2 = phi * q1;
  q2.normalize();
  
end
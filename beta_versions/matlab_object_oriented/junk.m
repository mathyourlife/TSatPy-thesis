function data = junk()
  
  args = struct;
  args.I = eye(3);
  p = plant(args);
  
  p.propagate();
  
  args = struct;
  args.Q_k = eye(3);
  args.R_k = eye(3);
  
  s_ekf = ekf(args);
  
  args = struct;
  args.x = p.state.w.w;
  args.u = [1 2 3]';
  for a = 1:10
    s_ekf.update(args);
    disp(s_ekf.str)
  end
  
  return
  
  angle = 181;
  volts = [cos(angle/180*pi) sin(angle/180*pi) 0]
  
  xp = [1 0 0];
  yp = [0 1 0];
  xn = [-1 0 0];
  yn = [0 -1 0];
  
  
  if check(xp, volts, yp) > 0
    quadrant = 1;
    x = xp; y = yp; z = cross(x, y);
    disp('xp, yp')
  elseif check(yp, volts, xn) > 0
    quadrant = 2;
    x = yp; y = xn; z = cross(x, y);
    disp('yp, xn')
  elseif check(xn, volts, yn) > 0
    quadrant = 3;
    x = xn; y = yn; z = cross(x, y);
    disp('xn, yn')
  else
    quadrant = 4;
    x = yn; y = xp; z = cross(x, y);
    disp('yn, xp')
  end
  
  x
  y
  z
  
  A = [x;y;z]
  pt = A^-1 * volts'
  atan2(pt(2), pt(1))
  quadrant * 90 + (atan2(pt(2), pt(1)) / pi * 180)
  
end

function ret = check(a, volts, b)

  if (dot(a,volts) < 0) & (dot(b,volts) < 0)
    ret = -1;
    return
  end
  c1 = cross(a, volts);
  c2 = cross(volts, b);
  
  ret = dot(c1, c2);
end
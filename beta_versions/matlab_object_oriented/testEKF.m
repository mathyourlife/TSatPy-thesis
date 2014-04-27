function r = testEKF()

  myekf = ekf;

  w_actual = 3*2*pi/60; %rad/s
  dT = 0.5; %s
  N = 200;
  for i=1:N
    angle = (i+20)*dT*w_actual; % + 0.2*randn;
    vector = [0 0 1];
    args = struct; args.vector = vector; args.theta = angle;
    q_sensor=quaternion(args);
    w_val = [0 0 w_actual] + 0.1*rand(1,3);
    args = struct; args.w = w_val;
    w = bodyRate(args);
    args = struct; args.q = q_sensor; args.w = w;
    x = state(args);
    args = stuct; args.state = x;
    myekf = myekf.update(args);
  end

  figure(2)
  plot(myekf.history.qhatp(:,1),myekf.history.qhatp(:,2:end));
end
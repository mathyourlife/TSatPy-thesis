
record_it = 0;

if (record_it)
  scrsz = get(0,'ScreenSize');
  width = 400;
  y = (scrsz(4) - width)/2;
  x = (scrsz(3) - width*1.6)/2;
  scrsz = [x y width*1.6 width];
end

fig = tPlot();

tm_act = tsatModel();
args = struct; args.plot = fig; args.color = 'r';
fig=tm_act.setupPlot(args);
tm_est = tsatModel();
args = struct; args.plot = fig; args.color = 'b';
fig=tm_est.setupPlot(args);
tm_meas = tsatModel();
args = struct; args.plot = fig; args.colot = 'g';
fig=tm_meas.setupPlot(args);

fh=figure(fig.fig_id);
title('Luenberger Observer with Quaternion Dynamics Propagation and Quaternion Multiplication Error Correction')
if (record_it)
  set(fh,'Position',scrsz);
end

rad_per_sec = 3*2*pi/60;
w = [0 0 rad_per_sec]';
w_est = w;

rnd_vec = rand(1,3)-0.5;
rnd_theta = rand() * 2 * pi;
args = struct; args.vector = rnd_vec; args.theta = rnd_theta;
q_o = quaternion(args);
disp(sprintf('Random Starting State: %s',q_o.str))
actual_state = state();


pause_time = 0.01;
check_last = ceil(3/pause_time) + 1;

args = struct; args.q = q_o;
qd = quaternionDynamics(args);


Ks = 100;
Kv1 = 1;
Kv2 = 1;
Kv3 = 10;
Kv = [Kv1 0 0; 0 Kv2 0; 0 0 Kv3];

o_luen = observerLuenberger();
o_luen.Kq.Ks = Ks;
o_luen.Kq.Kv = Kv;

h=hist();
eh=hist();

loop = 1;
if (record_it)
  clear mov;
  frame = 0;
end
while loop
  if (record_it)
    frame = frame + 1;
  end
  pause(pause_time)
  
  theta = rem(now,1)*24*3600*rad_per_sec;
  args = struct; args.vector = [0 0 1]; args.theta = theta;
  actual_state.q = quaternion(args);
  args = struct; args.plot = fig; args.state = actual_state;
  fig=tm_act.updatePlot(args);
  
  args = struct; args.w = w_est;
  br = bodyRate(args);
  args.w = br;
  qd.propagate(args);

  args = struct; args.var = 'q_hat'; args.value = qd.q;
  h = h.log(args);
  
  args = struct; args.q = qd.q;
  s = state(args);
  args = struct; args.plot = fig; args.state = s;
  fig = tm_est.updatePlot(args);

  % Update measured model
  Buffer2Sensor;
  
  args = struct; args.var = 'q'; args.value = tsat.sensors.state.q;
  h = h.log(args);
  
  args = struct; args.plot = fig; args.state = tsat.sensors.state;
  fig=tm_meas.updatePlot(args);
  
  args = struct; args.q = tsat.sensors.state.q; args.q_hat = qd.q;
  q_e = quaternionError(args);
  
  args = struct; args.var = 'q'; args.value = q_e;
  eh = eh.log(args);
  
  % Estimator
  args = struct; args.q = q_e;
  s = state(args);
  args = struct; args.state = s;
  o_luen = o_luen.update(args);
  q_e = o_luen.state.q;
  
  % Update the estimated quaternion state
  qd.q = qd.q * q_e.conj;
  
  % Display calculated body rates
  wt = qd.q.conj * qd.q_dot;
  wt.vector = -2 * wt.vector;
  %w_est = wt.vector;
  %disp(wt.str);
  
  %disp(sprintf('w=%s q_e=%s q=%s',wt.str,q_e.str,qd.q.str))
  if (size(eh.logs.q,1) > check_last)
    %disp(sprintf('%0.5f',mean(abs(eh.q.scalar(end-20:end,2)))))
    if (mean(abs(eh.logs.q(end-check_last:end,5))) > 0.99)
      disp('Error Quaternon is stable')
      loop = 0;
    end
  end
  if (record_it)
    mov(frame)=getframe(fh);
  end
end
if (record_it)
  movie2avi(mov,'filename.avi', 'COMPRESSION', 'Cinepak');
  clear mov;
end

figure(3)
plot(eh.logs.q(:,1), eh.logs.q(:,2), eh.logs.q(:,1), eh.logs.q(:,3), eh.logs.q(:,1), eh.logs.q(:,4));
grid on
figure(4)
plot(eh.logs.q(:,1),abs(eh.logs.q(:,5)))
grid on

args = struct; args.vector = [0,0,1]; args.scalar = 0;
q_hat=quaternion(args);

args = struct; args.vector = [0,1,1]; args.theta = 2*pi/360*90;
q_meas=quaternion(args);

% Calculate the error quaternion
e = q_meas.conj * q_hat;

% Ensure that numerical drift gets normalized back to a unit vector.
e.normalize();

disp(sprintf('q_hat = %s',q_hat.str))
disp(sprintf('q_meas = %s',q_meas.str))
disp(sprintf('e = %s',e.str))

disp('Check error quaternion')
n = q_meas * e;
disp(sprintf('q_meas * e = q_hat = %s',n.str))
n = e * q_hat;
disp(sprintf('e * q_hat = q_meas = %s',n.str))

args = struct; args.q_hat = q_hat; args.q = q_meas;
e = quaternionError(args);
disp(sprintf('e = %s',e.str))







figure(1)
fig= tPlot();
% Setup estimator series
item = struct;
item.name = 'q_hat0';
item.type = 'plot';
item.style = 'b--';
data = struct; data.x = 0; data.y = 0;
item.data = data;
fig=fig.addSeries(item);
for i = 1:3
  item = struct;
  item.name = sprintf('q_hat%d',i);
  item.type = 'plot';
  item.style = 'g--';
  data = struct; data.x = 0; data.y = 0;
  item.data = data;
  fig=fig.addSeries(item);
end

% Setup "true" series
item = struct;
item.name = 'q0';
item.type = 'plot';
item.style = 'b-';
data = struct; data.x = 0; data.y = 0;
item.data = data;
fig=fig.addSeries(item);
for i = 1:3
  item = struct;
  item.name = sprinf('q%d',,i);
  item.type = 'plot';
  item.style = 'g-';
  data = struct; data.x = 0; data.y = 0;
  item.data = data;
  fig=fig.addSeries(item);
end

prop_args = struct;
prop_args.w = [0 0 -3*2*pi/60]';
prop_args.w = bodyRate(prop_args);
qd = quaternionDynamics();

q_e = quaternionError();
h=hist();
eh=hist();
for increment=0:10
  pause(0.5)

  qd.propagate(prop_args);
  args = struct; args.var = 'q_hat'; args.value = qd.q;
  h = h.log(args);
  item = struct;
  item.name = 'q_hat0';
  item.type = 'plot';
  data = struct; data.x = h.logs.q_hat(:,1); data.y = h.logs.q_hat(:,5);
  item.data = data;
  fig = fig.updateSeries(item);
  for i = 1:3
    item = struct;
    item.name = sprintf('q_hat%d',i);
    item.type = 'plot';
    data = struct; data.x = h.logs.q_hat(:,1); data.y = h.logs.q_hat(:,i+1);
    item.data = data;
    fig = fig.updateSeries(item);
  end
  
  % Update measured model
  Buffer2Sensor;

  args = struct; args.var = 'q'; args.value = tsat.sensors.state.q;
  h = h.log(args);
  
  item = struct;
  item.name = 'q0';
  item.type = 'plot';
  data = struct; data.x = h.logs.q(:,1); data.y = h.logs.q(:,5);
  item.data = data;
  fig=fig.updateSeries(item);
  for i = 1:3
    item = struct;
    item.name = sprintf('q%d',i)];
    item.type = 'plot';
    data = struct; data.x = h.logs.q(:,1); data.y = h.logs.q(:,i+1);
    item.data = data;
    fig=fig.updateSeries(item);
  end
  
  args = struct; args.q = tsat.sensors.state.q; args.q_hat = qd.q;
  q_e = quaternionError(args);
  args = struct; args.var = 'q'; args.value = q_e;
  eh = eh.log(args);
  
  % Here's the adjustment for a partial step
  q_e.scalar = q_e.scalar * 50;
  q_e.normalize();
  
  
  % Update the estimated quaternion state
  qd.q = qd.q * q_e.conj;
  
end

figure(3)
plot(eh.logs.q(:,1), eh.logs.q(:,2), eh.logs.q(:,1), eh.logs.q(:,3), eh.logs.q(:,1), eh.logs.q(:,4));
figure(4)
plot(eh.logs.q(:,1),abs(eh.logs.q(:,5)))

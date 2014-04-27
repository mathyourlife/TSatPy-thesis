

disp('Testing the functionality of the quaternion system equations')

disp('Quaternion kinematics q_dot = 1/2 q_w x q')

args = struct; args.w = [0 0 -3*2*pi/60]';
w = bodyRate(args);
args = struct; args.vector = w.w/2; args.scalar = 0;
q_w = quaternion(args);

args = struct; args.vector = [0 0 0]; args.scalar = 1;
q = quaternion(args);



figure(1)
fig = tPlot();
% Setup estimator series
item = struct;
item.name = 'q0';
item.type = 'plot';
item.style = 'b--';
item.data.x = 0;
item.data.y = 0;
fig =fig.addSeries(item);
for i = 1:3
  item.name = sprintf('q%d',i);
  item.style = 'g--';
  fig = fig.addSeries(item);
end

f_prop = 4;
dt = 1/f_prop;
elapse = 60;


h = hist()
for i=1:elapse*f_prop
  pause(dt)
  disp('')
  disp(sprintf('Step %d',i))

  q_dot = q_w * q;
  
  q_dot.vector = q_dot.vector;
  q_dot.scalar = q_dot.scalar;

  disp(sprintf('q_dot = %s',q_dot.str))
  
  % scale basd on propigation frequency
  q_dot.scalar = q_dot.scalar * dt;
  q_dot.vector = q_dot.vector * dt;
  
  q = q + q_dot;
  disp(sprintf('q     = %s',q.str))
  disp('Normalized')
  
  q.normalize();
  disp(sprintf('q     = %s',q.str))
  args = struct; args.var = 'q'; args.value = q;
  h = h.log(args);
  
  item = struct;
  item.name = 'q0';
  item.type = 'plot';
  item.data.x = h.values.q(:,1);
  item.data.y = h.values.q(:,5);
  fig = fig.updateSeries(item);
  for i = 1:3
    item.name = sprintf('q%d',i);
    item.data.x = h.values.q(:,1);
    item.data.y = h.values.q(:,i+1);
    fig = fig.updateSeries(item);
  end
end